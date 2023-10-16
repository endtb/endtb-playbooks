# EndTB System Provisioning

## Development Environment Setup
Follow instructions for checking out and setting up any

### Prerequisites
* Install latest versions of Ansible, VirtualBox, and Vagrant 
* Ensure BIOS supports virtualization (if needed) and install VirtualBox Guest Additions if needed

### Setting up the server
* Create a local directory to use for this.  For example "~/environments/endtb".  We'll refer to this as `$HOME` below.
* Create a folder in `$HOME` called `yum_cache` (see: https://talk.openmrs.org/t/installing-bahmni-with-limited-internet/5392)
* Create a symbolic link in `$HOME` to the local folder containing the checked out endtb-playbooks (this should be available at `$HOME/endtb-playbooks`)
* Create a symbolic link in `$HOME` to the local folder containing the checked out endtb-config (this should be available at `$HOME/endtb-config`)
* Create a symbolic link in `$HOME` to the local folder containing the checked out openmrs-module-bahmniapps (this should be available at `$HOME/openmrs-module-bahmniapps`)
* Create a symbolic link to `$HOME/endtb-playbooks/dev/Vagrantfile`
* Create a symbolic link to `$HOME/endtb-playbooks/dev/endtbdev`
* Set up your ssh settings by adding the following to your `.ssh/config` file (create this file if it does not yet exist):
```
Host vagrant-endtb
    HostName 192.168.33.21
    PubkeyAcceptedKeyTypes=+ssh-rsa,ssh-dss
    HostkeyAlgorithms=+ssh-rsa,ssh-dss
```
* Start up the Vagrant box by running `vagrant up`
* Once this has fired up, setup key-based authentication: `ssh-copy-id vagrant@vagrant-endtb` with password `vagrant`
* Connect into the box using  `ssh vagrant@vagrant-endtb`

## Commands to run within the Vagrant box

### Installing Ansible
Due to library dependencies, particularly of Python, with Ansible run from a current O/S on the host, and the version
of Python supported on the VM, it is currently easiest to simply install Ansible within the Vagrant Box and execute it
from there.
```
sudo su -
yum install -y epel-release
yum install -y ansible

### Provision your Vagrant Box

```
cd endtb-playbooks
ansible-playbook --become-user=root -i hosts "playbooks/bahmni.yml" --limit "localhost" -vvvv
```



Running a "vagrant up" should also provision your machine for you.  To run the ansible provisioning again, run "vagrant provision"

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