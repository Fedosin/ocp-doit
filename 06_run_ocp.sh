#!/usr/bin/env bash
set -x
set -e

source ocp_install_env.sh
source common.sh

if [ ! -d ocp ]; then
    mkdir -p ocp
    export CLUSTER_ID=$(uuidgen --random)
    cat > ocp/install-config.yml << EOF
baseDomain: ${BASE_DOMAIN}
clusterID:  ${CLUSTER_ID}
machines:
- name:     master
  replicas: 3
- name:     worker
  replicas: 3
metadata:
  name: ${CLUSTER_NAME}
networking:
  clusterNetworks:
  - cidr:             10.128.0.0/14
    hostSubnetLength: 9
  serviceCIDR: 172.30.0.0/16
  type:        OpenshiftSDN
platform:
  openstack:
    NetworkCIDRBlock: 10.0.0.0/16
    baseImage:        ${OPENSTACK_IMAGE}
    cloud:            ${OS_CLOUD}
    externalNetwork:  ${OPENSTACK_EXTERNAL_NETWORK}
    region:           ${OPENSTACK_REGION}
pullSecret: |
  ${PULL_SECRET}
sshKey: |
  ${SSH_PUB_KEY}
EOF
fi


$GOPATH/src/github.com/openshift/installer/bin/openshift-install --log-level=debug ${1:-create} ${2:-cluster} --dir ocp
