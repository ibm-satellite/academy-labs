# Lab 9 - Deploy ODF

https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli

In this lab we drive the deployment using CLI, after finishing this lab take a look to [odf on aws](../aws/aws-odf-ebs.md#configure-aws-ebs-storage-configuration-in-satellite) to see how would it be using IBM Cloud Console.

Login to IBM Cloud: See [Login](#login-to-ibm-cloud)

We will use Azure Disk CSI Driver as the storage for ODF, to use Azure Disk CSI Driver first we have to configure / deploy it to the ROKS cluster, then we will deploy ODF.

## Table of Contents

- [Configure Azure Disks](#configure-azure-disks)
  - [Create storage template configuration](#create-storage-template-configuration)
  - [Assign a template storage configuration to a cluster](#assign-a-template-storage-configuration-to-a-cluster)
- [Configure and deploy ODF](#configure-and-deploy-odf)
  - [Create storage template configuration](#create-storage-template-configuration)
  - [Assign template to a cluster](#assign-template-to-a-cluster)
- [Test ODF](#test-odf)
- [Check ODF Deployment in the Console](#check-odf-deployment-in-the-console)

## Configure Azure Disks

We will use Satellite storage templates to configure Azure Disk CSI Driver:

- https://cloud.ibm.com/docs/satellite?topic=satellite-sat-storage-template-ov&interface=cli
- https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-azure-csi&interface=cli

You can create storage configurations by using the Satellite storage template for the storage provider or driver that you want to use, Azure Disk CSI Driver in this case. After you create a storage configuration by using a template, you can assign your storage configuration to your clusters or services.

By using storage templates, you can create storage configurations that can be consistently assigned, updated, and managed across the clusters, service clusters, and cluster groups in your location.

To see available templates:

```
ibmcloud sat storage template ls

Listing Satellite storage templates...
OK
Name                                     Display Name                                   Versions
...
azuredisk-csi-driver                     Azure Disk CSI Driver                          1.18.0, 1.4.0
...

```

Get details and parameters for a template:

```
ibmcloud sat storage template get --name azuredisk-csi-driver --version 1.4.0
Getting Satellite storage template details...
OK

Name:           azuredisk-csi-driver
Display Name:   Azure Disk CSI Driver
Version:        1.4.0

Configuration Parameters
Name                Display Name                  Description                                                                                                                                                                                        Required   Type   Default
location            Location                      The location of your Azure hosts. You can find the location of your virtual machines in the Azure portal or by running the 'az vm show' command. For example 'useast'                              true       text   -
resourceGroup       Resource Group                The name of your Azure resource group. You can find your resource group in the Azure portal or by running the 'az group list' command.                                                             true       text   -
securityGroupName   Network Security Group Name   The security group name. You can find your security group name in the Azure portal by running the 'az network nsg list' command.                                                                   true       text   -
vmType              Virtual Machnine Type         There are two types of virtual machine i.e. 'standard' and 'VMSS'. The standard VM are listed under virtual machines and the VMSSs' VMs are listed under virtual machine scale set as instances.   true       text   -
vnetName            Virtual Network Name          The name of the virtual network. You can find the name of your virtual network in the Azure portal or by running the 'az network vnet list' command.                                               true       text   -

Secret Parameters
Name              Display Name                           Description                                                                                                                                                            Required   Type     Default
aadClientId       Azure Active Directory Client ID       Your Azure Active Directory Client ID. You can find your Client ID in the Azure portal or by running the 'az ad sp list --all' command.                                true       string   -
aadClientSecret   Azure Active Directory Client Secret   Your Azure Active Directory Client Secret.                                                                                                                             true       string   -
subscriptionId    Subscription ID                        Your Azure subscription ID. You can find your subscription ID in the Azure portal or by running the 'az account subscription list' command.                            true       string   -
tenantId          Tenant ID                              The Azure tenant ID that you want to use for your configuration. You can find your tenant ID in the Azure portal or by running the 'az account tenant list' command.   true       string   -

....
```

### Create storage template configuration

Recover the Azure credentials: [Azure Credentials](#recover-your-azure-credentials)

```
Azure client ID (app ID): 58d21686-2688-426f-892e-c7aabed76a51
Azure secret key (password): xxx
Subscription ID: d4a70861-bd5f-46fb-99b4-3aa512929baf
Azure tenant ID: 4e7730a0-17bb-4dfa-8dad-7c54d3e761b7
```

Recover resource group and prefix: [Schematics variables](#gather-data.-resource group and prefix)

```
Resource Group: jordax-academy-4-9602
Prefix: jordax-academy-4-8097
```

Gather Satellite location

```
ibmcloud sat location ls
Retrieving locations...
OK
Name               ID                     Status   Ready   Created      Hosts (used/total)   Managed From
jordax-academy-4   cahrvp4w07i0nklqkbpg   normal   yes     2 days ago   6 / 6                wdc
```

Prepare and execute template creation, change 

```
#-----> Change these values with yours values
aadClientId="58d21686-2688-426f-892e-c7aabed76a51"
aadClientSecret="FHQ8Q~ecmmhZ1oOfEQs14i_0juGe4i-RpGvnlaKn"
subscriptionId="d4a70861-bd5f-46fb-99b4-3aa512929baf"
tenantId="4e7730a0-17bb-4dfa-8dad-7c54d3e761b7"

SAT_RG="jordax-academy-4-9602"
VM_PREFIX="jordax-academy-4-8097"

satLocation="jordax-academy-4"
#-----

location=eastus
securityGroupName="$VM_PREFIX"-sg
vmType=standard
vnetName="$VM_PREFIX"-vpc


ibmcloud sat storage config create --name azure-disk --template-name azuredisk-csi-driver --template-version 1.4.0 --location $satLocation -p tenantId="$tenantId" -p subscriptionId="$subscriptionId" -p aadClientId="$aadClientId" -p aadClientSecret="$aadClientSecret" -p resourceGroup="$SAT_RG" -p location="$location" -p vmType="$vmType" -p securityGroupName="$securityGroupName" -p vnetName="$vnetName"

Creating Satellite storage configuration...
OK
Storage configuration 'azure-disk' was successfully created with ID '280fb72c-cca2-4c25-81dc-f2db6d2ab360'.
```

Review:

```
ibmcloud sat storage config get --config azure-disk

Getting Satellite storage configuration details...
OK

Name:               azure-disk
ID:                 280fb72c-cca2-4c25-81dc-f2db6d2ab360
Template Name:      azuredisk-csi-driver
Template Version:   1.4.0
Location:           jordax-academy-4

Configuration Parameters
Name                Value
location            eastus
resourceGroup       jordax-academy-4-9602
securityGroupName   jordax-academy-4-8097-sg
vmType              standard
vnetName            jordax-academy-4-8097-vpc

Secret Parameters
Name              Value
aadClientId       *****
aadClientSecret   *****
subscriptionId    *****
tenantId          *****

...
```

![image-20220707023319575](.pastes/image-20220707023319575.png)

### Assign a template storage configuration to a cluster

Gather ROKS Cluster id

```
ibmcloud oc cluster ls --provider satellite
OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   2 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg

```

Apply template

```
# user your values
clusterID=cai4c1ew0o3o3vme5fa0
clusterName=jordax-academy-cluster1
# ---

ibmcloud sat storage assignment create --cluster $clusterID --config azure-disk

Creating assignment...
OK
Assignment  was successfully created with ID ed1fb94b-95e0-4770-b4e6-0f3b9a66fc8c.
```

Get kubeconfig (login as admin to ROKS)

```
ibmcloud ks cluster config --cluster $clusterName --admin
```

Check storage pods

```
kubectl get pods -n kube-system | grep azure
csi-azuredisk-controller-68698cd5cf-rbbgg            5/5     Running   0          62s
csi-azuredisk-controller-68698cd5cf-tt2pd            5/5     Running   0          62s
csi-azuredisk-node-4lslp                             3/3     Running   0          62s
csi-azuredisk-node-lmqwr                             3/3     Running   0          62s
csi-azuredisk-node-x6r5s                             3/3     Running   0          62s
```

Get storage classes

```
kubectl get sc

NAME                                   PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
sat-azure-block-bronze                 disk.csi.azure.com   Delete          Immediate              true                   3m39s
sat-azure-block-bronze-metro           disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   3m39s
sat-azure-block-gold                   disk.csi.azure.com   Delete          Immediate              true                   3m40s
sat-azure-block-gold-metro (default)   disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   3m40s
sat-azure-block-platinum               disk.csi.azure.com   Delete          Immediate              true                   3m40s
sat-azure-block-platinum-metro         disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   3m40s
sat-azure-block-silver                 disk.csi.azure.com   Delete          Immediate              true                   3m39s
sat-azure-block-silver-metro           disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   3m40s

```

## Configure and deploy ODF

https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli

One comment about ODF is when you size or estimate the cost you must also size and calculate the costs for the corresponding ROKS workers, in this lab we will reuse the workers we already created instead of creating three new dedicated workers.

For the ODF Storage template it is needed an API Key, for this lab we will use the user API Key, but take a look to the section [Service IDs](#service-ids) for instructions about how to create a Service ID, its API Key and assign the Service ID to an Access Group.

Create API Key

```
ibmcloud iam api-key-create student_key
Creating API key student_key under 20c282cbc5174bdbaddb0a5b94025d9f as javier.ordax@es.ibm.com...
OK
API key student_key was created

Please preserve the API key! It cannot be retrieved after it's created.

ID            ApiKey-952fc334-e93f-48f7-b536-1bb7742e170a
Name          student_key
Description
Created At    2022-06-15T09:02+0000
API Key       9lX1T-xxx
Locked        false
```

Take note of the API Key! you can not recover it latter.

```
ibmcloud sat storage template ls

Listing Satellite storage templates...
OK
Name                                     Display Name                                   Versions
...
odf-remote                               OpenShift Data Foundation for remote storage   4.7, 4.8, 4.9
```

```
ibmcloud sat storage template get --name odf-remote --version 4.9

Getting Satellite storage template details...
OK

Name:           odf-remote
Display Name:   OpenShift Data Foundation for remote storage
Version:        4.9

Configuration Parameters
Name                 Display Name                  Description                                                                                                                                                                                                                          Required   Type      Default
billing-type         Billing type                  The billing type you want to use. Choose from 'essentials' or 'advanced'.                                                                                                                                                            false      text      advanced
cluster-encryption   Encryption enabled            Set to 'true' if you want to enable cluster-wide encryption.                                                                                                                                                                         false      boolean   false
ibm-cos-endpoint     IBM COS endpoint              The IBM COS regional public endpoint.                                                                                                                                                                                                false      text      -
ibm-cos-location     IBM COS location constraint   The location constraint that you want to use when creating your bucket. For example 'us-east-standard'.                                                                                                                              false      text      -
num-of-osd           Number of OSD volumes         The number of OSD volumes that you want to provision. The total storage available to your apps is equal to the volume size (osd-size) multiplied by the number of volumes (num-of-osd). The default value is '1'.                    false      text      1
odf-upgrade          Upgrade                       Set to 'true' if you want to upgrade the ODF version.                                                                                                                                                                                false      boolean   false
osd-size             OSD pod volume size           The OSD storage size in Gi. The default value is '100Gi'.                                                                                                                                                                            true       text      100Gi
osd-storage-class    OSD pod storage class         The storage class to use when dynamically provisioning volumes for the OSD pods.                                                                                                                                                     true       text      -
perform-cleanup      Perform Cleanup               Set to 'true' if you want to perform complete cleanup of ODF on assignment deletion                                                                                                                                                  false      boolean   false
worker-nodes         Worker node names             The node names where you want to deploy ODF. Leave this field blank to deploy ODF across all worker nodes in your cluster. The minimum number of worker nodes is 3. You can find your worker node names by running 'oc get nodes'.   false      text      -

Secret Parameters
Name                 Display Name        Description                            Required   Type   Default
iam-api-key          IAM API key         Your IAM API key.                      true       text   -
ibm-cos-access-key   Access key ID       Your IBM COS HMAC access key ID .      false      text   -
ibm-cos-secret-key   Secret access key   Your IBM COS HMAC secret access key.   false      text   -

```

### Create storage template configuration

We will create an ODF deployment with 3 replicas with 100GB storage available, this implies deploy ODF in three workers each one will configure a Persistent Volume of 100GB

To use OpenShift CLI see [Download OpenShift CLI](#download-openshift-cli)

Gather worker nodes names:

```sh
ibmcloud ks cluster ls

OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name   Provider
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   4 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg             satellite


ibmcloud ks cluster config --cluster $clusterName --admin

OK
The configuration for jordax-academy-cluster1 was downloaded successfully.


oc get nodes
NAME                         STATUS   ROLES           AGE    VERSION
jordax-academy-4-8097-vm-3   Ready    master,worker   4d1h   v1.22.8+f34b40c
jordax-academy-4-8097-vm-4   Ready    master,worker   4d1h   v1.22.8+f34b40c
jordax-academy-4-8097-vm-5   Ready    master,worker   4d1h   v1.22.8+f34b40c
```

Create the template configuration:

```
#-----> Replace with your values
satLocation=jordax-academy-4
workerNodes=jordax-academy-4-8097-vm-3,jordax-academy-4-8097-vm-4,jordax-academy-4-8097-vm-5
apiKey=9lX1T-xxx
#-----------

osdStorageClass=sat-azure-block-gold-metro
osdSize=100Gi
numOfOsd=1


ibmcloud sat storage config create --name odf-config --location $satLocation --template-name odf-remote --template-version 4.9 -p osd-storage-class=$osdStorageClass -p osd-size=$osdSize -p num-of-osd=$numOfOsd -p worker-nodes=$workerNodes -p iam-api-key=$apiKey

Creating Satellite storage configuration...
OK
Storage configuration 'odf-config' was successfully created with ID '8c9c5321-b21b-4d7a-bc44-4887346c70c8'.



ibmcloud sat storage config get --config odf-config

Getting Satellite storage configuration details...
OK

Name:               odf-config
ID:                 a5a24c08-058c-4645-a386-d9f4c9c3db86
Template Name:      odf-remote
Template Version:   4.9
Location:           jordax-academy-4

Configuration Parameters
Name                 Value
billing-type         advanced
cluster-encryption   false
num-of-osd           1
odf-upgrade          false
osd-size             100Gi
osd-storage-class    sat-azure-block-gold-metro
perform-cleanup      false
worker-nodes         jordax-academy-4-8097-vm-3,jordax-academy-4-8097-vm-4,jordax-academy-4-8097-vm-5

Secret Parameters
Name          Value
iam-api-key   *****
```

![image-20220707023753267](.pastes/image-20220707023753267.png)



Note: currently ODF storage template does not support taints / tolerations and / or labels / selectors, so that's why you have to use specify node names, if a worker get replaced you have to replace the name (https://cloud.ibm.com/docs/openshift?topic=openshift-ocs-manage-deployment#odf-vpc-update-worker)

```
oc edit ocscluster 
```

### Assign template to a cluster

Gather ROKS Cluster id

```
ibmcloud oc cluster ls --provider satellite
OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   2 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg
```

Apply template

```
# user your values
clusterID=cai4c1ew0o3o3vme5fa0
# ---

ibmcloud sat storage assignment create --cluster $clusterID --config odf-config
Creating assignment...
OK
Assignment  was successfully created with ID 683acd7e-a453-4aaa-80c3-2f5c23b959e4.
```

Verify that the configuration has been applied. You can list Razee "RemoteResource"

```
oc -n razeedeploy get rr
NAME                                                       AGE
clustersubscription-107aa355-197e-470b-b0b8-f22f45ed2843   8m37s
clustersubscription-474e6330-3187-4e98-a2b0-268a99d2bc81   4m7s
clustersubscription-system-primaryorgkey                   7h49m
```

This is the main pod to check logs if something is not going ok

```
oc get pods -n kube-system | grep ibm-ocs
ibm-ocs-operator-controller-manager-768c8fd559-5bdl4                           1/1     Running     0          14m
```



It is possible that you see as "PHASE" value "Error"... it is normal...

```
oc get storagecluster -n openshift-storage
NAME                 AGE     PHASE   EXTERNAL   CREATED AT             VERSION
ocs-storagecluster   2m57s   Error              2022-07-07T00:39:58Z   4.9.0

oc describe storagecluster -n openshift-storage
...
Status:
  Conditions:
    Last Heartbeat Time:   2022-07-07T00:42:55Z
    Last Transition Time:  2022-07-07T00:39:59Z
    Message:               Error while reconciling: some StorageClasses [ocs-storagecluster-cephfs,ocs-storagecluster-ceph-rbd] were skipped while waiting for pre-requisites to be met
    Reason:                ReconcileFailed
    Status:                False
    Type:                  ReconcileComplete
    Last Heartbeat Time:   2022-07-07T00:39:58Z
    Last Transition Time:  2022-07-07T00:39:58Z
    Message:               Initializing StorageCluster
    Reason:                Init
    Status:                False
    Type:                  Available
    Last Heartbeat Time:   2022-07-07T00:39:58Z
    Last Transition Time:  2022-07-07T00:39:58Z
    Message:               Initializing StorageCluster
    Reason:                Init
    Status:                True
    Type:                  Progressing
    Last Heartbeat Time:   2022-07-07T00:39:58Z
    Last Transition Time:  2022-07-07T00:39:58Z
    Message:               Initializing StorageCluster
    Reason:                Init
    Status:                False
    Type:                  Degraded
    Last Heartbeat Time:   2022-07-07T00:39:58Z
    Last Transition Time:  2022-07-07T00:39:58Z
    Message:               Initializing StorageCluster
    Reason:                Init
    Status:                Unknown
    Type:                  Upgradeable
  Failure Domain:          zone
  Failure Domain Key:      topology.kubernetes.io/zone
  Failure Domain Values:
    eastus-3
    eastus-1
    eastus-2

```



```
oc get storagecluster -n openshift-storage

NAME                 AGE    PHASE         EXTERNAL   CREATED AT             VERSION
ocs-storagecluster   9m7s   Progressing              2022-06-15T11:45:58Z   4.9.0


oc get storagecluster -n openshift-storage

NAME                 AGE   PHASE   EXTERNAL   CREATED AT             VERSION
ocs-storagecluster   10m   Ready              2022-06-15T11:45:58Z   4.9.0



oc get pods -n openshift-storage

NAME                                                              READY   STATUS      RESTARTS   AGE
csi-cephfsplugin-gzl5j                                            3/3     Running     0          7m36s
csi-cephfsplugin-lxzjc                                            3/3     Running     0          7m36s
csi-cephfsplugin-mvrhz                                            3/3     Running     0          7m36s
csi-cephfsplugin-provisioner-5b9c6d55cd-7vl76                     6/6     Running     0          7m35s
csi-cephfsplugin-provisioner-5b9c6d55cd-l922d                     6/6     Running     0          7m35s
csi-rbdplugin-ldgtd                                               3/3     Running     0          7m37s
csi-rbdplugin-provisioner-5b674484d-ltgv5                         6/6     Running     0          7m37s
csi-rbdplugin-provisioner-5b674484d-nbmrd                         6/6     Running     0          7m37s
csi-rbdplugin-pwws5                                               3/3     Running     0          7m37s
csi-rbdplugin-s59rx                                               3/3     Running     0          7m37s
noobaa-core-0                                                     1/1     Running     0          2m11s
noobaa-db-pg-0                                                    1/1     Running     0          2m11s
noobaa-endpoint-7b49dfb9f8-s42hf                                  1/1     Running     0          52s
noobaa-operator-6b5d8ffbc7-hj7hx                                  1/1     Running     0          10m
ocs-metrics-exporter-6659bcdcfb-cpszv                             1/1     Running     0          10m
ocs-operator-5bc589f4c4-t8w6p                                     1/1     Running     0          10m
odf-console-85b7f578c9-stzfm                                      1/1     Running     0          10m
odf-operator-controller-manager-6f885fcc64-4bvfd                  2/2     Running     0          10m
rook-ceph-crashcollector-jordax-academy-4-8097-vm-3-84549fd68rl   1/1     Running     0          4m27s
rook-ceph-crashcollector-jordax-academy-4-8097-vm-4-66979frwrj8   1/1     Running     0          4m20s
rook-ceph-crashcollector-jordax-academy-4-8097-vm-5-5989776br7x   1/1     Running     0          4m26s
rook-ceph-mds-ocs-storagecluster-cephfilesystem-a-f68b57cc4m54k   2/2     Running     0          2m47s
rook-ceph-mds-ocs-storagecluster-cephfilesystem-b-864c475ddfrs6   2/2     Running     0          2m46s
rook-ceph-mgr-a-8ddd9789-ntf4x                                    2/2     Running     0          4m27s
rook-ceph-mon-a-5bffcd6d75-6hnck                                  2/2     Running     0          6m52s
rook-ceph-mon-b-8db76d745-psqgh                                   2/2     Running     0          5m27s
rook-ceph-mon-c-6c994f596f-fl26x                                  2/2     Running     0          5m
rook-ceph-operator-7b5b5f9676-f6t5g                               1/1     Running     0          10m
rook-ceph-osd-0-76976bcbbb-cmp8q                                  2/2     Running     0          4m
rook-ceph-osd-1-5c74c9c4dd-krn2p                                  2/2     Running     0          3m44s
rook-ceph-osd-2-77dbc897d8-p4dj8                                  2/2     Running     0          3m13s
rook-ceph-osd-prepare-ocs-deviceset-0-data-0bx2pb--1-ddb4c        0/1     Completed   0          4m20s
rook-ceph-osd-prepare-ocs-deviceset-1-data-0mjd2w--1-gsxn6        0/1     Completed   0          4m20s
rook-ceph-osd-prepare-ocs-deviceset-2-data-0j6xch--1-rwd5h        0/1     Completed   0          4m20s
rook-ceph-rgw-ocs-storagecluster-cephobjectstore-a-7d7d5b48gklp   2/2     Running     0          2m45s


oc get sc | grep ocs

ocs-storagecluster-ceph-rbd            openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   3m16s
ocs-storagecluster-ceph-rgw            openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  8m48s
ocs-storagecluster-cephfs              openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   3m16s
sat-ocs-cephfs-gold                    openshift-storage.cephfs.csi.ceph.com   Delete          Immediate              true                   12m
sat-ocs-cephfs-gold-metro              openshift-storage.cephfs.csi.ceph.com   Delete          WaitForFirstConsumer   true                   12m
sat-ocs-cephrbd-gold                   openshift-storage.rbd.csi.ceph.com      Delete          Immediate              true                   12m
sat-ocs-cephrbd-gold-metro             openshift-storage.rbd.csi.ceph.com      Delete          WaitForFirstConsumer   true                   12m
sat-ocs-cephrgw-gold                   openshift-storage.ceph.rook.io/bucket   Delete          Immediate              false                  12m
sat-ocs-noobaa-gold                    openshift-storage.noobaa.io/obc         Delete          Immediate              false                  12m

```

Information about Storage classes https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli#sat-storage-odf-remote-sc-ref

## Test ODF

```
vi test.yaml

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
  storageClassName: sat-ocs-cephfs-gold
      
---
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
  namespace: default
spec:
  containers:
  - name: test-pod
    image: gcr.io/google_containers/busybox:1.24
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && echo 'success' && exit 0 || exit 1"
    volumeMounts:
      - name: odf-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: odf-pvc
      persistentVolumeClaim:
        claimName: test-claim    
 
oc create -f test.yaml

persistentvolumeclaim/test-claim created
pod/test-pod created


oc get pods -n default

NAME       READY   STATUS      RESTARTS   AGE
test-pod   0/1     Completed   0          51s

oc logs test-pod -n default
success


oc get pvc -n default

NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
test-claim   Bound    pvc-c94783e9-c592-43e0-9d23-e78fd7f3b19c   1Mi        RWX            sat-ocs-cephfs-gold   99s


oc get pv | grep test-claim
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                           STORAGECLASS                  REASON   AGE
pvc-c94783e9-c592-43e0-9d23-e78fd7f3b19c   1Mi        RWX            Delete           Bound    default/test-claim                              sat-ocs-cephfs-gold                    96s

```

## Check ODF Deployment in the OpenShift Console

You can find a **Data Foundation** page with some performance (i.e. IOPS, Latency, and Throughput) in the Administrator perspective of the Cluster Console.

![Data Foundation](images/odf-console.png)
