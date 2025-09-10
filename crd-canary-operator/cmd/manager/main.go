package main

import (
    "flag"
    "os"
    "time"

    corev1 "k8s.io/api/core/v1"
    "k8s.io/apimachinery/pkg/runtime"
    utilruntime "k8s.io/apimachinery/pkg/util/runtime"
    clientgoscheme "k8s.io/client-go/kubernetes/scheme"
    _ "k8s.io/client-go/plugin/pkg/client/auth"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/log/zap"

    canaryv1 "github.com/EzalB/aws-devops/operator/api/v1alpha1"
    "github.com/yourorg/EzalB/aws-devops/operator/controllers"
)

var (
    scheme = runtime.NewScheme()
)

func init() {
    utilruntime.Must(clientgoscheme.AddToScheme(scheme))
    utilruntime.Must(canaryv1.AddToScheme(scheme))
}

func main() {
    var metricsAddr string
    var probeAddr string
    var enableLeaderElection bool

    flag.StringVar(&metricsAddr, "metrics-addr", ":8080", "The address the metric endpoint binds to.")
    flag.StringVar(&probeAddr, "health-probe-addr", ":8081", "The address the probe endpoint binds to.")
    flag.BoolVar(&enableLeaderElection, "leader-elect", false, "Enable leader election for controller manager.")
    flag.Parse()

    ctrl.SetLogger(zap.New(zap.UseDevMode(true)))

    mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
        Scheme: scheme,
        MetricsBindAddress: metricsAddr,
        HealthProbeBindAddress: probeAddr,
        LeaderElection: enableLeaderElection,
        LeaderElectionID: "canary-operator-leader",
        SyncPeriod: func() *time.Duration { d := 60 * time.Second; return &d }(),
    })

    if err != nil {
        ctrl.Log.Error(err, "unable to start manager")
        os.Exit(1)
    }

    if err = (&controllers.CanaryReleaseReconciler{
        Client: mgr.GetClient(),
        Scheme: mgr.GetScheme(),
        Recorder: mgr.GetEventRecorderFor("canaryrelease-controller"),
        PrometheusURL: os.Getenv("PROMETHEUS_URL"),
    }).SetupWithManager(mgr); err != nil {
        ctrl.Log.Error(err, "unable to create controller", "controller", "CanaryRelease")
        os.Exit(1)
    }

    // health checks
    if err := mgr.AddHealthzCheck("healthz", func(r *ctrl.HealthCheckRequest) error { return nil }); err != nil {
        ctrl.Log.Error(err, "unable to set up health check")
        os.Exit(1)
    }

    if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
        ctrl.Log.Error(err, "problem running manager")
        os.Exit(1)
    }
}