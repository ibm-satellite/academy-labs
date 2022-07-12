# Prepare your workstation to use Cloud CLIs

## IBM Cloud CLI

1. Download IBM Cloud CLI from [here](https://github.com/IBM-Cloud/ibm-cloud-cli-release)

1. Install plugins from [here](https://cloud.ibm.com/docs/cli?topic=cli-install-devtools-manually)

1. Install private endpoints from [here](https://cloud.ibm.com/docs/cli?topic=cli-cli-private-endpoints)

## AWS CLI

1. Download the aws cli from https://aws.amazon.com/cli/

1. To login into your AWS account use the below command on your terminal

    ```sh
    aws configure
    ```

1. Fill in the details

    * AWS Access Key ID: **************
    * AWS Secret Access Key: **************
    * Default region name: us-east-2
    * Default output format: json

## Azure CLI

1. Download AZ CLI from
https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux

1. To login into your Azure account from CLI, use the Azure credentials received by mail or gathered from Tech Zone web:

    * `clientid` in place of app_id after -u
    * `clientSecret` for password-or-secret after -p
    * `tenantId` for tenant

    ```sh
    az login --service-principal -u 58d21686-2688-426f-892e-c7aabed76a51 -p xxx --tenant 4e7730a0-17bb-4dfa-8dad-7c54d3e761b7
    ```
