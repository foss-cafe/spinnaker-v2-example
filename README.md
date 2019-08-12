# spin-helm-demo
If you're planning on using Helm charts with Spinnaker, these resources should serve as a good way to get started.

## What's included?

* A simple "application" running inside a Docker container. Located in `src/`.
* A basic Helm chart that includes a `Deployment` and `Service`
* A `Makefile` for automating various pieces of the process. You could take these commands and integrate them into your CI workflows.

## Dependencies

* `docker`
* `make`
* `helm`
* `aws`
* `curl`
* `jq`
* `yq`

