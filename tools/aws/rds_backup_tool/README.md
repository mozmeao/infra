# MozMEAO RDS backup tool

The RDS backup tool allows us to export a MySQL/MariaDB/Postgres database from a pod running in Kubernetes. The running pod must already have connectivity to the VPC where the database is running. Backups are encrypted and pushed to a directory in an S3 bucket. Our current implemention uses an S3 bucket with lifecycle rules, which expires older backups to AWS Glacier after a certain number of days.

> Note: You must rely on an external scheduler/cron, as this tool is designed to be used in K8s clusters without cronjobs enabled.

## <a name="per-region-setup"></a>Per-region setup

Secrets for the RDS backup tool are located in our private repo in the `aws/rds_backup_secrets` directory. These secrets are shared for all backups configured in a given region. If the secrets have already been created in Kubernetes, you can most likely skip this section and continue on [to create a new backup target](#backup-target-setup).

#### Region global secrets

Create a file named `rds-backup-config-secrets-<region>.yaml` and populate with the following values:

```
apiVersion: v1
kind: Secret
metadata:
  name: rds-backup-config
type: Opaque
data:
  AWS_ACCESS_KEY_ID: value_in_bas64
  AWS_SECRET_ACCESS_KEY: value_in_bas64
  BACKUP_PASSWORD: value_in_bas64
```

- `AWS_ACCESS_KEY_ID` - access key ID for the user created above with access to the backup bucket
- `AWS_SECRET_ACCESS_KEY` - secret key ID for the user created above with access to the backup bucket
- `BACKUP_PASSWORD` - a password used for OpenSSL AES 256 symmetric encryption. It's up to the engineer installing this service to decide if each region uses a unique or shared password.

```
kubectl create namespace rds-backups
kubectl -n rds-backups create -f rds-backup-config-secrets-<region>.yaml
```

## <a name="backup-target-setup"></a>Backup target setup

To backup a particular database in the given region where the tool is installed, you'll need to create and install a secrets file, and then add a `Makefile` target specifying a few values for the new backup.

### 0. Create a new secrets file

Once the region global secrets have been configured, you can create a file named `rds-backup-<dbname>-secrets-<region>.yaml` using the following template:

```
apiVersion: v1
kind: Secret
metadata:
  name: rds-backup-<yourdbname>
type: Opaque
data:
  DBHOST: value_in_base64
  DBNAME: value_in_base64
  DBPASSWORD: value_in_base64
  DBPORT: value_in_base64
  DBUSER: value_in_base64
  DEADMANSSNITCH_URL: value_in_base64 or empty
```

#### Secret values

- `DBHOST ` - raw URL to access the DB, should NOT have a prefix (eq `pgsql://`) or a `:portnumber` suffix.
- `DBNAME` - the name of the database to export.
- `DBPASSWORD` - definitely the password.
- `DBPORT` - The port number, this is usually `5432` for Postgres or `3306` for Mysql.
- `DBUSER` - The db user used to connect and perform the backup.
- `DEADMANSSNITCH_URL` - If Deadmanssnitch is being used, populate this value with the URL. Leave empty to skip this type of notification.

### 1. Create the secret in Kubernetes

Next, create the secret in Kubernetes with the following command:

```
kubectl -n rds-backups create -f rds-backup-<dbname>-secrets-<region>.yaml
```

### 2. Add a Makefile target

Once a secret has been created, you'll need to add a new target to the `Makefile` in this directory.

```
backup-frankfurt:
    env DBTYPE=PGSQL \
        DB_SECRETS_NAME=rds-backup-frankfurt \
        BACKUP_POD_NAME=frankfurt \
    ${RENDER_POD_CMD}

```

> Note the `\` characters at the end of each line of the make target!

- `DBTYPE` - either `MYSQL` or `PGSQL`, must be in all caps or the universe will implode.
- `DB_SECRETS_NAME` - the name of the K8s secrets resource to use. This is NOT the filename, but the value obtained from the secrets you created directly above. For example, the `DB_SECRETS_NAME` value would be `rds-backup-bedrock` if the template above was populated with:

        apiVersion: v1
        kind: Secret
        metadata:
          name: rds-backup-bedrock
        ...

- `BACKUP_POD_NAME` - the name to give the running pod. Today's date is appended as a suffix.

### 3. Run the backup

```
make backup-frankfurt
```

## Troubleshooting

If the backup fails to run successfully, you can start it with `DEBUG_MODE=true` to prevent the `rdsbackup.sh` script from running in the container. This
allows you to obtain a shell in the pod for troubleshooting.

```
DEBUG_MODE=true make mdn-frankfurt
```

Connect to the pod that was started in `DEBUG_MODE` with:

```
kubectl -n rds-backups exec -it rdsbackup-frankfurt-2017-11-17 bash
```

To see a list of pods that includes pods in `Completed` status, run:

```
kubectl -n rds-backups get pods -a
```

> The main backup script in the container is called `/usr/bin/rdsbackup.sh`.

> Inspect the environment with the `env` command to see currently set values.

## Decrypting a database archive

You can download the backup from either the AWS web console, or the AWS cli.

```
aws s3 cp s3://meao-rds-backups/backups/developer_mozilla_org/developer_mozilla_org.2017-11-17.sql.gz.aes ./some_local_dir
```

Check the version of `openssl` that you're using (`openssl version`).

If you're using `openssl` version 1.1 or later:

```
# stream directly to dbms (with openssl version >= 1.1)
openssl aes-256-cbc -d -md md5 -in developer_mozilla_org.2017-11-17.sql.gz.aes -pass pass:foobar123 | zcat | mysql ...
# decrypt to a file (with openssl version >= 1.1)
openssl aes-256-cbc -d -md md5 -in developer_mozilla_org.2017-11-17.sql.gz.aes -pass pass:foobar123 -out developer_mozilla_org.2017-11-17.sql.gz
```

If you're using an `openssl` version prior to 1.1:

```
# stream directly to dbms (with openssl version < 1.1)
openssl aes-256-cbc -d -in developer_mozilla_org.2017-11-17.sql.gz.aes -pass pass:foobar123 | zcat | mysql ...
# decrypt to a file (with openssl version < 1.1)
openssl aes-256-cbc -d -in developer_mozilla_org.2017-11-17.sql.gz.aes -pass pass:foobar123 -out developer_mozilla_org.2017-11-17.sql.gz
```

> The password is stored in `credentials.yml` under the key `backup_gpg_password`.

## Initial setup

### S3

You can use whatever S3 bucket you'd like, but these are the configuration parameters we're using:

- Create an S3 bucket with logging and versioning enabled.
    - Logging can be configured to write to `logs/`.
- Setup a lifecycle rule to move old objects from `backups/` to Glacier.
    - Current/previous versions of objects can be transitioned to Glacier after 30 days.
    - Objects older than 60 days are expired from S3.
- Create a root level directory named `backups/` in the bucket. This is to separate `logs` from lifecycle rules.

### IAM

Create a user with API access the following IAM policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-backup-bucket"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::your-backup-bucket/*"
            ]
        }
    ]
}
```

Store the access key and secret key in a safe place. You'll need it for [per-region setup](#per-region-setup).
