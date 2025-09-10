package v1alpha1

import (
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)


// CanaryTargetRef identifies a Kubernetes workload
type CanaryTargetRef struct {
    Kind string `json:"kind"`
    Name string `json:"name"`
    Namespace string `json:"namespace,omitempty"`
}


// SuccessCriteria defines thresholds to consider a canary healthy
type SuccessCriteria struct {
    ErrorRateThreshold float64 `json:"errorRateThreshold"`
    LatencyP95Ms int `json:"latencyP95Ms"`
}


// CanaryReleaseSpec defines the desired state
type CanaryReleaseSpec struct {
    TargetRef CanaryTargetRef `json:"targetRef"`
    Image string `json:"image"`
    CanaryPercent int `json:"canaryPercent"`
    DurationMinutes int `json:"durationMinutes"`
    SuccessCriteria SuccessCriteria `json:"successCriteria"`
}


// CanaryReleaseStatus defines observed state
type CanaryReleaseStatus struct {
    Phase string `json:"phase,omitempty"`
    CanaryName string `json:"canaryName,omitempty"`
    PromotedImage string `json:"promotedImage,omitempty"`
    LastEvaluation *metav1.Time `json:"lastEvaluation,omitempty"`
}


//+kubebuilder:object:root=true
//+kubebuilder:subresource:status
type CanaryRelease struct {
    metav1.TypeMeta `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    Spec CanaryReleaseSpec `json:"spec,omitempty"`
    Status CanaryReleaseStatus `json:"status,omitempty"`
}


//+kubebuilder:object:root=true
type CanaryReleaseList struct {
    metav1.TypeMeta `json:",inline"`
    metav1.ListMeta `json:"metadata,omitempty"`
    Items []CanaryRelease `json:"items"`
}