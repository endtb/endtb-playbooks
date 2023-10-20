# EndTB System Provisioning

## Development Environment Setup

### Prerequisites
* Install latest versions of VirtualBox, and Vagrant 
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
```

### Provision your Vagrant Box

```
cd endtb-playbooks
ansible-playbook --become-user=root -i hosts "playbooks/bahmni.yml" --limit "localhost" -vvvv
```

The installation will take some time.  To monitor the installation, once the bahmni installer starts executing
you can tail and yum and/or bahmni installer logs:

```
sudo tail -f /var/log/yum.log
sudo tail -f /var/log/bahmni-installer/bahmni-installer.log
```