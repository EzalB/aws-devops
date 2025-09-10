package controllers

import (
    "net/http"
    "net/http/httptest"
    "testing"
    "time"

    canaryv1 "github.com/EzalB/aws-devops/operator/api/v1alpha1"
)

func TestQueryParsing(t *testing.T) {
    // Start a test server that simulates Prometheus response
    ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.Write([]byte(`{"status":"success","data":{"resultType":"vector","result":[{"value":[1620000000,"0.001"]}]}}`))
    }))
    defer ts.Close()

    r := &CanaryReleaseReconciler{PrometheusURL: ts.URL}
    cr := &canaryv1.CanaryRelease{Spec: canaryv1.CanaryReleaseSpec{SuccessCriteria: canaryv1.SuccessCriteria{ErrorRateThreshold: 0.01, LatencyP95Ms: 300}}}
    ok, err := r.evaluateCanary(nil, cr, "default", "my-canary")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if !ok {
        t.Fatalf("expected ok=true with simulated metrics")
    }
}