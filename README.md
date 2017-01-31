# EndTB System Provisioning

## Development Environment Setup

### Prerequisites
1. Install latest versions of Ansible, VirtualBox, and Vagrant
2. Ensure BIOS supports virtualization (if needed) and install VirtualBox Guest Additions if needed

### Create your Vagrant Box
1. Copy the "Vagrantfile" and "endtbdev" script found in the "dev" folder of this project to "~/bahmni/environments/endtb".  
(If you wish to use a directory other than "~/environments/endtb" to set up your VM you'll need to modify VAGRANT_BOX_DIR in the endtbdev script
2. Modify this file:
- Change "{{ENDTB_CONFIG_SRC_DIR}}" to point to the "openmrs" subfolder of the source folder for endtb config on your local machine
- Change "{{BAHMNI_APPS_SRC_DIR}}" to point to the source folder for bahmniapps on your local machine
- Adjust the memory allocated to the VM based on your machine's capacity
- Remove or modify the config.vm.synced_folder "../yum_cache/", "/etc/yum_cache".  This is for enables caching of rpms to be stored outside of vagrant. You'll need to make sure the source directory exists on your host if you want to cache.
(More infor on cache issues: https://talk.openmrs.org/t/installing-bahmni-with-limited-internet/5392)
3. Run "vagrant up" from this directory
4. You might need to SSH into this box for the first time to ensure proper keys are set up (run "ssh vagrant@192.168.33.21", password="vagrant")

### Provision your Vagrant Box

From the root of this project, run "./deploy.sh".  This will connect to the Vagrant box set up above (the IP address in both
is hard-coded to 192.168.33.21), and will setup Bahmni for endTB based on the configuration specified.

The install will take some time.  To monitor the install you can tail and yum and/or bahmni installer logs:
sudo tail -f /var/log/yum.log
sudo tail -f /var/log/bahmni-installer/bahmni-installer.log

### How to change this to reflect newer versions of code

The configuration is specified in playbooks/roles/bahmni/defaults/main.yml.  The things that will most frequently change here
as code changes are:

* bahmni_version: This should reflect the specific version of Bahmni to install (eg. bahmni_version: "0.86-70")
* implementation_config_url: This should point to a URL hosting a ZIP file containing the endtb config (eg. "https://github.com/Bahmni/endtb-config/archive/release-0.86.zip")
* omods: This should be changed as we host our omods in different locations, or want to install newer versions

For a given Vagrant box or test server, you may also want to change the following to meet the specific needs/constraints:

* timezone: "America/New_York"
* selinux_state: "permissive"
* openmrs_server_options: "-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m"

* openmrs_user_password: "Admin123"
* openmrs_db_password: "openmrs"
* mysql_root_password: "root"d

### Endtb update tools
The script "endtbdev" provides handy tools for updating your vagrant box.  You should copy it into the 