# Simple Inference Setup on OKE

A small demonstration on how to run an inference setup with Oracle's Kubernetes
Engine (OKE).

# Setup

## Prerequisites

* `terraform`
* `kubectl`
* `helm`

## Installation

1. Clone this repository, populate a new file `terraform.tfvars` with values.
   See [`variables.tf`](./variables.tf) for required variables.
2. Run `terraform apply`.
3. Run the command listed in the output as `access_k8s_public_endpoint`.
4. [Install the NVIDIA GPU Operator.](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#procedure)
   The default configuration should suffice.

# License
 
Copyright (c) 2025 Oracle and/or its affiliates.
 
Licensed under the Universal Permissive License (UPL), Version 1.0.
 
See [LICENSE](./LICENSE) for more details.
