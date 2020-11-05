#/bin/bash

LINE='package_url: "https://github.com/endtb/package1.git"'
FILE="playbooks/roles/bahmni/defaults/main.yml"

grep -qF -- "$LINE" "$FILE" || echo $LINE >> $FILE

ansible-playbook --sudo -i hosts "playbooks/package1.yml" --limit "production" -vvvv
