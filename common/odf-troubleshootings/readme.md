# ODF Troubleshooting commands

Below is a list of troubleshooting commands when installing, updated ODF on Satellite.

## Table of content

1. [Troubleshooting: Check the OCS cluster](#troubleshooting-check-the-ocs-cluster)
1. [Troubleshooting: Check the logs of metric agent](#troubleshooting-check-the-logs-of-metric-agent)
1. [Troubleshooting: Check the logs of OCS operator controller manager](#troubleshooting-check-the-logs-of-ocs-operator-controller-manager)
1. [Troubleshooting: Change worker name assigned to ODF](#troubleshooting-change-worker-name-assigned-to-odf)
1. [Troubleshooting: Control the managed addon option of ocs](#troubleshooting-control-the-managed-addon-option-of-ocs)
1. [Troubleshooting: Check the disk available in the storage node](#troubleshooting-check-the-disk-available-in-the-storage-node)

## Troubleshooting: Check the OCS cluster

1. Describe OCS cluster

    ```sh
    oc describe ocscluster
    ```

## Troubleshooting: Check the logs of metric agent

1. Make sure the metric agent is running.

    ```sh
    oc get pods -n kube-system | grep metrics
    ```

1. If the metric agent is running, save the pod metric agent name.

    ```sh
    export POD_METRIC_NAME=$(oc get pods -n kube-system | grep metrics | awk '{print $1}')
    ```

1. If the agent is running, get it logs

    ```sh
    oc logs -n kube-system $POD_METRIC_NAME
    ```

## Troubleshooting: Check the logs of OCS operator controller manager

1. Get OCS pod name

    ```sh
    export POD_OCS_NAME=$(oc get pods -n kube-system | grep ocs | awk '{print $1}')
    ```

1. Get the logs of OCS operator controller manager

    ```sh
    oc logs -n kube-system $POD_OCS_NAME
    ```

## Troubleshooting: Change worker name assigned to ODF

1. Get the worker names

    ```sh
    oc get nodes
    ```

1. Change the names of the worker assigned to ODF

    ```sh
    ibmcloud sat storage config param set --config <your_storage_config_name> --param "worker-nodes=<node-name-1>,<node-name-2>,<node-name-3>" --apply
    ```

    Example:

    ```sh
    ibmcloud sat storage config param set --config vmware-odf-local-storage --param "worker-nodes=satellite-270002r30a-pc7rcizz-storage-0.csplab.local,satellite-270002r30a-pc7rcizz-storage-1.csplab.local,satellite-270002r30a-pc7rcizz-storage-2.csplab.local" --apply
    ```

## Troubleshooting: Control the managed addon option of ocs

1. Get the status of managed-addon-options-osc

    ```sh
    oc describe cm managed-addon-options-osc -n kube-system
    ```

## Troubleshooting: Check the disk available in the storage node

1. Connect to the storage node.

1. List block devices

    ```sh
    lsblk
    ```

1. List block devices with output  info  about  filesystems

    ```sh
    lsblk -f
    ```
