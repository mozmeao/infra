# Jenkins Maintenance

## Upgrading Plugins

To upgrade Jenkins plugins:

 0. Ping folks in #mozmeao-infra that you're going to need about 30 minutes
 1. Get a [Backup](#backup)
 2. Login into WebUI
 3. Click `Manage Jenkins` -> `Manage Plugins` -> click the ones you want to
    upgrade.
 4. Verify that Jenkins is running and that everything looks OK. Otherwise
    rollback.

## Upgrading Jenkins Core

To upgrade Jenkins Core to a new version:

 0. Ping folks in #mozmeao-infra that you're going to need abocput 30 minutes
 1. Get a [Backup](#backup)
 2. SSH in ciw
 3. Run `sudo bash -c "aptitude update && aptitude install jenkins"`
 4. Verify that Jenkins is running and that everything looks OK. Otherwise
    rollback.

## Backup

To backup Jenkins

 1. Login into WebUI
 2. Click `Manage Jenkins` -> `ThinBackup` -> `Backup Now`

Note:

 The command will return immediately and the backup will happen in the
 background. If you need to know when the backup is done (and you probably do if
 you're upgrading core or plugins) SSH in ciw and `cd /var/lib/jenkins/backups`.
 If there're are more than 3 directories and files listed the backup is still
 running. You can verify that the directory size is growing using `du -sm .`.
 The backup takes about 10 minutes to complete.

## Docker Cleanup

To cleanup docker images and running containers:

 0. Ping folks in #mozmeao-infra that some jobs may fail due to docker restart
 1. SSH in ciw
 2. Run the docker image cleanup script `/usr/local/bin/remote-docker-images.sh`
 3. Restart docker to refresh the daemon and remove any stale containers
 4. Make sure that docker registries (2 have two of them) are running using
    `docker ps`. If not start them using `sudo supervisorctl start all`
