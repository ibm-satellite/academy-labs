## Activity Tracker Logs for Satellite

In this lab: we will view the activity tracker events associated with link endpoint operations. 

### Lab Steps

1. Go to appropriate Activity Tracker instance for region. [Relevant link](https://cloud.ibm.com/observe/activitytracker).
   ![Activity Tracker Instance](.pastes/appropriate_activity_tracker_instance.png)
   ![Open Dashboard](.pastes/open_dashboard.png)

2. Toggle link endpoints on and off in the Link Endpoints page of a given location. In the activity tracker logs search for `"endpoints update"` to see the data on the corresponding event.
   ![Update Event](.pastes/update_event.png)

3. Create and endpoint in the Link Endpoints page of a given location. In the activity tracker logs search for `endpoints create` to see the data on the corresponding event.
   ![Create Event](.pastes/create_event.png)

4. Delete an endpoint in the Link Endpoints page of a given location. In the activity tracker logs search for `endpoints delete` to see the data on the corresponding event.
   ![Delete Event](.pastes/delete_event.png)

Congrats! The lab is now complete.

Authors: Tyler Lisowski