{ pkgs, config }:

with builtins;
with pkgs.lib;

rec {

  region = head (splitString "." config.networking.domain);

  apiPort = 5000;
  adminApiPort = 35357;

  keystoneApiAdminHost = "keystone-admin-api-pods.service";
  keystoneApiHost = "keystone-api-pods.service";

  keystoneAdminPassword = "development";
  keystoneAdminToken = "development";
  keystoneDBPassword = "development";

  keystoneAdminTokenRc = pkgs.writeTextFile {
    name = "admin-token.openrc";
    text = ''
      export OS_URL="http://${keystoneApiAdminHost}.${config.networking.domain}:${toString adminApiPort}/v2.0"
      export OS_TOKEN="${keystoneAdminToken}"
    '';
  };

  keystoneAdminRc = pkgs.writeTextFile {
    name = "admin.openrc";
    text = ''
      export OS_AUTH_TYPE="v2password"
      export OS_AUTH_URL="http://${keystoneApiAdminHost}.${config.networking.domain}:${toString adminApiPort}/v2.0"
      export OS_REGION_NAME="${region}"
      export OS_PROJECT_NAME="openstack"
      export OS_TENANT_NAME="openstack"
      export OS_USERNAME="admin"
      export OS_PASSWORD="${keystoneAdminPassword}"
      export OS_INTERFACE="admin"
    '';
  };

  k8sResources = { ... }: with pkgs.dockerImages; with pkgs.platforms; {
    kubernetes.resources = {
      deployments.keystone-admin-api = mkMerge [
        (pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/keystone/admin-api.deployment.yml))
        {
          spec.replicas = 1;
          spec.selector.matchLabels = { application = "keystone"; service = "admin-api"; };
          # Since only resources.limits.memory is set in the deployment file k8s default
          # the resources.requests.memory value to the limit value which is very high.
          spec.template.spec.containers.keystone-admin-api = with pulled.keystoneAllImagePatched; {
            resources.requests.memory = "5Mi";
            image = "${imageName}:${pkgs.lib.imageHash pulled.keystoneAllImagePatched}";
          };
        }
      ];
      deployments.keystone-api = mkMerge [
        (pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/keystone/api.deployment.yml))
        {
          spec.replicas = 1;
          spec.selector.matchLabels = { application = "keystone"; service = "api"; };
          spec.template.spec.containers.keystone-api = with pulled.keystoneAllImagePatched; {
            resources.requests.memory = "5Mi";
            image = "${imageName}:${pkgs.lib.imageHash pulled.keystoneAllImagePatched}";
          };
        }
      ];
      services.keystone-admin-api =
        pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/keystone/admin-api-pods.service.yml);
      services.keystone-api =
        pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/keystone/api-pods.service.yml);
    };
  };

}
