# Azure Labs

# Table of contents

- [Azure Labs](#azure-labs)
  - [Lab1 - Check status](#lab1---check-status)
  - [Lab2 - Add new hosts to the location](#lab2---add-new-hosts-to-the-location)
    - [Gather data. Resource Group and Prefix](#gather-data-resource-group-and-prefix)
    - [Create VMs using AZ CLI](#create-vms-using-az-cli)
    - [Attach hosts to the location](#attach-hosts-to-the-location)
      - [Prepare VM](#prepare-vm)
      - [Get and execute attach script](#get-and-execute-attach-script)
  - [Lab X - Logging](#lab-x---logging)
    - [Create a logging instance](#create-a-logging-instance)
    - [Configure Platform logs](#configure-platform-logs)
    - [Deploy logging agent](#deploy-logging-agent)
      - [Gather log DNA ingestion key](#gather-log-dna-ingestion-key)
      - [Deploy LogDNA agents](#deploy-logdna-agents)
    - [](#)
      - [View Logs](#view-logs)
  - [Lab X - Monitoring](#lab-x---monitoring)
    - [Create Monitoring Instance](#create-monitoring-instance)
    - [Gater SysDig AccessKey](#gater-sysdig-accesskey)
    - [Deploy SysDig agent](#deploy-sysdig-agent)
    - [Open Dashboard](#open-dashboard)
  - [Lab X - Activity Tracker](#lab-x---activity-tracker)
    - [Create an instance](#create-an-instance)
    - [Dashboard](#dashboard)
  - [Lab X - Configure Registry with Object Storage](#lab-x---configure-registry-with-object-storage)
    - [Create Azure "bucket"](#create-azure-bucket)
    - [Configure ROKS Registry to use Azure Object Storage (BLOB)](#configure-roks-registry-to-use-azure-object-storage-blob)
    - [Test deployment](#test-deployment)
  - [Lab X - Deploy ODF](#lab-x---deploy-odf)
    - [Configure Azure Disks](#configure-azure-disks)
      - [Create storage template configuration](#create-storage-template-configuration)
      - [Assign a template storage configuration to a cluster](#assign-a-template-storage-configuration-to-a-cluster)
    - [Configure and deploy ODF](#configure-and-deploy-odf)
      - [Create storage template configuration](#create-storage-template-configuration)
      - [Assign template to a cluster](#assign-template-to-a-cluster)
      - [Test ODF](#test-odf)
  - [Lab X - Replace Control plane](#lab-x---replace-control-plane)
    - [Remove the VM in Azure IaaS](#remove-the-vm-in-azure-iaas)
    - [Replace Control plane](#replace-control-plane)
      - [Remove host from location](#remove-host-from-location)
      - [Assign a new host as Control Plane](#assign-a-new-host-as-control-plane)
  - [Lab X - Add new worker to ROKS](#lab-x---add-new-worker-to-roks)
- [Apendix](#apendix)
  - [Create new hosts using terraform](#create-new-hosts-using-terraform)
    - [Install terraform](#install-terraform)
    - [Terraform files](#terraform-files)
    - [Init terraform](#init-terraform)
    - [Create the VM](#create-the-vm)
    - [](#)
  - [Login to IBM Cloud](#login-to-ibm-cloud)
    - [Install CLI](#install-cli)
    - [Login](#login)
  - [Recover your Azure credentials](#recover-your-azure-credentials)
  - [Service IDs](#service-ids)
  - [Login to Azure](#login-to-azure)
    - [Install azure CLI on CentOS](#install-azure-cli-on-centos)
    - [Login](#login)



## Lab1 - Check status

### UI

Go to the left navigation menu, on top left corner to the left of IBM Cloud and the click on Satellite Locations

![image-20220610103944390](.pastes/image-20220610103944390.png)



Click on the location

![image-20220610104015815](.pastes/image-20220610104015815.png)



On the Overview page, you can see status is normal

![image-20220611093153409](.pastes/image-20220611093153409.png)



On left side click on Hosts to show the hosts attached to the location and all hosts in normal

![image-20220611215131389](.pastes/image-20220611215131389.png)

Review Cluster state

![image-20220616173642404](.pastes/image-20220616173642404.png)

![image-20220616173613024](.pastes/image-20220616173613024.png)

### CLI

Check location status

```
ibmcloud sat location ls
Retrieving locations...
OK
Name               ID                     Status   Ready   Created        Hosts (used/total)   Managed From
jordax-academy-4   cahrvp4w07i0nklqkbpg   normal   yes     20 hours ago   6 / 6                wdc


ibmcloud sat location get --location jordax-academy-4
Retrieving location...
OK

Name:                           jordax-academy-4
ID:                             cahrvp4w07i0nklqkbpg
Created:                        2022-06-10 22:04:20 +0000 (20 hours ago)
Managed From:                   wdc
State:                          normal
Ready for deployments:          yes
Message:                        R0001: The Satellite location is ready for operations.
Hosts Available:                0
Hosts Total:                    6
Host Zones:                     eastus-1, eastus-2, eastus-3
Public Service Endpoint URL:    https://c117.us-east.satellite.cloud.ibm.com:30623
Private Service Endpoint URL:   -
OpenVPN Server Port:            -
```

"R0001: The Satellite location is ready for operations." is the correct message when the location is enabled and ready.

If status indicates warning with an error code, refer to steps needed to fix it as in cloud docs https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug

Check cluster status:

```
ibmcloud ks cluster ls
OK
Name                      ID                     State    Created        Workers   Location           Version                 Resource Group Name   Provider
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   11 hours ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg             satellite


ibmcloud ks cluster get --cluster jordax-academy-cluster1 | grep Status
Status:                         All Workers Normal
Ingress Status:                 Normal
Status:     Ready
```



## Lab2 - Add new hosts to the location

We will use terraform to create two new hosts in Azure.

### Gather data. Resource Group and Prefix

Normally all this information is well know by Azure IaaS administrators, it is also possible to gather it from the schematics job logs.

The resource group is generated by the terraform template executed with Schematics, you can gather the name from the schematics workspace.

![image-20220610124116284](.pastes/image-20220610124116284.png)

Go to Settings

![image-20220610124143966](.pastes/image-20220610124143966.png)

And in variables look for "az_resource_group", in this case it is "jordax-academy-4-9602"

![image-20220611210436130](.pastes/image-20220611210436130.png)

The terraform template generate all artifacts with a specific prefix, look for "az_resource_prefix", in this case it is "jordax-academy-4-8097"

![image-20220611210421332](.pastes/image-20220611210421332.png)

### Create VMs using AZ CLI

Gather azure credentials [Azure credentials](#recover-your-azure-credentials) and login

```
az login --service-principal -u 58d21686-2688-426f-892e-c7aabed76a51 -p xxx --tenant 4e7730a0-17bb-4dfa-8dad-7c54d3e761b7
```

Create VMs:

```
AZ_RESOURCE_GROUP=jordax-academy-4-9602
AZ_PREFIX=jordax-academy-4-8097


az vm create --name "$AZ_PREFIX"-cp4 --resource-group $AZ_RESOURCE_GROUP --admin-user adminuser --admin-password LongPassw0rd! --image RedHat:RHEL:7-LVM:latest --nsg "$AZ_PREFIX"-sg --os-disk-name "$AZ_PREFIX"-cp4-disk1 --os-disk-size-gb 128 --data-disk-sizes-gb 100 --size Standard_D16as_v4 --zone 1 --vnet-name "$AZ_PREFIX"-vpc --subnet "$AZ_PREFIX"-subnet-1 --public-ip-sku Standard

{
  "fqdns": "",
  "id": "/subscriptions/d4a70861-bd5f-46fb-99b4-3aa512929baf/resourceGroups/jordax-academy-4-9602/providers/Microsoft.Compute/virtualMachines/jordax-academy-4-8097-cp4",
  "location": "eastus",
  "macAddress": "00-0D-3A-8D-6A-63",
  "powerState": "VM running",
  "privateIpAddress": "10.0.1.6",
  "publicIpAddress": "20.84.66.93",
  "resourceGroup": "jordax-academy-4-9602",
  "zones": "1"
}


az vm create --name "$AZ_PREFIX"-w4 --resource-group $AZ_RESOURCE_GROUP --admin-user adminuser --admin-password LongPassw0rd! --image RedHat:RHEL:7-LVM:latest --nsg "$AZ_PREFIX"-sg --os-disk-name "$AZ_PREFIX"-w4-disk1 --os-disk-size-gb 128 --data-disk-sizes-gb 100 --size Standard_D16as_v4 --zone 1 --vnet-name "$AZ_PREFIX"-vpc --subnet "$AZ_PREFIX"-subnet-1 --public-ip-sku Standard

{
  "fqdns": "",
  "id": "/subscriptions/d4a70861-bd5f-46fb-99b4-3aa512929baf/resourceGroups/jordax-academy-4-9602/providers/Microsoft.Compute/virtualMachines/jordax-academy-4-8097-w4",
  "location": "eastus",
  "macAddress": "00-0D-3A-8C-33-EE",
  "powerState": "VM running",
  "privateIpAddress": "10.0.1.7",
  "publicIpAddress": "20.119.80.61",
  "resourceGroup": "jordax-academy-4-9602",
  "zones": "1"
}

```

 

### Attach hosts to the location

#### Prepare VM

In the documentation https://cloud.ibm.com/docs/satellite?topic=satellite-azure#azure-host-attach it is explained that you can add the following lines to the "attach script" that we will download later but we are going to explicitly run them. So connect to the VMs and run them.

Connect to one of the VMs and then connect to the other one ("20.185.255.248" and "40.88.145.118")

```
ssh adminuser@20.84.66.93

Are you sure you want to continue connecting (yes/no)? yes

adminuser@20.84.66.93's password: LongPassw0rd!


sudo -i

# Grow the base volume group first
echo -e "r\ne\ny\nw\ny\ny\n" | gdisk /dev/sda
# Mark result as true as this returns a non-0 RC when syncing disks
echo -e "n\n\n\n\n\nw\n" | fdisk /dev/sda || true
partx -l /dev/sda || true
partx -v -a /dev/sda || true
pvcreate /dev/sda5
vgextend rootvg /dev/sda5
# Grow the TMP LV
lvextend -L+10G /dev/rootvg/tmplv
xfs_growfs /dev/rootvg/tmplv
# Grow the var LV
lvextend -L+20G /dev/rootvg/varlv
xfs_growfs /dev/rootvg/varlv

# Enable Azure RHEL Updates
yum update --disablerepo=* --enablerepo="*microsoft*" -y
yum-config-manager --enable '*'
yum repolist all
yum install container-selinux -y

.....

Installed:
  container-selinux.noarch 2:2.119.2-1.911c772.el7_8

Complete!

```

Do not forget to run the same in the second VM

```
ssh adminuser@20.119.80.61

....
```



#### Get and execute attach script

![image-20220613163931753](.pastes/image-20220613163931753.png)

![image-20220613164148290](.pastes/image-20220613164148290.png)

![image-20220613164243142](.pastes/image-20220613164243142.png)

Save the file and move it to the Azure VMs, You can do a copy & paste of the content. In the azure VM:

```
vi attachHost-jordax-academy-4.sh

#!/usr/bin/env bash
cat << 'HERE' >>/usr/local/bin/ibm-host-attach.sh
#!/usr/bin/env bash
....

chmod +x attachHost-jordax-academy-4.sh
nohup bash attachHost-jordax-academy-4.sh &
(Press Enter)

journalctl -f -u ibm-host-attach
....
 + true
 + set +ex
 % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
 Dload  Upload   Total   Spent    Left  Speed
 [234B blob data]
 ++ echo '{"id":"","isAssigned":false,"script":""}'
 ++ python3 -c 'import sys, json; print(json.load(sys.stdin)['\''isAssigned'\''])'
 ++ awk '{print tolower($0)}'
 + isAssigned=false
 + [[ false == \t\r\u\e ]]
 + [[ false != \f\a\l\s\e ]]
 + sleep 10
 
 
```

It will be in that loop until the VM is assigned to a service or as control plane, this is a loop because the communication is from the VM to IBM Cloud, not reverse, so there is no service running in the VM waiting for a call from IBM Cloud, it is the VM asking all the time which is its responsibility.

Then you can see the VM in the location hosts in state "Unassigned"

![image-20220613230835438](.pastes/image-20220613230835438.png)



Copy and execute the script in the second VM, the script is always the same for the location unless you configure specific custom labels.

![image-20220613231544017](.pastes/image-20220613231544017.png)

## Lab X - Logging

### Create a logging instance 

Go to Observability, you can do this although through the IBM Cloud Catalog

![image-20220615121656777](.pastes/image-20220615121656777.png)



![image-20220615121859678](.pastes/image-20220615121859678.png)



![image-20220615121930698](.pastes/image-20220615121930698.png)

![image-20220615121945766](.pastes/image-20220615121945766.png)

![image-20220615122027673](.pastes/image-20220615122027673.png)

![image-20220615122037535](.pastes/image-20220615122037535.png)



![image-20220615122129079](.pastes/image-20220615122129079.png)



### Configure Platform logs

Configure the logging instance a "Platform logs" so in case there are some issues wit following labs there are logs available to troubleshoot.

![image-20220615122326660](.pastes/image-20220615122326660.png)

![image-20220615122400076](.pastes/image-20220615122400076.png)

![image-20220615122417286](.pastes/image-20220615122417286.png)

Give it some minutes

![image-20220615123201861](.pastes/image-20220615123201861.png)

### Deploy logging agent

In Satellite clusters you can not configure the IBM Cloud Logging using the console or the CLI, you must deploy manually the log agent.

#### Gather log DNA ingestion key

https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-ingestion_key

Login to IBM Cloud. [Login](#login-to-ibm-cloud)

```
ibmcloud resource service-instances

Name                                                                  Location   State    Type               Resource Group ID
IBM Log Analysis - us-east                                            us-east    active   service_instance   67a3bfe503c64e62b53ab0c4f4dd7da5
...


ibmcloud resource service-keys --instance-name "IBM Log Analysis - us-east"

Name                                           State    Created At
IBM Log Analysis - us-east-key-Administrator   active   Wed Jun 15 10:20:46 UTC 2022


ibmcloud resource service-key "IBM Log Analysis - us-east-key-Administrator"
...
ingestion_key:            f8e8757d19465f587e67b6456c952c79
...

```

#### Deploy LogDNA agents  

https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-config_agent_os_cluster

We will use public endpoint and version 3.

To check available / supported versions: https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-log_analysis_agent#log_analysis_agent_image_kube_versions

![image-20220615130642282](.pastes/image-20220615130642282.png)



I will use [custom tags](https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-adding_tags) to be able to make searches on the Logging instance based on those tags, so first I'm going to download the logging agent yaml file to edit it

```
wget https://assets.us-east.logging.cloud.ibm.com/clients/logdna-agent/3/agent-resources-openshift.yaml
vi agent-resources-openshift.yaml

Look for this object:

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logdna-agent

Add:
          env:
            - name: LOGDNA_TAGS
              value: academy-tag

```



```
ibmcloud ks cluster ls

OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name   Provider
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   4 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg             satellite


ibmcloud ks cluster config --cluster jordax-academy-cluster1 --admin
```



```
logdnaAgentKey="f8e8757d19465f587e67b6456c952c79"

oc adm new-project --node-selector='' ibm-observe

oc create serviceaccount logdna-agent -n ibm-observe
oc adm policy add-scc-to-user privileged system:serviceaccount:ibm-observe:logdna-agent

oc create secret generic logdna-agent-key --from-literal=logdna-agent-key=$logdnaAgentKey -n ibm-observe

kubectl apply -f agent-resources-openshift.yaml -n ibm-observe

role.rbac.authorization.k8s.io/logdna-agent created
rolebinding.rbac.authorization.k8s.io/logdna-agent created
clusterrole.rbac.authorization.k8s.io/logdna-agent created
clusterrolebinding.rbac.authorization.k8s.io/logdna-agent created
daemonset.apps/logdna-agent created


kubectl get pods -n ibm-observe

NAME                 READY   STATUS    RESTARTS   AGE
logdna-agent-hxhsj   1/1     Running   0          70s
logdna-agent-qpbd9   1/1     Running   0          70s
logdna-agent-slq2m   1/1     Running   0          70s

```

### 

#### View Logs

![image-20220615133530681](.pastes/image-20220615133530681.png)



![image-20220615133624114](.pastes/image-20220615133624114.png)

As this logging instance can be used for any other service you can filter your cluster logs as in the sample with "tag:academy-tag"

## Lab X - Monitoring

### Create Monitoring Instance

Go to Observability, you can do this although through the IBM Cloud Catalog

![image-20220615121656777](.pastes/image-20220615121656777.png)

![image-20220615164526954](.pastes/image-20220615164526954.png)



![image-20220615164549774](.pastes/image-20220615164549774.png)

![image-20220615164631814](.pastes/image-20220615164631814.png)

![image-20220615164651373](.pastes/image-20220615164651373.png)

![image-20220615164709134](.pastes/image-20220615164709134.png)

![image-20220615164958323](.pastes/image-20220615164958323.png)

### Gater SysDig AccessKey

Login to IBM Cloud. [Login](#login-to-ibm-cloud)

https://cloud.ibm.com/docs/monitoring?topic=monitoring-access_key#access_key_cli

```
ibmcloud resource service-instances
...
Location   State    Type               Resource Group ID
IBM Cloud Monitoring-us-east                                          us-east    active   service_instance   67a3bfe503c64e62b53ab0c4f4dd7da5
...


ibmcloud resource service-keys --instance-name "IBM Cloud Monitoring-us-east"
...
Name                                             State    Created At
IBM Cloud Monitoring-us-east-key-Administrator   active   Wed Jun 15 14:47:22 UTC 2022


ibmcloud resource service-key "IBM Cloud Monitoring-us-east-key-Administrator"
...
 Sysdig Access Key:           a05997cd-4c1d-42ed-9af1-e5bb92544d72
...
```

### Deploy SysDig agent

https://cloud.ibm.com/docs/monitoring?topic=monitoring-config_agent#config_agent_kube_os_script

Login to ROKS

```
ibmcloud ks cluster ls

OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name   Provider
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   4 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg             satellite


ibmcloud ks cluster config --cluster jordax-academy-cluster1 --admin
```

Create credentials

```
ibmcloud iam service-id-create all-icr-io --description "Grant access to private Sysdig agent image"
ibmcloud iam service-api-key-create all-icr-io-apikey all-icr-io

Service ID API key all-icr-io-apikey is created

Please preserve the API key! It cannot be retrieved after it's created.

ID            ApiKey-cb81c9cb-097c-4058-b074-99beebcca9df
Name          all-icr-io-apikey
Description
Created At    2022-06-15T15:11+0000
API Key       H1ESxxxx
Locked        false
```

Take note of the API Key! you can not recover it

```
#------> Replace with your key
apiKey="H1ESxxxx"
#------

oc -n default create secret docker-registry all-icr-io --docker-username=iamapikey --docker-password=$apiKey
```

Deploy Agent

```
sysdigKey="a05997cd-4c1d-42ed-9af1-e5bb92544d72"

curl -sL https://ibm.biz/install-sysdig-k8s-agent | bash -s -- -a $sysdigKey -c ingest.us-east.monitoring.cloud.ibm.com -ac 'sysdig_capture_enabled: false' --openshift
```

The init pods take some time to finish, in my case two minutes.  

```
oc get pods -n ibm-observe
NAME                 READY   STATUS    RESTARTS   AGE
...
sysdig-agent-6nbc4   1/1     Running   0          3m7s
sysdig-agent-bgc8n   1/1     Running   0          3m7s
sysdig-agent-dkj4r   1/1     Running   0          3m7s

```

Give it time also to start seeing information in the DashBoards (30 mins)

### Open Dashboard

![image-20220616102455112](.pastes/image-20220616102455112.png)

![image-20220616103146224](.pastes/image-20220616103146224.png)

![image-20220616103238551](.pastes/image-20220616103238551.png)



## Lab X - Activity Tracker

### Create an instance

Go to Observability, you can do this although through the IBM Cloud Catalog

![image-20220615121656777](.pastes/image-20220615121656777.png)

![image-20220616102046900](.pastes/image-20220616102046900.png)

![image-20220616102220544](.pastes/image-20220616102220544.png)

![image-20220616102342177](.pastes/image-20220616102342177.png)

![image-20220616102358916](.pastes/image-20220616102358916.png)



### Dashboard

![image-20220616103408078](.pastes/image-20220616103408078.png)



## Lab X - Configure Registry with Object Storage

### Create Azure "bucket"

Login to Azure, see [Login Azure](#login-to-azure)

Create resource group

```
az group create --name academy-blob-rg --location eastus

{
  "id": "/subscriptions/d4a70861-bd5f-46fb-99b4-3aa512929baf/resourceGroups/academy-blob-rg",
  "location": "eastus",
  "managedBy": null,
  "name": "academy-blob-rg",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

Create Object Storage (BLOB in Azure vocabulary) instance

```
#----> name must be unique, use your IBM Cloud sufix number
name=academyaccount23
#----

az storage account create --name $name --resource-group academy-blob-rg --location eastus --sku Standard_ZRS --encryption-services blob

...

```

Create a "bucket" (container in Azure vocabulary) and test it using Keys

```

az storage account keys list --resource-group academy-blob-rg --account-name $name

[
  {
    "creationTime": "2022-06-16T08:57:41.503638+00:00",
    "keyName": "key1",
    "permissions": "FULL",
    "value": "1aP9Tk2R/s0kX6RU9MnziS32Yo3ni840BgQmDXlQKTzn4QsafhhQE7J+DAfjZoinSaxo0MM+qdQl+AStsrJFAA=="
  },
  {
    "creationTime": "2022-06-16T08:57:41.503638+00:00",
    "keyName": "key2",
    "permissions": "FULL",
    "value": "EcVSnBjwe7TmW1JW2g2ix3VXH6TGWKQA2VPVvEA+aE0sZxRMzuMPgQrd2lecduiGmD6pMu7/Y0Pn+AStCY6uJQ=="
  }
]


#----> Replace with your key1 value above
key="1aP9Tk2R/s0kX6RU9MnziS32Yo3ni840BgQmDXlQKTzn4QsafhhQE7J+DAfjZoinSaxo0MM+qdQl+AStsrJFAA=="
#----

az storage container create --account-name $name --name roks-registry --account-key $key --auth-mode key

{
  "created": true
}


#Test uploading a dummy file called helloworld
touch helloworld
az storage blob upload --account-name $name --container-name roks-registry --name helloworld --file helloworld --auth-mode login
```



### Configure ROKS Registry to use Azure Object Storage (BLOB)

https://docs.openshift.com/container-platform/4.9/registry/configuring_registry_storage/configuring-registry-storage-azure-user-infrastructure.html

Login to ROKS

```
ibmcloud ks cluster config --cluster jordax-academy-cluster1 --admin
```

Take note of your Azure Object Storage instance

```
academyaccount23
```

Edit OCP Container Registry Operator configuration

```
oc create secret generic image-registry-private-configuration-user --from-literal=REGISTRY_STORAGE_AZURE_ACCOUNTKEY=$key --namespace openshift-image-registry

oc edit configs.imageregistry.operator.openshift.io/cluster

#Replace

spec:
...
  managementState: Removed
...
  storage:
    emptyDir: {}

#With

spec:
...
  managementState: Managed
...
  storage:
    azure:
      accountName: academyaccount23
      container: roks-registry
```

Check status

```
oc get pods -n openshift-image-registry

NAME                                               READY   STATUS      RESTARTS   AGE
...
image-registry-749c6c86c4-tzmlq                    1/1     Running     0          2m10s
...

oc get co

NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
...
image-registry                             4.9.33    True        False         False      2m46s
...

```

### Test deployment

Give it like 10 mins and create a new app

```
oc -n default new-app https://github.com/sclorg/nodejs-ex.git --name=hello-app --strategy=source

oc -n default logs -f buildconfig/hello-app
...
Successfully pushed image-registry.openshift-image-registry.svc:5000/openshift-image-registry/hello-app2@sha256:e2a4838975de39c23e5c55075389aeeeaa42e01ae2ac9ab1db2eebe30d50f888
Push successful
```

If it fails with certificate error

```
error: build error: After retrying 2 times, Pull image still failed due to error: initializing source docker://image-registry.openshift-image-registry.svc:5000/openshift/nodejs@sha256:0a4a2830592ac8dac54b0a37c3229e7135cba4f6f0fd3915caa24665cba65544: pinging container registry image-registry.openshift-image-registry.svc:5000: Get "https://image-registry.openshift-image-registry.svc:5000/v2/": x509: certificate signed by unknown authority
```

Remove the app and try again

```
oc delete all --selector app=hello-app
```



## Lab X - Deploy ODF

https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli

Login to IBM Cloud: See [Login](#login-to-ibm-cloud)

We will use Azure Disk CSI Driver as the storage for ODF, to use Azure Disk CSI Driver first we have to configure / deploy it to the ROKS cluster, then we will deploy ODF.

### Configure Azure Disks

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

#### Create storage template configuration

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

resourceGroup="jordax-academy-4-9602"
prefix="jordax-academy-4-8097"

satLocation="jordax-academy-4"
#-----

location=eastus
securityGroupName="$prefix"-sg
vmType=standard
vnetName="$prefix"-vpc


ibmcloud sat storage config create --name azure-disk --template-name azuredisk-csi-driver --template-version 1.4.0 --location $satLocation -p tenantId="$tenantId" -p subscriptionId="$subscriptionId" -p aadClientId="$aadClientId" -p aadClientSecret="$aadClientSecret" -p resourceGroup="$resourceGroup" -p location="$location" -p vmType="$vmType" -p securityGroupName="$securityGroupName" -p vnetName="$vnetName"

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



#### Assign a template storage configuration to a cluster

Gather ROKS Cluster id

```
ibmcloud oc cluster ls --provider satellite
OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   2 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg

```

Apply template

```
ibmcloud sat storage assignment create --cluster cai4c1ew0o3o3vme5fa0 --config azure-disk

Creating assignment...
OK
Assignment  was successfully created with ID ed1fb94b-95e0-4770-b4e6-0f3b9a66fc8c.
```

Get kubeconfig (login as admin to ROKS)

```
ibmcloud ks cluster config --cluster jordax-academy-cluster1 --admin
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



### Configure and deploy ODF

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

#### Create storage template configuration

We will create an ODF deployment with 3 replicas with 100GB storage available, this implies deploy ODF in three workers each one will configure a Persistent Volume of 100GB

Gather worker nodes names:

```
ibmcloud ks cluster ls

OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name   Provider
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   4 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg             satellite


ibmcloud ks cluster config --cluster jordax-academy-cluster1 --admin

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

Note: currently ODF storage template does not support taints / tolerations and / or labels / selectors, so that's why you have to use specify node names, if a worker get replaced you have to replace the name (https://cloud.ibm.com/docs/openshift?topic=openshift-ocs-manage-deployment#odf-vpc-update-worker)

```
oc edit ocscluster 
```



#### Assign template to a cluster

Gather ROKS Cluster id

```
ibmcloud oc cluster ls --provider satellite
OK
Name                      ID                     State    Created      Workers   Location           Version                 Resource Group Name
jordax-academy-cluster1   cai4c1ew0o3o3vme5fa0   normal   2 days ago   3         jordax-academy-4   4.9.33_1540_openshift   academyrg
```

Apply template

```
ibmcloud sat storage assignment create --cluster cai4c1ew0o3o3vme5fa0 --config odf-config
Creating assignment...
OK
Assignment  was successfully created with ID 683acd7e-a453-4aaa-80c3-2f5c23b959e4.
```

Verify

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

#### Test ODF

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


oc get pods

NAME       READY   STATUS      RESTARTS   AGE
test-pod   0/1     Completed   0          51s

oc logs test-pod
success


oc get pvc

NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
test-claim   Bound    pvc-c94783e9-c592-43e0-9d23-e78fd7f3b19c   1Mi        RWX            sat-ocs-cephfs-gold   99s


oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                           STORAGECLASS                  REASON   AGE
...
pvc-c94783e9-c592-43e0-9d23-e78fd7f3b19c   1Mi        RWX            Delete           Bound    default/test-claim                              sat-ocs-cephfs-gold                    96s

```



## Lab X - Replace Control plane

In this lab we are going to replace a Control plane using one of the hosts that we added to the location and is unassigned.

It is important to learn that Control Planes must never be removed all together, you have to replace one by one waiting between them, this is because in the Control Plane nodes is where kubernetes ETCD database resides, so if you remove more than one at the same time the ETCD will stop working and you will have to ask via IBM ticket to restore a backup. (once you have three control planes ready again)

### Remove the VM in Azure IaaS

Gather resource group used by schematics when creating the VMs

![image-20220610124116284](.pastes/image-20220610124116284.png)

Go to Settings

![image-20220610124143966](.pastes/image-20220610124143966.png)

And in variables look for "az_resource_group", in this case it is "jordax-academy-4-9602"

![image-20220611210436130](.pastes/image-20220611210436130.png)

In Azure the VMs names are the same as the hostname so we can gather the VM name from the location hosts

![image-20220616131036498](.pastes/image-20220616131036498.png)

As we are going to replace a Control Plane we will remove VM "jordax-academy-4-8097-vm-0"

```
#----> Use your value
resourceGroup=jordax-academy-4-9602
vm=jordax-academy-4-8097-vm-0
#----

az vm delete --yes --name $vm --resource-group $resourceGroup

az vm list --resource-group $resourceGroup | grep name | grep -v admin | grep -v -i disk | grep -v pvc-

    "name": "jordax-academy-4-8097-cp4",
    "name": "jordax-academy-4-8097-vm-1",
    "name": "jordax-academy-4-8097-vm-2",
    "name": "jordax-academy-4-8097-vm-3",
    "name": "jordax-academy-4-8097-vm-4",
    "name": "jordax-academy-4-8097-vm-5",
    "name": "jordax-academy-4-8097-w4",

```

The above command only deletes the VM, not the NIC, public IP, disks...

After some minutes the location status will change:

![image-20220616132532078](.pastes/image-20220616132532078.png)

```
ibmcloud sat location get --location jordax-academy-4

ID:                             cahrvp4w07i0nklqkbpg
...
State:                          action required
Ready for deployments:          no
Message:                        R0043: The location does not meet the following requirement: Hosts must have TCP/UDP/ICMP Layer 3 connectivity for all ports across hosts https://ibm.biz/sat-loc-debug#R0043. If you still have issues, contact IBM Cloud Support and include your Satellite location ID.
```



If you take a look to Platform logs

![image-20220616132736351](.pastes/image-20220616132736351.png)

Filter by the location id, in our case "cahrvp4w07i0nklqkbpg"

![image-20220616132832732](.pastes/image-20220616132832732.png)

You would see errors before the state changes on the location overview.

```
Jun 16 13:16:49 satellite crn:v1:bluemix:public:satellite:us-east:a/20c282cbc5174bdbaddb0a5b94025d9f:cahrvp4w07i0nklqkbpg:link:cahrvp4w07i0nklqkbpg 50 flowlog: error when client 10.211.100.183:51110 connecting to j80e9ce1185365420fe2d-6b64a6ccc9c596bf59a86625d8fa2202-ce00.us-east.satellite.appdomain.cloud:30000, conn_type: location, detail: connect ETIMEDOUT 52.142.29.196:30000
Jun 16 13:17:21 satellite crn:v1:bluemix:public:satellite:us-east:a/20c282cbc5174bdbaddb0a5b94025d9f:cahrvp4w07i0nklqkbpg:: Ingress health status: Ingress has been generated
Jun 16 13:17:32 satellite crn:v1:bluemix:public:satellite:us-east:a/20c282cbc5174bdbaddb0a5b94025d9f:cahrvp4w07i0nklqkbpg:: {"logSourceCRN":"crn:v1:bluemix:public:satellite:us-east:a/20c282cbc5174bdbaddb0a5b94025d9f:cahrvp4w07i0nklqkbpg::","saveServiceCopy":true,"Details":{"message":"R0047: IBM Cloud is unable to use the health check endpoint to check the location's health. For more information, see 'https://ibm.biz/satloc-ts-healthcheck'.","errorDetails":"R0047: IBM Cloud is unable to use the health check endpoint to check the location's health. For more information, see 'https://ibm.biz/satloc-ts-healthcheck'.","messageID":"R0047"}} 
```

### Replace Control plane

#### Remove host from location

![image-20220616133147327](.pastes/image-20220616133147327.png)

#### Assign a new host as Control Plane

![image-20220616133314527](.pastes/image-20220616133314527.png)

![image-20220616133329869](.pastes/image-20220616133329869.png)

Refresh

![image-20220616133358106](.pastes/image-20220616133358106.png)

It takes like 30 mins

Normal "on-going states" even if the control plane is Assigned and normal

![image-20220616134343332](.pastes/image-20220616134343332.png)

https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug#R0012

```
If you just assigned hosts to the control plane, wait a while for the bootstrapping process to complete. Otherwise, assign at least one host to each of the three zones for the location itself, to run control plane operations. 
```

Finally...

![image-20220616134937985](.pastes/image-20220616134937985.png)

At this moment we should repeat again the steps done in pre-req about exposing the VMs with public IPs

ROKS will also show a warning message about the location

![image-20220616135252054](.pastes/image-20220616135252054.png)

```
ibmcloud ks cluster get --cluster jordax-academy-cluster1

...
State:                          warning
Status:                         Location Action Required
...
```

This needs more time to change to green...



## Lab X - Add new worker to ROKS

![image-20220616135406902](.pastes/image-20220616135406902.png)

Our nodes are 16vCPU and 64GB so we will configure it to enable "auto-assign to work properly". If not we can always assign the node to the worker pool using the satellite hosts UI as we did with the Control Plane.

Deploy only 1 Worker in eastus-1 that is where we have an Un-assigned node.

![image-20220616140205405](.pastes/image-20220616140205405.png)

![image-20220616140311959](.pastes/image-20220616140311959.png)

# Apendix

## Create new hosts using terraform

### Install terraform

```
wget https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip  
unzip terraform_1.0.6_linux_amd64.zip
rm -f terraform_1.0.6_linux_amd64.zip
mv terraform /usr/local/bin/
```

### Terraform files

In your system create a folder, for example "/terraform_academy", and create inside it the file "main.tf", copy the following content.

For sake of simplicity we will use a single file with "locals" variables instead of having a file for variables definitions and variable values.

- Change "az_xxx" values with your data / credentials obtained for azure.
- Change "resource_group" and "prefix" with the values obtained from "az_resource_group" and "az_resource_prefix" schematics variables
- For "base_nameX" and "subnetX" values leave current values.

main.tf:

```
locals {
  az_subscription_id = "d4a70861-bd5f-46fb-99b4-3aa512929baf"
  az_client_id = "58d21686-2688-426f-892e-c7aabed76a51"
  az_tenant_id = "4e7730a0-17bb-4dfa-8dad-7c54d3e761b7"
  az_password = "xxxx"

  resource_group = "jordax-academy-4-9602"
  prefix = "jordax-academy-4-8097"
  base_name1 = "new1"
  base_name2 = "new2"
  subnet1 = "1"
  subnet2 = "2"


}

provider "azurerm" {
  features {}
  subscription_id = local.az_subscription_id
  client_id       = local.az_client_id
  tenant_id       = local.az_tenant_id
  client_secret   = local.az_password

}


data "azurerm_resource_group" "resource_group" {
  name       = local.resource_group
}

data "azurerm_subnet" "azsubnet1" {
  name                 = "${local.prefix}-subnet-${local.subnet1}"
  virtual_network_name = "${local.prefix}-vpc"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

data "azurerm_subnet" "azsubnet2" {
  name                 = "${local.prefix}-subnet-${local.subnet2}"
  virtual_network_name = "${local.prefix}-vpc"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}


resource "azurerm_public_ip" "public_ip" {
  name                = "${local.prefix}-${local.base_name1}-public-ip"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "az_nic" {
  name                = "${local.prefix}-${local.base_name1}-nic1"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "${local.prefix}-${local.base_name1}-nic-internal"
    subnet_id                     = data.azurerm_subnet.azsubnet1.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

}


resource "azurerm_linux_virtual_machine" "az_host" {
  name                  = "${local.prefix}-${local.base_name1}-vm"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = "Standard_D16as_v4"
  admin_username        = "adminuser"
  admin_password        = "LongPassw0rd!"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.az_nic.id]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-LVM"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "${local.prefix}-${local.base_name1}-disk"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.az_host.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_public_ip" "public_ip2" {
  name                = "${local.prefix}-${local.base_name2}-public-ip"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "az_nic2" {
  name                = "${local.prefix}-${local.base_name2}-nic1"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "${local.prefix}-${local.base_name2}-nic-internal"
    subnet_id                     = data.azurerm_subnet.azsubnet2.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id = azurerm_public_ip.public_ip2.id
  }

}

resource "azurerm_linux_virtual_machine" "az_host2" {
  name                  = "${local.prefix}-${local.base_name2}-vm"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = "Standard_D16as_v4"
  admin_username        = "adminuser"
  admin_password        = "LongPassw0rd!"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.az_nic2.id]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-LVM"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data_disk2" {
  name                 = "${local.prefix}-${local.base_name2}-disk"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach2" {
  managed_disk_id    = azurerm_managed_disk.data_disk2.id
  virtual_machine_id = azurerm_linux_virtual_machine.az_host2.id
  lun                = "10"
  caching            = "ReadWrite"
}


output "ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "ip2" {
  value = azurerm_public_ip.public_ip2.ip_address
}

```

### Init terraform

```
cd /terraform_academy

terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/azurerm...
- Installing hashicorp/azurerm v3.10.0...
- Installed hashicorp/azurerm v3.10.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Create the VM

```
terraform plan -out=deployvm

...
Plan: 10 to add, 0 to change, 0 to destroy.
...

terraform apply "deployvm"
...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

ip = ""
ip2 = ""
```

If Outputs are empty execute again

```
terraform plan -out=deployvm
...
Changes to Outputs:
  + ip  = "20.185.255.248"
  + ip2 = "40.88.145.118"
....
```

### 

## Login to IBM Cloud

### Install CLI

https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli

```
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

ibmcloud version
ibmcloud version 1.3.0+4308925-2020-12-16T07:53:49+00:00
```

### Login

During login use "--sso" in case you have SSO configured with IBM Cloud, like for example the case of IBM users.

```
ibmcloud login --sso

Select an account:
18. itztsglenablement23 (20c282cbc5174bdbaddb0a5b94025d9f) <-> 2566264
Enter a number> 18

ibmcloud target -r us-east
ibmcloud target -g academyrg
```



## Recover your Azure credentials

Recover your credentials provided by the TechZone environment, in TechZone portal go to My Library and click on My Reservations

<img src=".pastes/image2.png" alt="My Reservations" style="zoom:50%;" />

You will see your request

<img src=".pastes/image-20220610102305412.png" alt="image-20220610102305412" style="zoom:75%;" />

If you click on it you will see your credentials:

![image-20220610102422293](.pastes/image-20220610102422293.png)

```
Azure client ID (app ID): 58d21686-2688-426f-892e-c7aabed76a51
Azure secret key (password): xxx
Subscription ID: d4a70861-bd5f-46fb-99b4-3aa512929baf
Azure tenant ID: 4e7730a0-17bb-4dfa-8dad-7c54d3e761b7
```



## Service IDs

Create Service ID

```
ibmcloud iam service-id-create sid_academy --description "Technical Service ID"
Creating service ID sid_academy bound to current account as javier.ordax@es.ibm.com...
OK
Service ID sid_academy is created successfully

ID            ServiceId-e9bf1d88-7821-4a37-98f0-5f6b8fbedd42
Name          sid_academy
Description   Technical Service ID
CRN           crn:v1:bluemix:public:iam-identity::a/20c282cbc5174bdbaddb0a5b94025d9f::serviceid:ServiceId-e9bf1d88-7821-4a37-98f0-5f6b8fbedd42
Version       1-ca196bb281e8a9178fec37fb02da88d0
Locked        false

```

Create API Key

```
ibmcloud iam service-api-key-create academy ServiceId-e9bf1d88-7821-4a37-98f0-5f6b8fbedd42 --description "API key"
Creating API key academy of service ID ServiceId-e9bf1d88-7821-4a37-98f0-5f6b8fbedd42 under account 20c282cbc5174bdbaddb0a5b94025d9f as javier.ordax@es.ibm.com...
OK
Service ID API key academy is created

Please preserve the API key! It cannot be retrieved after it's created.

ID            ApiKey-6fc684aa-0909-4bb7-9239-173c6f8d657f
Name          academy
Description   API key
Created At    2022-06-15T08:58+0000
API Key       xxxx
Locked        false

```

Assign Access Group.

```
ibmcloud iam access-group-service-id-add <access_group_name> ServiceId-e9bf1d88-7821-4a37-98f0-5f6b8fbedd42
```

## Login to Azure

### Install azure CLI on CentOS

```
yum install -y dnf
rpm --import https://packages.microsoft.com/keys/microsoft.asc

echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo

dnf install azure-cli
```

### Login

From ITZ (See [Azure credentials](#Recover-your-azure-credentials)) use:

- clientid in place of app_id after -u
- clientSecret for password-or-secret after -p
- tenantId for tenant

```
az login --service-principal -u 58d21686-2688-426f-892e-c7aabed76a51 -p xxx --tenant 4e7730a0-17bb-4dfa-8dad-7c54d3e761b7
```

