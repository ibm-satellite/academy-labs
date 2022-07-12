# Copy/paste the satellite location attach script in the wrapper below
# where you see <ATTACH_SCRIPT>
#
# The pasted script
# - needs to be indented 4 spaces
# - they need to be spaces, NOT tabs
# - remove any blank lines before/after what was pasted (if any were included)
# - remove <ATTACH_SCRIPT> line
# - needs to have the "if" script from  vpc-attach-labels.sh  added



#cloud-config
write_files:
- content: |
    <ATTACH_SCRIPT>
  path: /run/attach.sh
  permissions: '0700'
runcmd:
  - subscription-manager refresh && subscription-manager repos --enable rhel-server-rhscl-7-rpms && subscription-manager repos --enable rhel-7-server-optional-rpms && subscription-manager repos --enable rhel-7-server-rh-common-rpms && subscription-manager repos --enable rhel-7-server-supplementary-rpms && subscription-manager repos --enable rhel-7-server-extras-rpms && nohup bash /run/attach.sh
