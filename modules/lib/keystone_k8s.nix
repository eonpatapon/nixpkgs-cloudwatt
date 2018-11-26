{ pkgs }:

with pkgs.lib;
with builtins;

let

  createProjectUserRole = project: user: roles:
    concatStringsSep "\n" (map (role: ''
      role add --project ${project} --user ${user} ${role}
    '') roles);

  createProjectUsers = project: users:
    concatStringsSep "\n" (mapAttrsToList (user: { password, roles ? [] }: ''
      user create --password '${password}' ${user}
    '' + optionalString (roles != []) (createProjectUserRole project user roles)) users);

  createProject = project: { users ? {} }: ''
    project create ${project}
  '' + optionalString (users != {}) (createProjectUsers project users);

in {

  createProjects = mapAttrsToList createProject;

  createCatalog = catalog: region:
    mapAttrsToList (type: { name, admin_url, internal_url, public_url }: ''
      service create --description '${type} service' --name ${name} ${type}
      endpoint create --region ${region} \
        --adminurl ${admin_url} \
        --internalurl ${internal_url} \
        --publicurl ${public_url} ${type}
    '') catalog;

  createRoles = map (role: ''role create ${role}'');

}
