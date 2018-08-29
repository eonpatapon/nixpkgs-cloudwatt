# Downloaded from the repository openstack/requirements
-c upper-constraints.txt

# I don't know if this is really useful... this comes from the
# cloudwatt docker/neutron repository
PyMySQL

# Downloaded from openstack/neutron
-r requirements-neutron.txt
# Downloaded from openstack/neutron-lbaas
-r requirements-neutron-lbaas.txt

# This file is manually created and fixes some dependencies used by
# the contrail neutron plugin. These dependencies are freezed in order
# to be compatible with the neutron dependencies
-r requirements-contrail-neutron-plugin.txt
