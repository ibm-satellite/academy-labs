# Lab cleanup This needs to be completed within 72 hours after completing the academy session.

## Cleanup Demo Environments

1. It is very important to clean-up the demo env as soon as customer
    demo is done, so that cloud spend is controlled and we show to the
    customers of same value.

1. By cleaning the demo env, you allow other IBMers, and business
    partners will be able to use cloud resources to show to their
    clients.

1. Proper cleanup avoids hitting resource limits set by the ITZ
    enterprise account and prevents failures in building more
    environments.

## Demo env Cleanup Procedures

1. Login to IBM Cloud, and go to schematics

    ![img](./images/image25.png)

1. Click on the workspace named with your location name

    ![img](./images/image26.png)

1. Click on the job and from Actions drop down select **Destroy**.

    ![img](./images/image27.png)

1. This destroys resources created by this schematics template

    > NOTE: This may take up to 30mins.

1. Now Go to Satellite location and verify location to be deleted has 0/0 hosts in Host usage column (used/total)

    ![img](./images/image28.png)

1. Click on the location and see if it shows any hosts assigned, if so, remove each host from this location

1. Now from actions drop down Delete the location

    ![img](./images/image29.png)

1. If you get a message like below, go to clusters and delete the cluster

    ![img](./images/image30.png)

1. Remove the worker nodes if exist

    ![img](./images/image31.png)

1. To delete the cluster, go to Resource list and to the right end click on Three Dots and click delete

    ![img](./images/image32.png)

1. Remove the COS Bucket that created by Satellite location.

1. Remove Sysdig instance

1. Remove LogDNA instance.

23. Activity tracker

THANK YOU for being responsible to clean the demo environments and support others to have same experiential learning of IBM Cloud Satellite.