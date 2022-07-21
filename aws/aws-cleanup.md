# Cleanup AWS Resources

## 1. Delete your Openshift Satellite Cluster

![clean](images/clean-1.png)

## 2. Find your AWS VPC ID from Schematics

Search for a string of your VPC Id in the Schematics Logs of the Terraform logs:
search for **"id=vpc"** and note the id there is only one place in the log with the string.

![clean](images/clean2.png)

![clean](images/clean3.png)

## 3. Destroy the environment using Schematics

![clean](images/clean4.png)

Wait until finished (10 minutes)

## 4. Destroy leftover resources with AWS CLI

Find Instance Ids of your ec2 Instances not created via Terraform using the VPC ID from step 2.

```shell
aws ec2 describe-instances   --filters Name=vpc-id,Values=<vpc-id>  --query 'Reservations[].Instances[].InstanceId' --output text
```

![clean](images/clean5.png)

This will output the Ids of leftover EC2 instances.

Terminate the instances

```shell
   aws ec2 terminate-instances --instance-ids <id> <id>
```

![clean](images/clean6.png)  

## 5. Destroy Satellite location

![clean](images/clean7.png)
