#!/bin/bash

PLAYBOOK_NAME="$1"

yum install -y ansible
ansible-playbook --sudo -i hosts "playbooks/$PLAYBOOK_NAME.yml" --limit "endtb-test" -vvvv