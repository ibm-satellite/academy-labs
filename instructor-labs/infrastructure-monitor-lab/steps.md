## Satellite Monitoring Automation in Action

In this example we are going to show how IBM Cloud Satellite monitors location health and provides feedback to the user to solve issues. In this lab: we will simulate a problem in which the user has blocked access to IBM Cloud IAM. After blocking the access: we are going to look at the feedback offered by the location in the location status to determine what the problem is. We are also then going to use Platform logs to dig deeper into the specific issue that is occurring. 

### Lab Steps

1) In an existing healthy coreos-enabled location: disable the Satellite link IAM endpoint

While waiting do activity tracker lab


3) Wait a couple minutes for location to enter unhealthy state show the status
```
ibmcloud sat location get --location can3j0ql0pcg357njmqg
Retrieving location...
OK
                                   
Name:                           tyler-hypershift-eu-gb-1   
ID:                             can3j0ql0pcg357njmqg   
Created:                        2022-06-18 15:45:55 -0500 (1 week ago)   
Managed From:                   lon   
State:                          action required   
Ready for deployments:          no   
Message:                        R0057: Outbound traffic to IBM Cloud IAM is failing. To ensure that all host requirements are met, see https://ibm.biz/sat-host-reqs. More information is available in the IBM Cloud Platform Logs. If the issue persists, contact IBM Cloud Support and include your Satellite location ID.   
Hosts Available:                0   
Hosts Total:                    8   
Host Zones:                     eu-gb-1, eu-gb-2, eu-gb-3   
Provider:                       -   
Provider Region:                -   
Provider Credentials:           no   
Public Service Endpoint URL:    https://c116-e.eu-gb.satellite.cloud.ibm.com:31778   
Private Service Endpoint URL:   -   
OpenVPN Server Port:            -   
Ignition Server Port:           32257   
Konnectivity Server Port:       31036   
Logging Key Set:                no   
Activity Tracker Key Set:       no   
```

3) Then go to platform logs and find:
```
Check iam-test is failing on host: t-can3j0ql0pcg357njmqg-3
Failure Message: Readiness probe failed: error curling IAM health endpoint
+ IAM_ENDPOINT=iam.cloud.ibm.com
+ [[ '' == \s\t\a\g\e* ]]
```

4) Using that information now let's turn back on IAM endpoint and then wait for location to go healthy

```
bx sat location get --location can3j0ql0pcg357njmqg
Retrieving location...
OK
                                   
Name:                           tyler-hypershift-eu-gb-1   
ID:                             can3j0ql0pcg357njmqg   
Created:                        2022-06-18 15:45:55 -0500 (1 week ago)   
Managed From:                   lon   
State:                          normal   
Ready for deployments:          yes   
Message:                        R0001: The Satellite location is ready for operations.   
Hosts Available:                0   
Hosts Total:                    8   
Host Zones:                     eu-gb-1, eu-gb-2, eu-gb-3   
Provider:                       -   
Provider Region:                -   
Provider Credentials:           no   
Public Service Endpoint URL:    https://c116-e.eu-gb.satellite.cloud.ibm.com:31778   
Private Service Endpoint URL:   -   
OpenVPN Server Port:            -   
Ignition Server Port:           32257   
Konnectivity Server Port:       31036   
Logging Key Set:                no   
Activity Tracker Key Set:       no
```