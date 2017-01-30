#!/bin/bash

##########################################################################################
# Provisions Bahmni into a Vagrant box
##########################################################################################

ansible-playbook --sudo -i hosts "playbooks/bahmni.yml" --limit "endtb-dev" -vvvv
