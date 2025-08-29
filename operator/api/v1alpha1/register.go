package v1alpha1

import (
    "k8s.io/apimachinery/pkg/runtime/schema"
    "sigs.k8s.io/controller-runtime/pkg/scheme"
)

var (
    SchemeBuilder = &scheme.Builder{GroupVersion: schema.GroupVersion{Group: GroupName, Version: "v1alpha1"}}
)