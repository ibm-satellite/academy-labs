# Replace Control Plane

In this lab, we will replace an host attached to the control plane and add a new worker to ROKS.

## Table of contents

- [Replace Control plane](#replace-control-plane)
  - [Remove existing host](#remove-existing-host)
  - [Assign a new host as Control Plane](#assign-a-new-host-as-control-plane)
- [Add new worker to ROKS](#add-new-worker-to-roks)
- [Fix public IP Assignment for Control Plane and ROKS](#Fix-public-IP-Assignment-for-Control-Plane-and-ROKS)

## Replace Control plane

### Remove existing host

It is important to learn that Control Planes must **never** be removed all together, you have to replace one by one waiting between them, this is because in the Control Plane nodes is where kubernetes ETCD database resides, so if you remove more than one at the same time the ETCD will stop working and you will have to ask via IBM ticket to restore a backup. (once you have three control planes ready again)

We will remove a control plane in the same zone where we attached the new hosts. **Please note that the names of the nodes/zones in the screenshots might differ, depending on your environment! Also you need to update DNS of Sat Control Plane and ROKS NLB DNS entries afterwards**  

The new host we attached is on eastus-1

![image-20220616190030045](images/image-20220616190030045.png)

1. So remove the control plane from eastus-1 (not the Unassigned node)

    ![image-20220706234359292](.pastes/image-20220706234359292.png)

1. After some minutes the Location state will switch to warning.

    ![image-20220616190314621](images/image-20220616190314621.png)

1. Going over the Information icon, you will see this messages, R0012 will be the final one.

    > R0047: IBM Cloud is unable to use the health check endpoint to check the location's health. For more information, see 'https://ibm.biz/satloc-ts-healthcheck'. For more information, see the [docs](https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug).
    >
    > R0043: The location does not meet the following requirement: Hosts must have TCP/UDP/ICMP Layer 3 connectivity for all ports across hosts https://ibm.biz/sat-loc-debug#R0043. If you still have issues, contact IBM Cloud Support and include your Satellite location ID.
    >
    > R0012: The location control plane does not have hosts in all 3 zones.  Add available hosts to your location for the control plane. For more information, see the [docs](https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug).

1. Check the status of the location with the CLI

    ```sh
    ibmcloud sat location get --location <location-name>
    ```

    Output:

    ```sh
    ID:                             cahrvp4w07i0nklqkbpg
    ...
    State:                          action required
    Ready for deployments:          no
    Message:                        R0012: The location control plane does not have hosts in all 3 zones. Add available hosts to your location for the control plane.
    ```

### Assign a new host as Control Plane

![image-20220616133314527](images/image-20220616133314527.png)

![image-20220616133329869](images/image-20220616133329869.png)

Refresh

![image-20220616133358106](images/image-20220616133358106.png)

It takes like 30 mins

Normal "on-going states" even if the control plane is Assigned and normal

![image-20220616134343332](images/image-20220616134343332.png)

https://cloud.ibm.com/docs/satellite?topic=satellite-ts-locations-debug#R0012

> If you just assigned hosts to the control plane, wait a while for the bootstrapping process to complete. Otherwise, assign at least one host to each of the three zones for the location itself, to run control plane operations.

Finally...

![image-20220616134937985](images/image-20220616134937985.png)

## Add new worker to ROKS

Review the vCPU, Memory and Zone of the worker you attached, in this case it was:

![image-20220616183950015](images/image-20220616183950015.png)

So 16vCPU, 64GB and zone "eastus-1" so we will configure the new worker to enable "auto-assign" to work properly. If not we can always assign the node to the worker pool using the satellite hosts UI as we did with the Control Plane.

Go to ROKS worker pools

![image-20220616135406902](images/image-20220616135406902.png)

Deploy only 1 Worker.

![image-20220616140205405](images/image-20220616140205405.png)

Check in the location that the "Unassigned" node is now "Assigned" to our cluster, give it like 10 minutes

![image-20220616140311959](images/image-20220616140311959.png)

## Fix public IP Assignment for Control Plane

Do this lab once the control plane has been successfully assigned and the location status is green again.

Because we have now changed the Hosts in the Satellite Control Plane we need to update the Sattelite DNS. Please follow the steps for the Control Plane only:

- For Azure: [Reset public IPs](azure/AcademyLabs.md#lab4---remove-and-replace-an-existinghost---control-plane)
- For AWS: [Public IPs](../../aws/aws-access-roks-inet.md)
