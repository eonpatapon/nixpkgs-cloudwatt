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

Workflow
========

  1. Changes are made to docker images
  2. Deployments are updated if needed
  3. A pull request is made
  4. If tests are OK generated deployment files can be copied to the revelant
     `platforms` repo for deployment

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

    $ cat /tmp/test2/discovery.yml | yq '.items[].metadata.labels'
    {
      "kubenix/build": "68552a66663ff1dcf78bbc2c979f48adc9cd8916",
      "nixpkgs-cloudwatt": "76c05db70ff5b751f25e2a323f385aa3a9a83894"
    }
    ...

Adding a deployment
===================

In `pkgs/k8s-deployment/default.nix` add your app in the map:

    hello = callPackage ./hello { };

Create `pkgs/k8s-deployment/hello/default.nix` file with:

    { lib }:

    let

      defaultDeployments = {
        hello = {
          deployment = ./hello.nix;
        };
      };

    in {

      lab2 = lib.buildK8SDeployments defaultDeployments;

      test = lib.buildK8SDeployments defaultDeployments;

    }

The `defaultDeployments` contains the different deployments we generate for our
app, in this case only one. The deployment must be described in the `hello.nix`
file.

Below we have the build targets that correspond to environments. In this case
we just build `defaultDeployments` for any of theses environments.

Create `pkgs/k8s-deployment/hello/hello.nix` file:

    { pkgs, lib, config, dockerImages, ... }:

    {

      require = [
        ../modules/deployment.nix
      ];

      kubernetes.modules.hello = {
        module = "cwDeployment";
        configuration = {
          application = "hello";
          service = "test";
          replicas = 2;
          port = 1;
        };
      };

    }

The deployment uses the `cwDeployment` module that generates a k8s deployment +
k8s service. To see all configuration options of the module look at [the module
file](./modules/deployment.nix).

We can now try to build the deployment with:

    $ nix-build -A k8sDeployments.hello.lab2
    error: The option `kubernetes.modules.hello.configuration.image' is used but not defined.

Indeed the `cwDeployment` module requires the image attribute in its configuration.

We could specify a default value in the deployment but we can also set this
value per environement.

In `pkgs/k8s-deployment/hello/default.nix`:

    { pkgs, lib }:

    with pkgs.lib;

    let

      defaultDeployments = {
        hello = {
          deployment = ./hello.nix;
        };
      };

      lab2Deployments = {
        hello = {
          deployment = ./hello.nix;
          overrides = {
            kubernetes.modules.hello.configuration.image = "lab2-image";
          };
        };
      };

    in {

      lab2 = lib.buildK8SDeployments lab2Deployments;

      test = lib.buildK8SDeployments lab2Deployments;

    }

We create a `lab2Deployments` map and we customize the deployment with the
`overrides` attribute.

Now the build succeed!

    $ nix-build -A k8sDeployments.hello.lab2
    /nix/store/l56px5z0bqb0yilq5jfmrlngqlx5wm18-deployment
    $ ls /nix/store/l56px5z0bqb0yilq5jfmrlngqlx5wm18-deployment
    hello.yml

What if we want to scale down the deployment for the test env?

    { pkgs, lib }:

    with pkgs.lib;

    let

      defaultDeployments = {
        hello.deployment = ./hello.nix;
      };

      lab2Deployments = recursiveUpdate defaultDeployments {
        hello.overrides = {
          kubernetes.modules.hello.configuration.image = "lab2-image";
        };
      };

      testDeployments = recursiveUpdate lab2Deployments {
        hello.overrides = {
          kubernetes.modules.hello.configuration.replicas = mkForce 1;
        };
      };

    in {

      lab2 = lib.buildK8SDeployments lab2Deployments;

      test = lib.buildK8SDeployments testDeployments;

    }

Here instead of creating a complete `lab2Deployments` map, we derive it from
`defaultDeployments`.

We also make the code more consise:

    hello = {
      deployment = ./hello.nix;
    };

Is the same as:

    hello.deployment = ./hello.nix;

We create also `testDeployments` that derives `lab2Deployments` and
override the `replicas` attribute.

We need to use `mkForce` in this case because the attribute is already defined
to some other value in the deployment.

The system will choose one of the two based on some weight. If they have the
same weight it will fail. With `mkForce` we give this value a higher weight.
Try to build without `mkForce`, it will raise an error!
