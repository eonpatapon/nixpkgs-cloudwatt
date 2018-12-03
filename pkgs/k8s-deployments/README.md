K8S deployment generation
=========================

Why
===

Since we build docker images with nix why don't build the k8s deployments as
well?

The benefits of specifying docker image and deployment in the same place:

 * image/deployment compatiblity: for any *git rev* we are able to build the
   image and the deployment that works with this image

 * continous testing: the test deployment is derived from the production
   deployment. Less surprises when deploying in production!

 * tracability: we can easily add metadata in generated resources, like
   the *git rev* of this repository. A simple `kubectl describe pod` on any
   production environement will give the *git rev* needed to build the image that
   is running as well as the deployment files.

Usage
=====

You can test the generation by running:

    nix-build -A k8sDeployments.contrail.lab2

An helper is also provided in `tools/copy-deployment.sh`.
This helper generates the deployment files like the command above + :

 * inject the current *git rev* of nixpkgs-cloudwatt in k8s resource metadata
 * copy the files to a target directory, like the `platforms` repos as `yaml` files.

Usage is: `tools/copy-deployment.sh APP ENV DEST [DEPLOYMENT]`

Examples:

    $ tools/copy-deployment.sh contrail lab2 /tmp/test1
    ...
    $ tree /tmp/test1
    ├── analytics.yml
    ├── api-server.yml
    ├── control1.yml
    ├── control2.yml
    ├── discovery.yml
    ├── schema-transformer.yml
    └── svc-monitor.yml

    $ tools/copy-deployment.sh contrail lab2 /tmp/test2 discovery
    ...
    $ tree /tmp/test2
    └── discovery.yml

    $ cat /tmp/test2/discovery.yml | yq '.items[].metadata.labels'
    {
      "kubenix/build": "68552a66663ff1dcf78bbc2c979f48adc9cd8916",
      "nixpkgs-cloudwatt": "76c05db70ff5b751f25e2a323f385aa3a9a83894"
    }
    ...
