# mdn-backup

## Building and pushing the image

From the `infra/apps/mdn/utils/efs_backup/image` directory, simply run:

```bash
make
```

The default target will build and push the image to quay.io.

## Configuration

- `LOCAL_DIR` - the directory *in the running container* that we'll push or pull from.
- `BUCKET` - the bucket where backup data is stored. 
- `REMOTE_DIR` - the directory in `$BUCKET` that we'll push or pull from.
- `PUSH_OR_PULL` - set to either `PUSH` or `PULL`
  - `PUSH` - recursively sync from `$LOCAL_DIR` to `$BUCKET$REMOTE_DIR`
  - `PULL` - recursively sync from `$BUCKET$REMOTE_DIR` to `$LOCAL_DIR`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
	- credentials for the `mdn-efs-backup` user
	- **or**, credentials for a user with the following attached policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::your-backup-bucket"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::your-backup-bucket/*"]
    }
  ]
}
```

## Running locally

You can run the tool in Docker locally to test out IAM creds:

```bash
docker run \
        -e AWS_ACCESS_KEY_ID="foo" \
        -e AWS_SECRET_ACCESS_KEY="bar" \
        -e PUSH_OR_PULL="PULL" \
        -e LOCAL_DIR="/mdn_stuff" \
        -e REMOTE_DIR="/backups/www" \
        -e BUCKET="s3://mdn-shared-backup" \
        -v $(pwd)/stuff:/mdn_stuff \
        quay.io/mozmar/mdn-backup:latest
```


## Using in Kubernetes

First, create a K8s secret.

`mdn-backup-secrets.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mdn-sync-secrets
type: Opaque
data:
  access_key: foo_in_base64
  secret_key: bar_in_base64
```

**NOTE** `access_key` and `secret_key` values MUST be encoded with the `base64` utility.

### TODO: turn this into a deployment w/ crontask

Next, create a deployment.

`mdn-backup.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mdn-backup-and-sync
spec:
  containers:
    - name: mdn-sync
      image: quay.io/mozmar/mdn-backup:latest
      volumeMounts:
        - mountPath: "/mdn"
          name: mdn-shared-pvc
      env:
        - name: LOCAL_DIR
          value: /mdn
        - name: REMOTE_DIR
          value: /backups/dev/
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: mdn-sync-secrets
              key: access_key
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: mdn-sync-secrets
              key: secret_key
  volumes:
    - name: mdn-shared-pvc
      persistentVolumeClaim:
        claimName: mdn-shared-pvc
  restartPolicy: Never
```


```bash
kubectl -n some_namespace apply -f mdn-backup-secrets.yaml
kubectl -n some_namespace apply -f mdn-backup.yaml
```
