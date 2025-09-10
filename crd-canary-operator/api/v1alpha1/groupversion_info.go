package v1alpha1

import (
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
    GroupName = "ops.ezalb.com"
)

func init() {
    metav1.AddToGroupVersion(SchemeBuilder.Scheme, metav1.SchemeGroupVersion{Group: GroupName, Version: "v1alpha1"})
}