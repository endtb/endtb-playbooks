# EndTB System Provisioning

## Development Environment Setup

### Prerequisites
1. Install latest versions of Ansible, VirtualBox, and Vagrant
2. Ensure BIOS supports virtualization (if needed) and install VirtualBox Guest Additions if needed

### Create your Vagrant Box
1. In a new directory, copy the Vagrantfile in the "dev" folder of this project.
2. Modify this file as needed 
- Adjust the memory allocated to the VM based on your machine's capacity
- Remove of modify the config.vm.synced_folder "../yum_cache/", "/etc/yum_cache".  This is for enabling caching of rpms outside of vagrant.
3. Run "vagrant up" from this directory
4. You might need to SSH into this box for the first time to ensure proper keys are set up (ssh vagrant@192.168.33.21)

### Provision your Vagrant Box

From the root of this project, run "./deploy.sh".  This will connect to the Vagrant box set up above (the IP address in both
is hard-coded to 192.168.33.21), and will setup Bahmni for endTB based on the configuration specified.

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
* mysql_root_password: "root"