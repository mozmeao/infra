# Ark backup and restore

MozMEAO uses [Heptio's](https://heptio.com/) [Ark](https://github.com/heptio/ark) tool for Kubernetes backup and restore.


# Operations

- [Ark Quickstart](https://heptio.github.io/ark/v0.9.0/quickstart)
- [Ark Use Cases](https://heptio.github.io/ark/v0.9.0/use-cases)

## Listing current backups

```
ark backup list
```

## Ad-hoc backups

To backup the entire cluster:

```bash
ark backup create my-backup
```

To backup using a selector:

```bash
ark backup create my-backup  --selector app=nginx
```


## Scheduled backups

List current schedules:

```bash
ark schedule get
```

Setup a new backup schedule:

```bash
ark schedule create oregon-a-daily --schedule "0 7 * * *"
```

## Restoring a backup

```
 ark restore create --from-backup my-backup
```
The [Ark Use Cases](https://heptio.github.io/ark/v0.9.0/use-cases) page walks through a disaster recovery scenario.

---

# Installation

## K8s Installation

Install Ark using [these](https://heptio.github.io/ark/v0.9.0/aws-config) docs for AWS. 

> The Ark user and bucket names have been renamed from the install doc examples to be cluster-specific. 

- Setup an S3 bucket and IAM user:

```bash
export ARK_BUCKET=my-bucket-ark-frankfurt
export ARK_REGION=eu-central-1
export ARK_USER=ark-frankfurt
export ARK_NAMESPACE=heptio-ark

aws s3api create-bucket \
    --bucket ${ARK_BUCKET} \
    --region ${ARK_REGION} \
    --create-bucket-configuration LocationConstraint=${ARK_REGION}

 aws iam create-user --user-name ${ARK_USER}

 cat > heptio-ark-policy.json <<EOF
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "ec2:DescribeVolumes",
                 "ec2:DescribeSnapshots",
                 "ec2:CreateTags",
                 "ec2:CreateVolume",
                 "ec2:CreateSnapshot",
                 "ec2:DeleteSnapshot"
             ],
             "Resource": "*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "s3:GetObject",
                 "s3:DeleteObject",
                 "s3:PutObject",
                 "s3:AbortMultipartUpload",
                 "s3:ListMultipartUploadParts"
             ],
             "Resource": [
                 "arn:aws:s3:::${ARK_BUCKET}/*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "s3:ListBucket"
             ],
             "Resource": [
                 "arn:aws:s3:::${ARK_BUCKET}"
             ]
         }
     ]
 }
 EOF

aws iam put-user-policy \
   --user-name ${ARK_USER} \
   --policy-name ${ARK_USER} \
   --policy-document file://heptio-ark-policy.json

aws iam create-access-key --user-name ${ARK_USER}
```

- Populate the `credentials-ark` file with the results from the command above:

```
 [default]
 aws_access_key_id=<AWS_ACCESS_KEY_ID>
 aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
```

- Create a secret:

```bash
kubectl create secret generic cloud-credentials \
    --namespace ${ARK_NAMESPACE} \
    --from-file cloud=credentials-ark
```


- Modify Ark config

Modify the `ark-config.yaml` file and change the `region` and `bucket` values. 

- Install Ark

```
kubectl apply -f 00-prereqs.yaml
kubectl apply -f 00-ark-config.yaml
kubectl apply -f 10-deployment.yaml
```

- Test

Once the Ark pod is up and running, try creating a backup:

```bash
ark backup create test-backup
watch ark backup describe test-backup
```

If there are IAM or ClusterRole issues, tail the Ark pod logs:

```bash
kubectl -n heptio-ark logs ark-57f45f7d78-ts21x
```

Once your test backup works, setup a backup schedule:

```bash
ark schedule create frankfurt-daily --schedule "0 9 * * *"
```


## Client installation

Download the appropriate release from [here](https://github.com/heptio/ark/releases), make it executable and put it somewhere in your path.


