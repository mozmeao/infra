# MDN infra provisioning

The scripts in this directory are for provisioning MDN clusters.

### Prerequisites:

- `terraform`
- `jq`
- `awscli` w/ creds via the AWS metadata service OR `~/.aws/credentials configured`
	- we prefer to use the AWS metadata service so credentials aren't left on disk.


### Usage

```
./provision.sh
```