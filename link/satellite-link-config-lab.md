## Overview
When ROKS Cluster is running in a Satellite location in a private network to which a VPN connection is needed to the private Network to access OpenShift Console. There could be situations, where sich a VPN is not avaiable or time consuming, but Satellite deployment  needs to progress deliver value to customer. When such VPN connection to private network is is not accessible, this method can be used as a short term access to continue deployment of Satellite, workloads and management of the cluster or applications. 
This methd allows access OpenShift console in private Networ from IBM Cloud bover Satellite Link established while creating a Satellite location, by provisioning a test windows VM in IBM Cloud.

NOTE: Customer has full ability to turn off this method any time by dosabling the Link endpoints that are created as part of this method.

## Prepare Test machine in IBM Cloud
1.	Provision a Windows server to test this method in a VPC, make sure to create and attach an SSH key to the instance
2.	From your workstation login to IBM Cloud
3.	Find out instance id using ibmcloud is instances|grep <your VSI name>
4.	Get Instance details using ibmcloud is instance <instance id in the first column>
5.	Initialize to get password using ibmcloud is in-init <instance name> --private-key @<your SSh keys attached to the instance>
6.	Note the password for user administrator above command generates and store it to login to windows server
7.	Install Windows Remote Desktop app into your workstation
8.	Now open RDP session to test windows server, and login as administrator with password provided in above step
9.	Make sure to install Firefox browser
10.	Install extension for Proxy OmegaSwitch for Firefox from https://addons.mozilla.org/en-US/firefox/addon/switchyomega/

## Prepare your workstation
## Downloading the IBM Cloud CLI on hosts in your Satellite Location by using Satellite Link

This example walks you through creating a Satellite Link Endpoint which you can use to download the IBM Cloud CLI into your Satellite location.

## Preparing Proxy Configuration
1.	Download the [sample .pac file](./OmegaProfile_proxy.pac)
2.	Replace highlighted values, as in picture below, for 1 and 2 with target env values. First one for Satellite location
![access-ocp-console-image](./Access-OCP-Console-Image.jpg)
3. Go to Firefox settings and use the updated .pac proxy config file for the target env
    
### Lab Steps
1. Navigate to your [Satellite Locations console](https://cloud.ibm.com/satellite/locations/) and select your location. 
2. Click **Link endpoints** > **Create an endpoint**.

2. On the **Destination resource** tab, select **Cloud** and click **Next**.
![Cloud Destination Resource](.pastes/cloud_destination_resource.png)


3. On the **Resource details** tab, enter `download-clis-cloud-ibm-com` as the **Endpoint name**. In the **Destination address** field, enter `download.clis.cloud.ibm.com` and in the **Port** field, enter `443`.
![CLIs link endpoint](.pastes/clis_cloud_ibm_com_endpoint.png)

4. On the **Protocol** tab, select **HTTPS** as the source protocol and check the **Verify destination certificate** check-box and click **Next**.
![Link Endpoint Metadata](.pastes/clis_linkendpoint_protocol_metadata.png)

5. On the **Connection settings** tab, keep the default inactivity timeout of `60` , and click **Create endpoint**
![Create Endpoint](.pastes/create_cli_link_endpoint.png)

6. After creating the endpoint, you are redirected to the **Link endpoints** page. Click the `download-clis-cloud-ibm-com` endpoint that you just created and view the details.
![Find Details](.pastes/find_link_endpoint_details.png)

7. On the **Endpoint details** page, make a note of the **Endpoint address**. You can click the copy button to copy the address.
![Find Location Endpoint](.pastes/find_location_endpoint.png)

8. Log-in to IBM Cloud and target the region and resource group where your Satellite location and cluster are located. 
    ```sh
    ibmcloud login
    ```
    
    ```sh
    ibmcloud target -g GROUP -r REGION
    ```

9. List your clusters, make a note of the cluster ID of your Satellite cluster, then download the `kubeconfig`.
    ```sh
    ibmcloud ks cluster ls
    ```
    
    ```
    ibmcloud ks cluster config --cluster CLUSTERID --admin
    ```

10. Log-in to the `openshift-console` pod and download the IBM Cloud CLI Installer script by using the Link endpoint that you created earlier.
    ```sh
    kubectl exec -it -n openshift-console  deploy/console bash
    ```

12. Curl the Link endpoint that you created earlier to download the IBM Cloud CLI Installer script into your Location.
    ```
    bash-4.4$ curl https://ENDPOINT_ADDRESS/ibm-cloud-cli-installer-scripts/linux
    #!/bin/sh
    host="download.clis.cloud.ibm.com"
    metadata_host="$host/ibm-cloud-cli-metadata"
    binary_download_host="$host/ibm-cloud-cli"
    ...
    ```

     Example commands.
    ```
    ibmcloud ks cluster config --cluster canqs7tl0hrf12canr8g --admin
    OK
    The configuration for canqs7tl0hrf12canr8g was downloaded successfully.

    kubectl exec -it -n openshift-console  deploy/console bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    bash-4.4$ curl https://t471ec4b40dc029fdb318-6b64a6ccc9c596bf59a86625d8fa2202-c000.eu-gb.satellite.appdomain.cloud:31545/ibm-cloud-cli-installer-scripts/linux
    #!/bin/sh
      
    host="download.clis.cloud.ibm.com"
    metadata_host="$host/ibm-cloud-cli-metadata"
    binary_download_host="$host/ibm-cloud-cli"
    ...
    ```

9. Verify traffic has been sent over the endpoint by looking at **Data rate** panel on the **Endpoint details** page.
![Data Rate](.pastes/data_rate.png)

13. On the **Endpoint details** page, click the **Actions** menu and select **Disable** to disable the endpoint. 
![Disable endpoint](.pastes/disable_endpoint.png)

11) Test that the endpoint is disabled by logging back into the console pod and attempting to download the IBM Cloud CLI Installer script from the Link endpoint.
    ```
    kubectl exec -it -n openshift-console  deploy/console bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    bash-4.4$ curl https://ENDPOINTADDRESS/ibm-cloud-cli-installer-scripts/linux
    curl: (7) Failed to connect to ENDPOINTHOST port ENDPOINTPORT: Connection refused
    ```

    Example commands.

    ```
    kubectl exec -it -n openshift-console  deploy/console bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    bash-4.4$ curl https://t471ec4b40dc029fdb318-6b64a6ccc9c596bf59a86625d8fa2202-c000.eu-gb.satellite.appdomain.cloud:31545/ibm-cloud-cli-installer-scripts/linux
    curl: (7) Failed to connect to t471ec4b40dc029fdb318-6b64a6ccc9c596bf59a86625d8fa2202-c000.eu-gb.satellite.appdomain.cloud port 31545: Connection refused
    ```

12. In the **Actions** menu on the **Endpoint details** page, re-enable the endpoint.
![Enable Endpoint](.pastes/enable_endpoint.png)

13) Exec into the console pod again and verify that the IBM Cloud CLI Installer script can be downloaded from the link endpoint
    ```
    kubectl exec -it -n openshift-console  deploy/console bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    bash-4.4$ curl https://ENDPOINTADDRESS/ibm-cloud-cli-installer-scripts/linux
    #!/bin/sh

    host="download.clis.cloud.ibm.com"
    metadata_host="$host/ibm-cloud-cli-metadata"
    binary_download_host="$host/ibm-cloud-cli"
    ...
    ```

    Example commands.

    ```
    kubectl exec -it -n openshift-console  deploy/console bash
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    bash-4.4$ curl https://t471ec4b40dc029fdb318-6b64a6ccc9c596bf59a86625d8fa2202-c000.eu-gb.satellite.appdomain.cloud:31545/ibm-cloud-cli-installer-scripts/linux
    #!/bin/sh

    host="download.clis.cloud.ibm.com"
    metadata_host="$host/ibm-cloud-cli-metadata"
    binary_download_host="$host/ibm-cloud-cli"
    ...
    ```

14. Delete the endpoint
![Delete endpoint](.pastes/delete-endpoint.png)

## Troubleshooting
1.	If you still face errors edit /etc/hosts on this test machine and add following line
2.	Below IP is one of the public ips of Satellite location control plane host
3.	<ip address>	i10c37a0d32a841019b1e-6b64a6ccc9c596bf59a86625d8fa2202-ce00.us-east.satellite.appdomain.cloud

Amazing Work! This concludes the lab exercise.

Authors: Tyler Lisowski and Derek Poindexter
