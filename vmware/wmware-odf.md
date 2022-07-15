# Install Openshift Data Foundation on Satellite based ROKS Clusters on VMWare

## Table of Contents

1. [Introduction](#introduction)
1. [Create a storage worker pool in the cluster](#create-a-storage-worker-pool-in-the-cluster)
1. [Configure ODF for local devices storage configuration in Satellite](#configure-odf-for-local-devices-storage-configuration-in-satellite)
1. [Check the ODF deployment in your cluster](#check-the-odf-deployment-in-your-cluster)

## Introduction

We would like to deploy OpenShift Data Foundation Add-on to our Satellite based OpenShift Cluster on VMWare using local disks. The procedure contains the following major steps

* Configuration of a VMWare storage configuration for our location and assign to our ROKS Cluster
* Deploy ODF using Satellite ODF storage configuration referencing Storage class

This lab assumes you already have an OpenShift cluster deployed in your Satellite location.

## Create a storage worker pool in the cluster

> Duration: 20 min

ODF could be installed across all the worker nodes of the cluster. Yet, the VMWare Infrastructure still have hosts dedicated for storage. As we do not want to install ODF on all hosts, we will create a dedicated pool for those hosts.

1. From your Satellite location page, select the **Services** menu in the left hand side panel, then click on your cluster name.

    ![sat-services](images/sat-services.png)

1. In the cluster, select the **Worker pools** menu.

    ![cluster-worker-pool](images/cluster-worker-pool.png)

1. Click **Add** to create a new worker pool. Give a meaningful name to this pool such as `storage-pool`.

    ![cluster-add-storage-pool](images/cluster-add-storage-pool.png)

1. Click **Get values from available hosts** to match the 

    ![cluster-pool-match](images/cluster-pool-match.png)

1. Validate by clicking **Set worker pool to match this host configuration**.

1. The warning `Minimum host requirements are not met` should have disappeared. Click **Create** pool.

1. Select **Worker nodes** menu to find out the status of the deployment.

    ![cluster-storage-pool-deploying](images/cluster-storage-pool-deploying.png)

1. Write down the three storage worker names. You will need them in the next step.

    ![node name](images/cluster-storage-pool-name.png)

> Deploying the new storage worker pools will take 30-40 minutes. You may see the error mesage `Critical - Not Ready` after a while. Wait a bit more and your worker pool will turn on `Normal`.

## Configure ODF for local devices storage configuration in Satellite

1. From the Satellite locations dashboard, select the location where you want to create a storage configuration.

1. Select Storage > Create storage configuration

    ![config](images/storage-create-config.png)

1. Enter a name such as `vmware-odf-storage` for your configuration. Select the Storage type **OpenShift Data Foundation for local devices** and the Version **4.9**. Then, click Next.

    ![type](images/storage-create-config2.png)  

1. In the Parameters tab, enter the 3 worker node names and then set the value **Automatic storage volume discovery** to true.

    ![config](images/odf-parameters1.png)

1. On the **Secrets** tab, leave both the Access key ID and Secret access key empty. Enter your IAM API key.

    ![config](images/odf-parameters2.png)

1. On the **Storage classes** tab, review the storage classes that are deployed by the configuration.

    ![config](images/odf-parameters3.png)

1. On the **Assign to service** tab, select your cluster that you want to assign your configuration to.

    ![config](images/odf-parameters4.png)

1. Click **Complete** to assign your storage configuration.

    > You might face the following error. Just wait a bit.
    >
    > Unable to fetch header secret data. { name: clustersubscription-98ec439b-1021-4b4f-8ae8-1cde95a09898-secret, namespace: razeedeploy, key: razee-api-org-key }: secrets "clustersubscription-98ec439b-1021-4b4f-8ae8-1cde95a09898-secret" is forbidden: User "IAM#xxx.xxx@fr.ibm.com" cannot get resource "secrets" in API group "" in the namespace "razeedeploy"

1. Once the deployment is complete, you should see 2 deployments:

    ![odf](images/odf-complete.png)

## Check the ODF deployment through the CLI

For more detailled descriptions of the following steps look also in the [Satellite Docs](https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-local&interface=cli)

1. Connect to your Satellite Location through the [Cloud Shell](https://cloud.ibm.com/shell).

    ```sh
    ibmcloud target -g Satellite -r us-south
    ```

    ![output](images/ibm-cloud-rg.png)

1. List the Satellite locations to retrieve the  ID of your location.

    ```sh
    ibmcloud sat location ls
    ```

1. List the OpenShift clusters to retrieve the ID of your cluster.

    ```sh
    ibmcloud oc cluster ls --provider satellite
    ```

1. Verify that your cluster has a valid storage configuration has applied. Use the location id and cluster id ***NOT*** the name.

    ```sh
    ibmcloud sat storage assignment  ls --location <location_id> --cluster <cluster_id>
    ```

    ![output](images/odf1.png)

1. You can check the config is being applied to your cluster listing Razee "RemoteResource"

    ```
    oc get rr -n razeedeploy
    NAME                                                       AGE
    clustersubscription-6cd6ea3d-c348-45e2-8048-67e319f4177d   8m24s
    clustersubscription-system-primaryorgkey                   46h
    ```

1. What you also will see that we already have Storage classes deployed, which could be used by ODF. Connect to your cluster and list the storage classes:

    ```sh
    # remove endpoint parameter if you connect via public IPs
    # use endpoint parameter if you connect from cloudshell
    ibmcloud ks cluster config -c <your cluster> --admin --endpoint link
    oc get storageclass
    ```

    ![output](images/odf2.png)

    

1. You can list Persistent volumes to see that ODF hast created "local storage" PVs

    ```
    oc get pv
    NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                           STORAGECLASS                  REASON   AGE
    local-pv-c9518652                          500Gi      RWO            Delete           Bound    openshift-storage/ocs-deviceset-1-data-09fjjv   localblock                             3m35s
    local-pv-e9ba63bd                          500Gi      RWO            Delete           Bound    openshift-storage/ocs-deviceset-2-data-0x8pss   localblock                             3m35s
    local-pv-ed0dd215                          500Gi      RWO            Delete           Bound    openshift-storage/ocs-deviceset-0-data-0ljhbh   localblock                             3m35s
    ```

    

1. Check pods. This is the main pod to check logs if something is not going ok

    ```
    oc get pods -n kube-system | grep ibm-ocs
    ibm-ocs-operator-controller-manager-768c8fd559-5bdl4                           1/1     Running     0          14m
    ```

    ```
    oc get pods -n openshift-storage
    NAME                                                              READY   STATUS      RESTARTS   AGE
    csi-cephfsplugin-9gp2g                                            3/3     Running     0          12m
    csi-cephfsplugin-9vnjq                                            3/3     Running     0          12m
    csi-cephfsplugin-jh4c8                                            3/3     Running     0          12m
    csi-cephfsplugin-provisioner-7b4b8bf596-2jbmh                     6/6     Running     0          12m
    csi-cephfsplugin-provisioner-7b4b8bf596-tnxjd                     6/6     Running     0          12m
    csi-rbdplugin-h8trn                                               3/3     Running     0          12m
    csi-rbdplugin-kl8bv                                               3/3     Running     0          12m
    csi-rbdplugin-l4tqg                                               3/3     Running     0          12m
    csi-rbdplugin-provisioner-5b4b47b7b6-7tsdn                        6/6     Running     0          12m
    csi-rbdplugin-provisioner-5b4b47b7b6-9sqt6                        6/6     Running     0          12m
    noobaa-core-0                                                     1/1     Running     0          9m12s
    noobaa-db-pg-0                                                    1/1     Running     0          9m12s
    noobaa-endpoint-6b45d9d594-dfstc                                  1/1     Running     0          7m50s
    noobaa-operator-7d67f7878b-pdq5t                                  1/1     Running     0          12m
    ocs-metrics-exporter-6867f9f-mgsq2                                1/1     Running     0          12m
    ocs-operator-587cd7cccc-m7skf                                     1/1     Running     0          12m
    odf-console-59bf4b596b-dbv2h                                      1/1     Running     0          13m
    odf-operator-controller-manager-bf669c695-4nkd8                   2/2     Running     0          13m
    rook-ceph-crashcollector-48ecf34a4b4226f88c1d77b0d35976f8-6t662   1/1     Running     0          10m
    rook-ceph-crashcollector-c9ada7e32b0f9df4cc6e97f2d808fd0f-5j7fb   1/1     Running     0          9m55s
    rook-ceph-crashcollector-cb307ac9b5d16a6665e41e0232124206-9q7n6   1/1     Running     0          9m57s
    rook-ceph-mds-ocs-storagecluster-cephfilesystem-a-55b5cc7cnx5f9   2/2     Running     0          9m57s
    rook-ceph-mds-ocs-storagecluster-cephfilesystem-b-798bf47crmh5r   2/2     Running     0          9m56s
    rook-ceph-mgr-a-5545d5d555-9swtf                                  2/2     Running     0          10m
    rook-ceph-mon-a-5f87b86c95-k6jm9                                  2/2     Running     0          11m
    rook-ceph-mon-b-67b65fcb88-25vqv                                  2/2     Running     0          11m
    rook-ceph-mon-c-9bb8d58d4-vz6v7                                   2/2     Running     0          10m
    rook-ceph-operator-78c646489b-ndh5f                               1/1     Running     0          12m
    rook-ceph-osd-0-6d678b6fd8-nfv4c                                  2/2     Running     0          10m
    rook-ceph-osd-1-cd49997bb-jdsql                                   2/2     Running     0          10m
    rook-ceph-osd-2-6575bd8b87-sx2m2                                  2/2     Running     0          10m
    rook-ceph-osd-prepare-ocs-deviceset-0-data-0ljhbh--1-c46lw        0/1     Completed   0          10m
    rook-ceph-osd-prepare-ocs-deviceset-1-data-09fjjv--1-8mbxw        0/1     Completed   0          10m
    rook-ceph-osd-prepare-ocs-deviceset-2-data-0x8pss--1-f5kbl        0/1     Completed   0          10m
    rook-ceph-rgw-ocs-storagecluster-cephobjectstore-a-845874dqwhff   2/2     Running     0          9m54s
    
    ```

1. Check Storage Cluster resource. It is can be in "Error" phase during the deployment.

    ```
    oc get storagecluster -n openshift-storage
    NAME                 AGE   PHASE   EXTERNAL   CREATED AT             VERSION
    ocs-storagecluster   13m   Ready              2022-07-15T10:36:30Z   4.9.0
    
    ```

    

1. Test ODF with a sample pod.

    

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

    

    

## Resources

* [Host storage and attached devices](https://cloud.ibm.com/docs/satellite?topic=satellite-reqs-host-storage)

