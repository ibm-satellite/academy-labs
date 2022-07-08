## Lab cleanup This needs to be completed within 72 hours after completing the academy session.

### Cleanup Demo Environments

1.  It is very important to clean-up the demo env as soon as customer
    demo is done, so that cloud spend is controlled and we show to the
    customers of same value.

2.  By cleaning the demo env, you allow other IBMers, and business
    partners will be able to use cloud resources to show to their
    clients.

3.  Proper cleanup avoids hitting resource limits set by the ITZ
    enterprise account and prevents failures in building more
    environments.

Demo env Cleanup Procedures:

1.  Login to IBM Cloud, and go to schematics

2.  ![Graphical user interface, application Description automatically
    generated](./images/image25.png)

3.  Click on the workspace named with your location name

4.  ![Graphical user interface, application, Teams Description
    automatically
    generated](./images/image26.png)

5.  Click on the job and from Actions drop down select Destroy

6.  ![Graphical user interface, application, Teams Description
    automatically
    generated](./images/image27.png)

7.  This destroys resources created by this schematics template

8.  NOTE: This may take up to 30mins

9.  Now Go to Satellite location and verify location to be deleted has
    0/0 hosts in Host usage column (used/total)

10. ![Graphical user interface, application Description automatically
    generated](./images/image28.png)

11. Click on the location and see if it shows any hosts assigned, if so,
    remove each host from this location

12. Now from actions drop down Delete the location

13. ![Graphical user interface, application, website, Teams Description
    automatically
    generated](./images/image29.png)

14. If you get a message like below, go to clusters and delete the
    cluster

15. ![Graphical user interface, application, Teams Description
    automatically
    generated](./images/image30.png)

16. Remove the worker nodes if exist

17. ![A screenshot of a computer Description automatically
    generated](./images/image31.png)

18. To delete the cluster, go to Resource list and to the right end
    click on Three Dots and click delete

19. ![Graphical user interface, text, website Description automatically
    generated](./images/image32.png)

20. Remove the COS Bucket that created by Satellite location (TBD)

21. Remove Sysdig instance

22. Log DNA

23. Activity tracker

THANK YOU for being responsible to clean the demo environments and support others to have same experiential learning of IBM Cloud Satellite.