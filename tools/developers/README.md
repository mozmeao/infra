# AWS EC2 developer instance launcher

The `launch_instance.sh` script in this directory launches ad-hoc instances in `us-east-2` from the command line with minimal setup.

## Prerequisites

- [AWS cli](https://aws.amazon.com/cli/)
- [jq](https://stedolan.github.io/jq/)
- bash
	- this is a bash script, and zsh won't work.

On MacOS with `brew` installed, you can run:

```
brew install awscli
brew install jq
```

### Setup the AWS cli

run:

```
aws configure
```

and follow the prompts. 

- for `Default region name`, enter `us-east-2`
- for `Default output format`, enter `json`

## Defaults

The default settings are as follows:

- `t2.medium` in the `us-east-2` AWS EC2 region 
-  Ubuntu Server 16.04 LTS (HVM), SSD Volume Type for us-east-2
	-  via the `ami-fcc19b99` AMI
	-  see [below](#envvars) to change the AMI
- your public ssh key located at `~/.ssh/id_rsa.pub` will automatically be uploaded to the `us-east-2` region.
	- see [below](#envvars) to override the public key file location

## Usage 

```
export AWS_USER="foo"
./launch_instance.sh
```

### Example

```
$ export AWS_USER="foo"
$ export EC2_INSTANCE_SIZE="t2.micro"
$ ./launch_instance.sh
   __  __        __  __ ___   _   ___
 |  \/  |___ __|  \/  | __| /_\ / _ \
 | |\/| / _ \_ / |\/| | _| / _ \ (_) |
 |_|_ |_\___/__|_|  |_|___/_/ \_\___/
 | __/ __|_  ) (_)_ _  __| |_ __ _ _ _  __ ___
 | _| (__ / /  | | ' \(_-<  _/ _` | ' \/ _/ -_)
 |___\___/___| |_|_||_/__/\__\__,_|_||_\__\___|
 | |__ _ _  _ _ _  __| |_  ___ _ _
 | / _` | || | ' \/ _| ' \/ -_) '_|
 |_\__,_|\_,_|_||_\__|_||_\___|_|

Checking for dependencies:
  aws... \o/
  jq... \o/
Verifying AWS credentials work... \o/
Uploading /Users/foo/.ssh/id_rsa.pub to AWS... \o/
Launching instance... \o/
Waiting for a public IP.... \o/
Tagging instances...  \o/

Your instance has been successfully created:
  EC2 instance ID: i-07c8c0b4476788axf
  Instance name: foo-dev-17-02-17
  Public ip: 52.14.72.34
  Remote key name: foo.ssh
  Note: although the remote key name doesn't match your local
        key name, the contents will container either:
        - ~/.ssh/id_rsa.pub
           OR
        - $SSH_PUBLIC_KEY_FILE if you specified it before
              launching an instance (as mentioned in the docs)

To connect, wait a few minutes for the instance to finish spinning up,
and then run:
ssh -i /Users/foo/.ssh/id_rsa ubuntu@52.14.72.34

To stop the instance:
aws ec2 stop-instances --instance-ids "i-07c8c0b4476788axf" --region "us-east-2"

To (re)start the instance:
aws ec2 start-instances --instance-ids "i-07c8c0b4476788axf" --region "us-east-2"

To terminate the instance:
aws ec2 terminate-instances --instance-ids "i-07c8c0b4476788axf" --region "us-east-2"

$ ssh -i /Users/foo/.ssh/id_rsa ubuntu@52.14.72.34
The authenticity of host '52.14.72.34 (52.14.72.34)' can't be established.
ECDSA key fingerprint is SHA256:GmKa2xxZ0kMtMv8dXLZVXNDDoXtsdiITwqknf9bJUuM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.14.72.34' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-57-generic x86_64)
...

```

### Optional environment variables<a name="envvars"></a>

- `EC2_INSTANCE_SIZE`
	- defaults to Ubuntu Server 16.04 LTS (HVM), SSD Volume Type for us-east-2
	- see a full list of instance types [here](https://aws.amazon.com/ec2/instance-types/)
- `EC2_AMI`
- `SSH_PUBLIC_KEY_FILE`
	- defaults to `~/.ssh/id_rsa.pub`
- `SSH_PRIVATE_KEY_FILE`
	- defaults to `~/.ssh/id_rsa`
- `AWS_REGION`
	- defaults to `us-east-2`
	- the current developer security policy restricts access to this region only.
	
	
**Example**

```
$ export AWS_USER="foo"
$ export EC2_INSTANCE_SIZE="t2.micro"
$ export EC2_AMI="ami-fcc19b99"
$ export SSH_PUBLIC_KEY_FILE=~/.ssh/some_key.pub
$ export SSH_PRIVATE_KEY_FILE=~/.ssh/some_key
$ ./launch_instance.sh

```

## Post launch

### Stopping/restarting an instance

```
aws ec2 stop-instances --instance-ids <value>
aws ec2 start-instances --instance-ids <value>
```

### Terminating an instance

```
aws ec2 terminate-instances --instance-ids <value>
```