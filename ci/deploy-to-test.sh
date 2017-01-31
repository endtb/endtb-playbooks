#!/bin/bash

PLAYBOOK_NAME="$1"
SSH_USER="$2"
SSH_KEY_FILE="$3"

yum install -y ansible
ansible-playbook --sudo -i hosts -u "$SSH_USER" --private-key="$SSH_KEY_FILE" "playbooks/$PLAYBOOK_NAME.yml" --limit "endtb-test" -vvvv
