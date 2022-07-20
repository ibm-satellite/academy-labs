# Access OpenShift Console via public Internet

Satellite location is registered with DNS using private IP addresses of the hosts assigned to control plane.

For the purposes of the demo register public IP addresses of control plane hosts for the location to be publicly accessible.

![image-20220611092910593](./images/image-remove-hosts.png)

## Assign Public IPs from AWS EC2 Instances to Control Plane DNS and NLB of ROKS Cluster

1. Download the aws cli from <https://aws.amazon.com/cli/>

1. To login into your aws account use the below command on your terminal

    ```sh
    aws configure
    ```

    Fill in the details:
    * AWS Access Key ID: **************
    * AWS Secret Access Key: **************
    * Default region name: `us-east-1`
    * Default output format: `json`

1. Now we need to identify the public ips of our hosts running on ec2 instances

1. To list all the ec2 instances in the aws account use

    ```sh
    aws ec2 describe-instances
    ```

1. This might have a huge list depending on the environment used.

1. Easier way to identify your hosts is copy the output in a file (e.g. ec2.txt) and search manually

    ```sh
    aws ec2 describe-instances > ec2.txt
    ```

1. This would save the output in the ec2.txt file, now search your relevant hosts through hostname or private Ips to identify their respective public IP's

1. As alternative you could use jq CLI to process the aws CLI output.

   Install [jq CLI json processor](https://github.com/stedolan/jq/wiki)

   [jq cheat sheet](https://lzone.de/cheat-sheet/jq)

   ```sh
   aws ec2 describe-instances | jq '.Reservations[].Instances[] | select (.PrivateIpAddress=="10.0.1.240") | {PrivateIpAddress,PublicIpAddress,SecurityGroups,SubnetId,ImageId,InstanceType,Placement}'
   ```

   ![jq](images/aws-cli-jq.png)

1. Write down all public IPs of Control Plane and Worker Nodes for the next steps.

## Apply Public Ips to Satellite location and ROKS cluster in IBM Cloud

1. Login to IBM Cloud using the ibmcloud cli and target your ITZ Account

    ```shell
    ibmcloud login --sso
    ibmcloud target -g academyrg
    ```

1. Review the location subdomains and check the Records for the private IP addresses of the hosts that are registered in the DNS for the subdomain.

    ```sh
    ibmcloud sat location ls
    ibmcloud sat location dns ls --location <location_name_or_ID>
    ```

1. Update the location subdomain DNS records with the 3 public IP addresses of each host in the control plane

    ```sh
    ibmcloud sat location dns register --location <location_name_or_ID> --ip <host_IP> --ip <host_IP> --ip <host_IP>
    ```

1. Verify that the public IP addresses are registered with your location DNS records.

    ```sh
    ibmcloud sat location dns ls --location <location_name_or_ID>
    ```

1. Get the Hostname for your cluster in the format

    ```sh
    ibmcloud oc clusters
    ibmcloud oc nlb-dns ls --cluster <cluster_name_or_ID>
    ```

1. Add the public IP addresses of the hosts that are assigned as worker nodes to this cluster to your cluster's subdomain. Repeat this command for each host's public IP address.

    ```sh
    ibmcloud oc nlb-dns add --ip <public_IP> --cluster <cluster_name_or_ID> --nlb-host <hostname>
    ```

1. Remove the private IP addresses from your cluster's subdomain. Repeat this command for all private IP addresses that you retrieved
    earlier.

    ```sh
    ibmcloud oc nlb-dns rm classic  --cluster <cluster_name_or_ID> --nlb-host <hostname> --ip <private_IP>
    ```

1. Verify that the public IP addresses are registered with your cluster subdomain.

    ```sh
    ibmcloud oc nlb-dns ls --cluster <cluster_name_or_ID>
    ```

1. Wait a couple of minutes until the DNS changes are applied and verify that you can access the OpenShift Console from the Cloud Console:

    ![](images/20220707113530.png)

1. For Troubleshooting use nslookup on your Sat and OpenShift Domains:

    ```shell
    ibmcloud sat location dns ls --location <your location>

    nslookup <satlocation hostnames> 

    ibmcloud oc nlb-dns ls --cluster <cluster_name_or_ID>

    nslookup <oc nlb-dns domain>
    ```
