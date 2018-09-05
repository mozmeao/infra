#!/bin/bash

set -xu

BACKUP_DIR="${backup_dir}"
BACKUP_BUCKET="${backup_bucket}"
JENKINS_BACKUP_DMS="${jenkins_backup_dms}"

die() {
    echo "$*" 1>&2
    exit 1
}

restore-backup-set() {
    systemctl stop jenkins
    echo "Restoring from backup"
    aws s3 sync --delete --exclude=.initial-sync "s3://$BACKUP_BUCKET/" "$BACKUP_DIR/" --quiet
    chown -R jenkins:jenkins "$BACKUP_DIR"
    touch "$BACKUP_DIR/.initial-sync"
    systemctl start jenkins
}

ci-restore() {
    systemctl stop jenkins
    # List all backups in proper order
    ALL_BACKUPS=$(find $$BACKUP_DIR -maxdepth 1 -type d   -name 'FULL*' -o -name 'DIFF*' | sort -t- -k2)

    # Find the last full backup
    LAST_FULL=$(basename "$(echo "$$ALL_BACKUPS" | grep FULL | tail -n1)")

    # And all following incrementals
    INCREMENTALS=$(echo "$$ALL_BACKUPS" | sed -e "0,/$LAST_FULL/d" | xargs -n1 basename)

    # Recover from latest backup (full + incrementals)
    for BACKUP in $$LAST_FULL $$INCREMENTALS; do
        echo "Restoring from $$BACKUP_DIR/$BACKUP/"
        su - jenkins -c "rsync -av $BACKUP_DIR/$BACKUP/ /var/lib/jenkins/"
    done
    systemctl start jenkins
}

lock() {
    local prefix=$$1
    local lock_file="/var/lock/$$prefix.lock"

    # create lockfile
    eval "exec 200>$$lock_file"
    # acquire the lock
    flock -n 200 \
        && return 0 \
        || return 1
}

main() {
    # Make sure backups dont run when trying to restore
    lock "backup_jenkins"

    # Setup git and ansible
    apt-get update
    apt-get install --yes git ansible

    # run ansible
    git clone https://github.com/mdn/ansible-jenkins.git /tmp/ansible-jenkins || die "Failed to git clone"
    cd /tmp/ansible-jenkins && \
        ansible-playbook site.yml -e "jenkins_backup_directory=$${BACKUP_DIR} jenkins_backup_bucket=$${BACKUP_BUCKET} jenkins_backup_dms=${jenkins_backup_dms} nginx_htpasswd=${nginx_htpasswd}" \
        || die "Failed to run ansible"

    echo "Restoring backup sets to $${BACKUP_DIR}"
    restore-backup-set || die "Failed to restore backup set to $${BACKUP_DIR}"

    echo "Restoring jenkins"
    ci-restore || die "Failed to restore jenkins"
}

main
