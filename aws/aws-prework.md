# Do It -- Build Demo Environment for Satellite in AWS

> This document is tailored for the Satellite Tech Academy Students.

- [Do It -- Build Demo Environment for Satellite in AWS](#do-it----build-demo-environment-for-satellite-in-aws)
  * [Purpose](#purpose)
  
  * [Overview](#overview)
  
  * [Target audience](#target-audience)
  
  * [Pre-requisites](#pre-requisites)
    + [How to request environment](#how-to-request-environment)
      - [AWS credentials](#aws-credentials)
      - [IBM Cloud Account](#ibm-cloud-account)
    + [Build Satellite env](#build-satellite-env)
      - [Create location in IBM Cloud](#create-location-in-ibm-cloud)
      - [Verify Schematics template is applied](#verify-schematics-template-is-applied)
      - [Verify Satellite location is created](#verify-satellite-location-is-created)
    
  * [Deploy Red Hat OpenShift onto Satellite location](#deploy-red-hat-openshift-onto-satellite-location)
    + [Using IBM Console](#using-ibm-console)
    
## Purpose

This document helps complete pre-requisites for the Satellite Academy
session. Students will perform following steps as pre-reqs

1. Deploy Satellite location using AWS infrastructure

2. Deploy Red Hat OpenShift cluster

## Overview

IBM Cloud Satellite can be deployed anywhere as depicted in this picture; however, this exercise helps you experience it by creating Satellite location in AWS infrastructure. This demo collection provides a fully automated method to deploy Satellite on AWS and deploying Red Hat OpenShift cluster onto that Satellite location. That builds a container platform that is ready for developers to build and run cloud native applications.

This Tech Zone demo collection is specially created for the Satellite Academy and is available here
<https://techzone.ibm.com/collection/cloud-platform-tech-academy-satellite>

## Target audience

IBM Cloud Sellers, Tech Sales, CSM, CSC, Client
Engineering and Business Partners

## Pre-requisites

To experience Satellite using AWS infrastructure, access to both AWS and IBM Cloud environment is needed.

The IBM Cloud environment is used to create Satellite location, the management side of the service, and from where you will start the creation / deployment of any satellite-enabled service 

The AWS environment is used as IaaS, is where you will provision VPC network, EC2 instances (compute) and storage infrastructure required to deploy the Satellite location and where the satellite-enabled services will work. 

Here is the demo environment that needs to be built.

![Architecture](./images/image1.png)

### How to request environment

#### AWS credentials

There is a Tech Zone demo collection specially created for the Satellite Academy and is available here
<https://techzone.ibm.com/collection/cloud-platform-tech-academy-satellite>

Create the AWS environment, in TechZone in this demo collection, in environment section, click on resource named '***Request AWS Credentials'*** to obtain AWS API credentials to use compute and storage.

![AWS Request](./images/aws-request.png)

Once the AWS environment is created an email will be sent by TechZone confirming access to AWS with required credentials. 

You can also verify status of your request for the environment, in Techzone portal go to My Library and click on My Reservations
<https://techzone.ibm.com/my/reservations>

You will see your request

![AWS Reservation](./images/aws-reservation.png)

If you click on it you will see your credentials:

![AWS Credentials](./images/aws-credentials.png)

#### IBM Cloud Account

The IBM Cloud environment is pre-assigned to each Academy student using temporary IBM Cloud account provisioned in an Enterprise Account owned by TechZone. You will get an email with an invitation to join this special IBM cloud account. IBM Cloud account will look like this with last two digits being different for each Student Ex "tztsglenablementxx" (expands to something like... TechZone Tech Sales Global Enablement xx)

## Build Satellite env
### Create location in IBM Cloud

1. Go to <https://cloud.ibm.com/> and login using w3 id

2. Make sure to switch to Demo account provided by IBM TechZone (ITZ) by clicking on the drop-down menu on your name and select TechZone Account.

![IBM Cloud Account](./images/ibmcloud-account.png)

3. Go to the left navigation menu, on top left corner to the left of IBM Cloud and the click on Satellite and "Create a Satellite location"

![image-20220610102752070](./images/satellite-menu.png)

![image-20220610102833033](./images/sat-location-create.png)

4. Click on the tile named AWS Quick Start to use AWS infrastructure

   ![aws-quick-start-template](./images/aws-quick.png)

5. Under AWS Credentials, copy paste the AWS access key ID and AWS secret access key, received from ITZ, and click the button on Fetch Options from AWS

![aws-credentials](./images/aws-input-credentials.png)

![aws-fetched](./images/aws-fetched.png)

6. Change the host profile selected for the AWS EC2 instances of the Service 

   ![aws-large](./images/aws-m5d.4xlarge.png)

   In later labs we will configure ODF on the worker nodes so we are going to select a size that fits with ODF requirements.

   Click on "Done Editing"

   ![aws-done](./images/aws-done.png)
   

7. Click Edit on Satellite Location

   Give the location a meaningful name:

   ![location-name](./images/locationname.png)

   Change the name of the Satellite location and select the Resource Group "academyrg"

   ![lab-rg](./images/lab-rg.png)

   Location will be managed from Washington DC. (east-us)

   ![aws-zones](./images/aws-zones.png)

   Click "Done Editing"

    ![aws-done](./images/aws-done.png)

8. Create COS Instance if you see the warning that no COS Instance exist:
![](images/aws-cos-create-loc.png)
![](images/aws-cos-location-instance.png)
Return to the create location Screen and Refresh the Object Storage Selection:
![](images/20220707092245.png)
Leave the bucket name blank it will be auto generated later:
![](images/20220707092407.png)  

9. Create Location

   ![create-location](./images/create-location.png)

IaaS and Satellite location creation will take like 30 mins, but after this it is also assigned three hosts as control planes, this assignment takes like 1h.



## Verify Satellite location is created

### Verify Schematics template is applied

1. Go to schematics and look for workspace by the name of the satellite location

    ![goto-schematics](./images/goto-schematics.png)	

2. Click on the workspace and job

    ![schematics-wsp](./images/schematics-wsp.png)

    ![job](./images/job.png)

3. Wait until it is applied successfully (30 mins)

    In case of errors with schematics try to take a look to the logs and then try to restart the template, you can try the combination of "Generate plan" and "Apply plan"

    

    If it does not work then destroy the resources: "Actions -> Destroy"

    

    Go to the location and remove all hosts if any was attached:

    ![image-20220611092910593](./images/image-remove-hosts.png)

    

    And then in the schematics workspace again "Generate plan" and "Apply plan"

    ![image-20220611092715987](./images/tf-apply.png)

    

5. Click on Resources to see what resources the schematics template has created automatically

    ![tf-resources](./images/tf-resources.png)

If you want to see the schematics job logs, the terraform template used to create the locations, hosts, AWS IaaS, attach and assign control plane hosts is located here:

https://github.com/terraform-ibm-modules/terraform-ibm-satellite/releases/download/v1.1.7/aws-v1.1.7.tgz

If you are familiar with terraform and not with schematics you can always download the terraform and use it locally... In this case take a look to the Setting section of the schematics workspace to see the variables values.

### Verify Satellite location is created

1. Go to the left navigation menu, on top left corner to the left of IBM Cloud and the click on Satellite Locations

   ![nav-locations](./images/nav-locations.png)
   
2. Click on the location that was created and is in Normal state

   ![sat-normal-state](./images/sat-normal-state.png)

It will be in "Action Required" for like 1h while the control planes are assigned, deployed and configured.

![image](./images/R0023.png)


3. On the Overview page you see most relevant information of your location.

   ![location-overview](./images/location-overview.png)


4. On left side click on Hosts to show the hosts attached to the location and hosts available for ROKS cluster

![aws-infra](./images/aws-infra.png)

## Deploy Red Hat OpenShift onto Satellite location

### Using IBM Console

1. Go to the left navigation menu, on top left corner to the left of IBM Cloud and Select OpenShift then Clusters

    ![OpenShift Clusters](./images/image5.png)

2. click on Create Cluster

    ![Create Cluster](./images/image6.png)

3. Here I see Satellite as another Infrastructure choice for me to deploy Red Hat OpenShift. Choose Satellite as my Infrastructure of choice

    ![image-20220610104519447](./images/create-cluster.png)
    
4. Now I see all the Satellite locations including my on-prem locations or other clouds. In the name column, select the radio button for the Satellite location you just created and also select the Resource Group

    ![image-20220610104706741](./images/create-cluster-rg.png)
    ![image-20220610104706741](./images/create-cluster-location.png)
  
5. Select the zones and the hardware requirement for the available hosts in the location. These values are used as "Selectors", when we start the creation of the cluster it will look for hosts with labels "cpu=4", "memory=16" and "zone=us-east-1 / 2 / 3" attached and available in the location and will start the deployment of ROKS on them. You can also start the deployment manually from the Satellite location page. 

    In our case the hosts are 16 vCPU and 64 GB, that's why the message:

    ![image-20220611093442095](./images/cluster-host-message.png)

    Click on "Get values from available hosts"

    ![image-20220611093354529](./images/cluster-host-values-1.png)

    

    ![image-20220611093354529](./images/cluster-host-values-2.png)

    

    ![image-20220611093354529](./images/cluster-host-values-3.png)

6. Select the version

    ![image-20220610105818844](./images/roks-version.png)

7. Configure OCP Entitlement

    ![image-20220610110104850](./images/roks-entitlement.png)

    Depending on the account and the user logged in you will see these options for OCP entitlement, select "Purchase additional licenses for this cluster"

    In case customer wants to use "Bring your own license" select the second option and copy the RedHat "pull secret"

8. Check the box "Enable Cluster admin access to Satellite Config to manage K8S resources in this clusters and then submit the deployment by hitting the Create.

    ![image-20220610110501962](./images/cluster-config-access.png)
   
9. Select a name

    ![image-20220610111144185](./images/roks-name.png)

10. Click on the Create button on right highlighted in Blue

    ![image-20220610111209087](./images/roks-create.png)
  
11. You can check the cluster status

     ![image-20220610111739277](./images/roks-creation-2.png)

     ![image-20220610111739277](./images/roks-creation-1.png)

     After 30 mins

     ![image-20220610152142748](./images/roks-ok.png)

     The "Unknown" status for ingress is because currently the ROKS Cluster is only accessible using AWS private IPs, in next sections we will change this.
