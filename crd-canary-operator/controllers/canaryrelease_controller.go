package controllers

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "strings"
    "time"

    appsv1 "k8s.io/api/apps/v1"
    corev1 "k8s.io/api/core/v1"
    "k8s.io/apimachinery/pkg/api/errors"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/types"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
    "sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
    "sigs.k8s.io/controller-runtime/pkg/log"

    canaryv1 "github.com/EzalB/aws-devops/operator/api/v1alpha1"
)

// CanaryReleaseReconciler reconciles a CanaryRelease object
type CanaryReleaseReconciler struct {
    client.Client
    Scheme *runtime.Scheme
    Recorder ctrl.EventRecorder
    PrometheusURL string
}

//+kubebuilder:rbac:groups=ops.example.com,resources=canaryreleases,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=ops.example.com,resources=canaryreleases/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=apps,resources=deployments,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch
//+kubebuilder:rbac:groups="",resources=events,verbs=create;patch

func (r *CanaryReleaseReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    logger := log.FromContext(ctx)
    cr := &canaryv1.CanaryRelease{}
    if err := r.Get(ctx, req.NamespacedName, cr); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // normalize namespace
    ns := cr.Spec.TargetRef.Namespace
    if ns == "" { ns = req.Namespace }


    stable := &appsv1.Deployment{}
    if err := r.Get(ctx, types.NamespacedName{Name: cr.Spec.TargetRef.Name, Namespace: ns}, stable); err != nil {
        logger.Error(err, "failed to get target deployment")
        r.Recorder.Event(cr, corev1.EventTypeWarning, "TargetMissing", "Target Deployment not found")
        return ctrl.Result{}, nil
    }

    canaryName := cr.Name + "-canary"

    // Ensure canary deployment exists
    canary := &appsv1.Deployment{}
    err := r.Get(ctx, types.NamespacedName{Name: canaryName, Namespace: ns}, canary)
    if errors.IsNotFound(err) {
        // create canary from stable with overridden image & scaled replicas based on percent
        new := r.buildCanaryDeployment(stable, cr, canaryName)
        if err := controllerutil.SetControllerReference(cr, new, r.Scheme); err != nil {
            return ctrl.Result{}, err
        }

        if err := r.Create(ctx, new); err != nil {
            logger.Error(err, "failed to create canary deployment")
            return ctrl.Result{}, err
        }

        r.Recorder.Event(cr, corev1.EventTypeNormal, "CanaryCreated", "Created canary deployment")
        cr.Status.Phase = "CanaryCreated"
        cr.Status.CanaryName = canaryName
        _ = r.Status().Update(ctx, cr)
        return ctrl.Result{RequeueAfter: time.Duration(cr.Spec.DurationMinutes) * time.Minute}, nil
    } else if err != nil {
        return ctrl.Result{}, err
    }

    // Canary exists -> evaluate
    ok, evalErr := r.evaluateCanary(ctx, cr, ns, canaryName)
    now := metav1.NewTime(time.Now())
    cr.Status.LastEvaluation = &now
    if evalErr != nil {
        r.Recorder.Event(cr, corev1.EventTypeWarning, "EvaluationError", evalErr.Error())
        cr.Status.Phase = "EvaluationFailed"
        _ = r.Status().Update(ctx, cr)
        return ctrl.Result{RequeueAfter: 30 * time.Second}, nil
    }

    if ok {
    // Promote: update stable deployment image to canary image and delete canary
        if err := r.promoteCanary(ctx, cr, stable, canary); err != nil {
            r.Recorder.Event(cr, corev1.EventTypeWarning, "PromoteFailed", err.Error())
            return ctrl.Result{}, err
        }
        cr.Status.Phase = "Promoted"
        cr.Status.PromotedImage = cr.Spec.Image
        _ = r.Status().Update(ctx, cr)
        r.Recorder.Event(cr, corev1.EventTypeNormal, "Promoted", "Canary promoted to stable")
        return ctrl.Result{}, nil
    }

    // not ok -> rollback
    if err := r.rollbackCanary(ctx, cr, canary); err != nil {
        r.Recorder.Event(cr, corev1.EventTypeWarning, "RollbackFailed", err.Error())
        return ctrl.Result{}, err
    }
    cr.Status.Phase = "RolledBack"
    _ = r.Status().Update(ctx, cr)
    r.Recorder.Event(cr, corev1.EventTypeNormal, "RolledBack", "Canary rolled back due to failed criteria")

    return ctrl.Result{}, nil
}

func (r *CanaryReleaseReconciler) SetupWithManager(mgr ctrl.Manager) error {
    r.Scheme = mgr.GetScheme()
    return ctrl.NewControllerManagedBy(mgr).
        For(&canaryv1.CanaryRelease{}).
        Owns(&appsv1.Deployment{}).
        Complete(r)
}

func (r *CanaryReleaseReconciler) buildCanaryDeployment(stable *appsv1.Deployment, cr *canaryv1.CanaryRelease, canaryName string) *appsv1.Deployment {
    new := stable.DeepCopy()
    new.ObjectMeta = metav1.ObjectMeta{
        Name: canaryName,
        Namespace: stable.Namespace,
        Labels: stable.Labels,
    }
    new.Spec.Replicas = int32ptr(percentOf(int(*stable.Spec.Replicas), cr.Spec.CanaryPercent))
    // override container image for the first container
    if len(new.Spec.Template.Spec.Containers) > 0 {
        new.Spec.Template.Spec.Containers[0].Image = cr.Spec.Image
        // label pods so metrics queries can find them
        if new.Spec.Template.ObjectMeta.Labels == nil { new.Spec.Template.ObjectMeta.Labels = map[string]string{} }
            new.Spec.Template.ObjectMeta.Labels["canary"] = "true"
    }
    // add label on deployment
    if new.Labels == nil { new.Labels = map[string]string{} }
    new.Labels["canary"] = "true"
    return new
}

func (r *CanaryReleaseReconciler) evaluateCanary(ctx context.Context, cr *canaryv1.CanaryRelease, ns, canaryName string) (bool, error) {
    // Query Prometheus for error rate and p95 latency. The operator expects PROMETHEUS_URL env var
    promURL := r.PrometheusURL
    if promURL == "" { promURL = "http://prometheus-operated.monitoring.svc:9090" }

    // Build queries; assume apps expose metrics with deployment label
    // error rate: rate of 5xx / total
    errorQuery := fmt.Sprintf(`sum(rate(http_server_requests_seconds_count{deployment="%s",status=~"5.."}[1m])) / sum(rate(http_server_requests_seconds_count{deployment="%s"}[1m]))`, canaryName, canaryName)
    p95Query := fmt.Sprintf(`histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{deployment="%s"}[1m])) by (le))`, canaryName)

    errRate, err := r.queryPrometheus(promURL, errorQuery)
    if err != nil { return false, err }
    p95, err := r.queryPrometheus(promURL, p95Query)
    if err != nil { return false, err }

    // log values
    log.FromContext(ctx).Info("evaluation metrics", "errorRate", errRate, "p95ms", p95)

    if errRate > cr.Spec.SuccessCriteria.ErrorRateThreshold { return false, nil }
    if int(p95*1000.0) > cr.Spec.SuccessCriteria.LatencyP95Ms { return false, nil }
    return true, nil
}

func (r *CanaryReleaseReconciler) queryPrometheus(promURL, query string) (float64, error) {
    q := fmt.Sprintf("%s/api/v1/query?query=%s", strings.TrimRight(promURL, "/"), url.QueryEscape(query))
    resp, err := http.Get(q)
    if err != nil { return 0, err }
    defer resp.Body.Close()
    var out struct {
        Status string `json:"status"`
        Data struct { ResultType string `json:"resultType"` ; Result []struct{ Value [2]interface{} `json:"value"` } `json:"result"` } `json:"data"`
    }
    if err := json.NewDecoder(resp.Body).Decode(&out); err != nil { return 0, err }
    if out.Status != "success" { return 0, fmt.Errorf("prometheus status %s", out.Status) }
    if len(out.Data.Result) == 0 { return 0, nil }
    v := out.Data.Result[0].Value[1]
    switch val := v.(type) {
        case string:
            f, err := strconv.ParseFloat(val, 64)
            if err != nil { return 0, err }
            return f, nil
        case float64:
            return val, nil
        default:
            return 0, fmt.Errorf("unexpected value type %T", v)
    }
}

func (r *CanaryReleaseReconciler) promoteCanary(ctx context.Context, cr *canaryv1.CanaryRelease, stable, canary *appsv1.Deployment) error {
    // Update stable container image to cr.Spec.Image
    if len(stable.Spec.Template.Spec.Containers) == 0 { return fmt.Errorf("stable has no containers") }
    stable.Spec.Template.Spec.Containers[0].Image = cr.Spec.Image
    if err := r.Update(ctx, stable); err != nil { return err }
    // delete canary deployment
    if err := r.Delete(ctx, canary); err != nil { return err }
    return nil
}

func (r *CanaryReleaseReconciler) rollbackCanary(ctx context.Context, cr *canaryv1.CanaryRelease, canary *appsv1.Deployment) error {
    // simply delete canary
    if canary == nil { return nil }
    return r.Delete(ctx, canary)
}

// helper
func percentOf(total, pct int) int { return (total * pct) / 100 }
func int32ptr(i int) *int32 { x := int32(i); return &x }
