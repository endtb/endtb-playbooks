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
1. 