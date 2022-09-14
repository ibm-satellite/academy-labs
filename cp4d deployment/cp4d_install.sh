#!/bin/bash

source ./cpd_vars.sh

oc login --username=${OCP_USERNAME} \
--password=${OCP_PASSWORD} \
--server=${OCP_URL}

cpd-cli manage login-to-ocp \
--username=${OCP_USERNAME} \
--password=${OCP_PASSWORD} \
--server=${OCP_URL}


oc new-project ${PROJECT_CPFS_OPS}
oc new-project ${PROJECT_CPD_OPS}
oc new-project ${PROJECT_CPD_INSTANCE}

cpd-cli manage apply-scc \
--cpd_instance_ns=${PROJECT_CPD_INSTANCE} \
--components=wkc

cpd-cli manage apply-crio \
  --openshift-type=${OPENSHIFT_TYPE}
  
cpd-cli manage apply-db2-kubelet \
--openshift-type=${OPENSHIFT_TYPE}

sleep 300

## ROSA and ARO
if [ "${OPENSHIFT_TYPE}" != "self-managed" ]; then 

cat <<EOF |oc apply -f -
apiVersion: tuned.openshift.io/v1
kind: Tuned
metadata:
  name: db2u-ipc-tune
  namespace: openshift-cluster-node-tuning-operator
spec:
  profile:
  - name: openshift-db2u-ipc
    data: |
      [main]
      summary=Tune IPC Kernel parameters on OpenShift nodes running Db2U engine PODs
      include=openshift-node

      [sysctl]
      kernel.shmmni = 1536
      kernel.shmmax = 6442450944
      kernel.shmall = 3145728
      kernel.sem = 250 256000 32 1536
      kernel.msgmni = 6144
      kernel.msgmax = 65536
      kernel.msgmnb = 65536

  recommend:
  - match:
    - label: node-role.kubernetes.io/worker
    priority: 10
    profile: openshift-db2u-ipc
EOF

local counter=0
local max=15
until [ $counter -gt $max ]; do
  oc get nodes | grep SchedulingDisabled
  if [ $? -eq 1 ]; then 
    counter=$((counter + max)) 
  else
    echo "[INFO ] nodes are not refreshed, sleeping for 60 seconds"
    ((counter++))
    sleep 60
  fi
done
fi

cpd-cli manage apply-olm \
--release=${VERSION} \
--components=${COMPONENTS} \
--cpd_operator_ns=${PROJECT_CPD_OPS}

oc patch NamespaceScope cpd-operators \
-n ${PROJECT_CPD_OPS} \
--type=merge \
--patch='{"spec": {"csvInjector": {"enable": true} } }'

## Not a 4.0 --> 4.5 upgrade
if [ $? -ne 0 ]; then 
  oc patch NamespaceScope nss-cpd-operators \
  -n ${PROJECT_CPD_OPS} \
  --type=merge \
  --patch='{"spec": {"csvInjector": {"enable": true} } }'
fi

cpd-cli manage setup-instance-ns \
--cpd_instance_ns=${PROJECT_CPD_INSTANCE} \
--cpd_operator_ns=${PROJECT_CPD_OPS}

cpd-cli manage apply-cr \
--components=${COMPONENTS} \
--release=${VERSION} \
--cpd_instance_ns=${PROJECT_CPD_INSTANCE} \
--block_storage_class=${STG_CLASS_BLOCK} \
--file_storage_class=${STG_CLASS_FILE} \
--license_acceptance=true

echo "###########################################"
echo "#                                         #"
echo "#           Install completed             #"
echo "#                                         #"
echo "###########################################"
