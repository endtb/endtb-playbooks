#!/bin/bash

PLAYBOOK_NAME="$1"
SSH_USER="$2"

yum install -y ansible
ansible-playbook --sudo -i hosts -u "$SSH_USER" "playbooks/$PLAYBOOK_NAME.yml" --limit "endtb-test" -vvvv