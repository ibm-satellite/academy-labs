# Event Streams - WORK IN PROGRESS, NOT READY FOR USE...Doug Beauchene  dougbeau@us.ibm.com

## Introduction
IBM® Event Streams for IBM Cloud® is a high-throughput message bus that is built with Apache Kafka.

To get started with Event Streams and start sending and receiving messages, you can use the Java™ sample.  This lab will walk through deploying the sample program and running it using a preprovisioned Event Streams service instance.

The sample program shows how a producer sends messages to a consumer by using a topic. The same sample program is used to consume messages and produce messages.  See the [References](#reference-information--links) section for additional information on the sample program.

The lab will also explore using the Event Streams REST API and ibmcloud CLI plugin.  An instance of IBM Cloud Monitoring has also been provisioned that will allow you to see the sample programs activity

In the sections below...
- Review the single instance of Event Streams deployed to a Satellite location used by all students
- You will SSH into a virtual server instance running in the same virtual private cloud as the Satellite location/Event Streams deployment
- The required tools for building the sample program will be installed on your virtual server instance
- You will build the sample program in your virtual server instance
- Using two virtual server instance sessions...
  - one session will produce messages to a unique topic in the Event Streams instance
  - the other session will consume messages from that topic
- You will use the Event Streams REST API to retrieve a list of topics
- You will install and run the Event Streams `ibmcloud es` CLI plugin
- You can see the sample program's activity in Monitoring
- Optionally update the sample program to send more data and/or use a different default topic


## Review deployed environment

1. Resource list
   | Type | Name | Location |
   | --- | --- | --- |
   | Satellite | `academy-instructor-lab` | Washington DC |
   | Services... | `academy-instructor-eventstreams` | academy-instructor-lab |

   ![resourcelist](images/resourcelist.png)
1. Event Streams service instance specifics in the satellite location
   - Hosts
     | Item | Value | Description |
     | --- | --- | --- |
     | Cluster | `mh-sat-....` | ROKS cluster behind the service instance, the cluster is in the Event Streams service account |
     | Worker pool | `edge, management, data` | 3 Worker pools created during Event Streams provision |

     ![satlochosts](images/satlochosts.png)
   - Services
     | Item | Value | Description |
     | --- | --- | --- |
     | Service | `messagehub` | architected name of the Event Streams service, `Event Streams` used be `MessageHub` |
     | Cluster name | `mh-sat-...` | ROKS cluster behind the service instance, the cluster is in the Event Streams service account |
     | Storage config | `instructor-lab-es-vpc-block` | ustomer created VPC storage config in the sat location that Event Streams will use to provision required block storage |

     ![satlocservices](images/satlocservices.png)
   - Link endpoints
     | Item | Value | Description |
     | --- | --- | --- |
     | xxxxx | `yyyyyy` | zzzzzzzzzzzzzzzzzzzzzzzzzzz |

     ![satlocendpoints](images/satlocendpoints.png)
   - Storage
     | Item | Value | Description |
     | --- | --- | --- |
     | xxxxx | `yyyyyy` | zzzzzzzzzzzzzzzzzzzzzzzzzzz |

     ![satlocstorage](images/satlocstorage.png)
1. Event Streams service instance Service credentials

   Later in the lab, we will use elements of the service credentials for the sample program and REST API.  Actual values will be provided to you.
   | Item | Description |
   | --- | --- |
   | apikey | API Key used to authorize access |
   | kafka_brokers_sasl | List of kafka brokers in the Event Streams cluster the sample program will use to send/receive messages |
   | kafka_http_url | URL used for the Event Streams REST API |

   **Note**:  `dougbeau-temporary-credentials` below was temporarily created for the screenshot example only, the credential has been deleted
   ![escredsgui](images/escredsgui.png)
1. VPC Infrastructure security group

   The security group assigned to the Event Streams cluster VPC instances needs inbound ports enabled/disabled
   | Action | Protocol | Port range | Source type | Description |
   | --- | --- | --- | --- | --- |
   | Enabled | TCP | 9093 - 9093 | Any | Kafka brokers listen on port 9093 |
   | Enabled | TCP | 9093 - 9093 | Any | Kafka admin/http listen on port 443 |
   | **Disabled** | TCP | 22 - 22 | Any | SSH access |

   We disable (remove) any inbound rule for port 22 so no SSH connection/login attempts can be made to the Event Streams hosts.  The security tooling will detect these attempts, IBM Security Operations Center will be notified, SOC will page Event Streams operations support to investigate.  It should also be noted that ROKS disables the root SSH user on the cluster.

   ![vpcsecgrpinbound](images/vpcsecgrpinbound.png)


## Set up tools for building the Event Streams sample program
1. Provision a service instance in the same virtual private cloud "dougbeau-pers-vpc", and assign public IP address so we can SSH into it
1. ssh -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers root@169.48.155.250
1. Install dev tools
   1. yum install git                            1.8.3.1-23.el7_8
   1. yum install java                           1:1.8.0.7.10-1jpp.1.el7
   1. yum install java-1.8.0-openjdk-devel
   1. gradle --> https://gradle.org/install/
      1. scp -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers /home/doug/Downloads/gradle-7.4.2-bin.zip root@169.48.155.250:/tmp/gradle-7.4.2-bin.zip
      1. ssh -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers root@169.48.155.250
      1. mkdir /opt/gradle
      1. unzip -d /opt/gradle /tmp/gradle-7.4.2-bin.zip
      1. ls /opt/gradle/gradle-7.4.2
      1. /opt/gradle/gradle-7.4.2/bin/gradle -version
      1. export PATH=$PATH:/opt/gradle/gradle-7.4.2/bin
      1. gradle -v

## Build the sample program
1. Build sample app
   1. https://github.com/ibm-messaging/event-streams-samples/blob/master/kafka-java-console-sample/docs/Local.md
   1. ssh -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers root@169.48.155.250
   1. cd /
   1. git clone https://github.com/ibm-messaging/event-streams-samples.git
   1. cd /event-streams-samples/kafka-java-console-sample
   1. gradle clean
   1. gradle build

## Start the sample program
1. Consuming app
   1. ssh -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers root@169.48.155.250
   1. cd /event-streams-samples/kafka-java-console-sample
   1. java -jar ./build/libs/kafka-java-console-sample-2.0.jar kafka-2.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093,kafka-0.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093,kafka-1.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093 1C86nlALK1jxpqQblYZ20UxYZNXXjQaYe41H_SwEdVrc -topic student-abc -consumer
1. Producing app
   1. ssh -i /home/doug/Desktop/Satellite/Tech-Academy-Education/dougbeau_pers root@169.48.155.250
   1. cd /event-streams-samples/kafka-java-console-sample
   1. java -jar ./build/libs/kafka-java-console-sample-2.0.jar kafka-2.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093,kafka-0.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093,kafka-1.mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com:9093 1C86nlALK1jxpqQblYZ20UxYZNXXjQaYe41H_SwEdVrc -topic student-abc -producer

## Using the Event Streams REST API
1. Get list of topics using Admin API
   1. Requires security group inbound rule that allows port 443
   1. curl -i -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' -u token:1C86nlALK1jxpqQblYZ20UxYZNXXjQaYe41H_SwEdVrc https://mh-sat-xtpgnbtywyksbrpp.c88plk8d0q2jcqk3hglg.eventstreams.cloud.ibm.com/admin/topics

## Using the Event Streams ibmcloud CLI plugin
1. Event Streams CLI plugin
   1. curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
   1. ibmcloud plugin install event-streams
   1. ibmcloud login -a cloud.ibm.com --sso
   1. ibmcloud resource service-instances
      ```
      Name:      Event-Streams-Sat-Dallas
      Location:  satloc_dal_c88plk8d0q2jcqk3hglg
      ```
   1. ibmcloud es init --instance-name Event-Streams-Sat-Dallas
      ```
      API Endpoint:		https://c88plk8d0q2jcqk3hglg-gpooy.private.us-south.link.satellite.cloud.ibm.com
      Service endpoints:	public
      Sorage size:		2048 GB
      Throughput:		150 MB/s
      ```
   1. ibmcloud es topics
      ```    
      Topic name   
      __consumer_offsets   
      dougbeau-new-topic   
      kafka-java-console-sample-topic
      ```

## Using monitoring to see activity created by sample application
1. Monitoring
   1. https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-metrics
   1. Opt in and Enabling default Event Streams metrics
   1. Enabling enhanced Event Streams metrics

## Optional:  Update the sample app's default message data / topic name
1. To edit/rebuild the sample 
    1. vim ...to edit the source files
    1. cd /event-streams-samples/event-streams-samples/kafka-java-console-sample
    1. gradle clean
    1. gradle build
1. Change size of the test message data
    1. /event-streams-samples/kafka-java-console-sample/src/main/java/com/eventstreams/samples/ProducerRunnable.java
    1. Line 73
    1. String message = "{\"message\":\"This is a test message #\",\"message_number\":" + producedMessages + "}";
    1. change the text, size of the message variable
    1. for example
        ```
        String extraMessage = "abcdefghijabcdefghij";
        String message = "{\"message\":\"This is a bigger test message... #\"" + extraMessage + ",\"message_number\":" + producedMessages + "}";
        ```
    1. rebuild the sample app 
1. Change the name of the default topic that is used by the sample app
    1. /event-streams-samples/kafka-java-console-sample/src/main/java/com/eventstreams/samples/EventStreamsConsoleSample.java
    1. Line #57
        ```
        private static final String DEFAULT_TOPIC_NAME = "kafka-java-console-sample-topic";
        ```
    1. change the name of the default topic that is created by the sample
    1. rebuild the sample app
    1. run the sample but do not specify the -consumer and -producer parameters

## Reference information / links
The Java sample program is available from multiple locations
- [Getting started with IBM Event Streams for IBM Cloud](https://cloud.ibm.com/docs/EventStreams?topic=EventStreams-getting-started)
- [event-streams-samples](https://github.com/ibm-messaging/event-streams-samples)
- within the provisioned service instance in the IBM Cloud console
  ![samplepgm](images/samplepgm.png)



XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


# Install Openshift Data Foundation on Satellite based ROKS Clusters on AWS using EBS volumes

## Introduction

We would like to deploy OpenShift Data Foundation Add-on to our Satellite based OpenShift Cluster on AWS using EBS volumes. The procedure contains the following major steps

* Configuration of a AWS EBS storage configuration for our location and assign to our ROKS Cluster
* Deploy ODF using Sattellite ODF storage configuration referencing AWS Storage class

## Configure AWS EBS storage configuration in Satellite

1. From the Satellite locations dashboard, select the location where you want to create a storage configuration.

1. Select Storage > Create storage configuration

   ![config](images/ebs1.png)

1. Enter a name for your configuration. Select the Storage type that you want to use to create your configuration and the Version.

    ![type](images/ebs2.png)  

1. On the Secrets tab, enter the secrets, if required, for your configuration.

    ![secrets](images/ebs3.png)  

1. On the Storage classes tab, review the storage classes that are deployed by the configuration or create a custom storage class.

    ![review](images/ebs4.png)

1. On the Assign to service tab, select your cluster that you want to assign your configuration to.

    ![assign](images/ebs5.png)

1. Click Complete to assign your storage configuration.

    ![complete](images/ebs6.png)

## Deploy ODF using EBS volumes in AWS

For more detailled descriptions of the following steps look also in the [Satellite Docs](https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli)
For sake of simplicity we will not configre Nooba COS backing store.

1. Connect to your Satellite Location on the CLI

    ```sh
    ibmcloud login --sso
    ibmcloud target -g academyrg -r us-east
    ```

    ![output](images/ibm-cloud-rg.png)

1. Verify that your cluster has a valid storage configuration has applied (from the previous chapter). Use the location id and cluster id ***NOT*** the name

    ```sh
    ibmcloud sat location ls
    ibmcloud oc cluster ls --provider satellite
    ibmcloud sat storage assignment  ls --location <location id> --cluster <cluster id>
    ```

    ![output](images/odf1.png)

1. What you also will see that we already have AWS Storage classes deployed, which could be used by ODF. Connect to your cluster and list the storage classes:

    ```sh
    # remove endpoint parameter if you connect via public IPs
    # use endpoint parameter if you connect from cloudshell
    ibmcloud ks cluster config -c <your cluster> --admin --endpoint link
    oc get storageclass
    ```

    ![output](images/odf2.png)  

1. Create an IBM API Key

    ```sh
    ibmcloud iam api-key-create odf --file apikey.json
    ```

    Open the JSON File and extract the apikey value. Don't share the key with anyone else!.

1. With that we could tell the Satellite based ODF deployment to use the AWS EBS Storage class configured by our Satellite Storage Configuration from the previous chapter. Please review before proceeeding the following article and parameters, we need to select a storage Class which has Volume Binding Mode Wait on first Consumer, because we have a multizone ROKS Cluster in AWS. 

    <https://cloud.ibm.com/docs/satellite?topic=satellite-config-storage-odf-remote&interface=cli#odf-remote-49-params>

    Execute the following command on your cluster to install ODF

    ```sh
    ibmcloud sat storage config create --name odf --location <your sat location id> --template-name odf-remote --template-version 4.9 -p "osd-storage-class=sat-aws-block-gold-metro" -p "osd-size=100Gi" -p "num-of-osd=1" -p "iam-api-key=<Your API Key>"
    ```

    ![output](images/odf3.png)

1. Assign the Configuration to the Cluster using the Console UI
Navigate in the IBM Cloud Console to your Satellite Storage Configurations. You will see now a second configuration for ODF.

    ![assign](images/odf4.png)

    Assign the Configuration to your ROKS cluster.

    ![assign](images/odf5.png)

1. Monitor the deployment using the oc CLI

    ```sh
    oc get storagecluster -n openshift-storage
    oc get pods -n openshift-storage
    ```

1. Grab a cup of coffee and wait until you see that all pods have been started

    ```sh
    oc get pods -n openshift-storage
    NAME                                                              READY   STATUS      RESTARTS   AGE
    csi-cephfsplugin-fshbp                                            3/3     Running     0          8m3s
    csi-cephfsplugin-g6h88                                            3/3     Running     0          8m3s
    csi-cephfsplugin-nzpql                                            3/3     Running     0          8m3s
    csi-cephfsplugin-provisioner-5b9c6d55cd-jz2rz                     6/6     Running     0          8m2s
    csi-cephfsplugin-provisioner-5b9c6d55cd-r8zdg                     6/6     Running     0          8m2s
    csi-rbdplugin-5fn6g                                               3/3     Running     0          8m4s
    csi-rbdplugin-c5wv5                                               3/3     Running     0          8m4s
    csi-rbdplugin-l4sfl                                               3/3     Running     0          8m4s
    csi-rbdplugin-provisioner-5b674484d-j8wgb                         6/6     Running     0          8m4s
    csi-rbdplugin-provisioner-5b674484d-s6vvn                         6/6     Running     0          8m4s
    noobaa-core-0                                                     1/1     Running     0          2m13s
    noobaa-db-pg-0                                                    1/1     Running     0          2m13s
    noobaa-endpoint-79cddbdfb8-plnfp                                  1/1     Running     0          57s
    noobaa-operator-6b5d8ffbc7-ftbtx                                  1/1     Running     0          8m49s
    ocs-metrics-exporter-6659bcdcfb-djkjg                             1/1     Running     0          8m39s
    ocs-operator-5bc589f4c4-p2vrh                                     1/1     Running     0          8m40s
    odf-console-85b7f578c9-lkpvf                                      1/1     Running     0          8m39s
    odf-operator-controller-manager-6f885fcc64-7xvmc                  2/2     Running     0          8m39s
    rook-ceph-crashcollector-ip-10-0-1-240.ec2.internal-76dc77c9pbl   1/1     Running     0          3m32s
    rook-ceph-crashcollector-ip-10-0-2-207.ec2.internal-69dbd62z65s   1/1     Running     0          3m33s
    rook-ceph-crashcollector-ip-10-0-3-177.ec2.internal-548768d84t5   1/1     Running     0          3m40s
    rook-ceph-mds-ocs-storagecluster-cephfilesystem-a-7dbfdc74h4nnp   2/2     Running     0          2m53s
    rook-ceph-mds-ocs-storagecluster-cephfilesystem-b-865b799c7gjd2   2/2     Running     0          2m52s
    rook-ceph-mgr-a-54b76869f4-47x5l                                  2/2     Running     0          3m40s
    rook-ceph-mon-a-688cb46bf9-c2sk5                                  2/2     Running     0          6m52s
    rook-ceph-mon-b-6c84db899-b8gfj                                   2/2     Running     0          4m18s
    rook-ceph-mon-c-b766fc6c-wlhbw                                    2/2     Running     0          4m1s
    rook-ceph-operator-7b5b5f9676-94nnr                               1/1     Running     0          8m39s
    rook-ceph-osd-0-77895b746b-kfqdk                                  2/2     Running     0          3m23s
    rook-ceph-osd-1-75cfcbfcc9-dtkgs                                  2/2     Running     0          3m23s
    rook-ceph-osd-2-5fd659646f-dj9jp                                  2/2     Running     0          3m15s
    rook-ceph-osd-prepare-ocs-deviceset-0-data-0kd9zz--1-h9cfm        0/1     Completed   0          3m37s
    rook-ceph-osd-prepare-ocs-deviceset-1-data-0nhdwc--1-2dskm        0/1     Completed   0          3m37s
    rook-ceph-osd-prepare-ocs-deviceset-2-data-0frg8b--1-wp2w6        0/1     Completed   0          3m36s
    rook-ceph-rgw-ocs-storagecluster-cephobjectstore-a-66c4b76g6qjt   2/2     Running     0          2m51s
    ```

1. Review the new ODF storage classes

    ```sh
    oc get storageclass
    ````

    ![output](images/odf6.png)

1. Test the storage class using the following yamls

    ```yaml
    # save to pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: odf-pvc
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
      storageClassName: ocs-storagecluster-ceph-rbd
    ```

1. Apply the pvc.yaml and check the pvcs

    ```sh
    oc project default
    oc apply -f pvc.yaml
    oc get pvc
    ```

    ![output](images/odf7.png)  

1. Now deploy an application using that pvc and connect to the pod:

    ```yaml
    # copy to pod.yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: app
    spec:
    containers:
    - name: app
        image: nginx
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo $(date -u) >> /test/test.txt; sleep 600; done"]
        volumeMounts:
        - name: persistent-storage
        mountPath: /test
    volumes:
    - name: persistent-storage
        persistentVolumeClaim:
        claimName: odf-pvc
    ```

    ```sh
    oc apply -f pod.yaml
    oc get po
    ````

    ![output](images/odf8.png)

1. Login into your pod and verify you could write to the volume

    ```sh
    oc exec app -it -- bash
    cat /test/test.txt
    touch /test/hello.txt
    ```

    ![output](images/odf9.png)
