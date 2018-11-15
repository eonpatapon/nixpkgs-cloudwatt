# Testing hydra jobs

Jobs are classic Nix expressions, so to test them, you just have to build them:

    % nix-build jobset.nix -A dockerImages.contrailApiServer

Note `pushDockerImages` expressions uses environment variables to provide registry credentials.

## How to test Docker image publish jobs

Currently, the Docker registry url and credential are provided to the
job by using environment variables. We then have to run Nix with these
environment variables (if the Nix deamon is used, you must provide
them to it). If these environment variables are not provided, the
default values points to a local Docker registry. So to locally test
push jobs, you can start a docker registry by using Docker:

    docker run -d -p 5000:5000 registry

Once the docker registry is up and running, we can run the publish job:

    nix-build jobset.nix -A pushDockerImages.contrailApiServer --arg pushToDockerRegistry true

We can then explore the registry and pull the image from it.

## Why we use environment variables to provide credentials to skopeo

We don't want to expose the password value. There is no input type in
Hydra to store and hide a value. Another way could be to store the
password in a file and let Hydra read it. However, Hydra runs Nix in
"restricted mode" which prohibits to access file that are outside of
the nix store.

It would be nice to find another way to do this.
