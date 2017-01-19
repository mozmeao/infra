## Dev node provisioning

This Terraform file is used to create an AWS Linux dev node for deploying via kops etc. It includes Docker, kops, kubectl, and jq.

Simply run:

```
terraform apply
```

and fill in the prompts.

If you'd like to see what's going to be created, run this first:

```
terraform plan
```

It's highly recommended that you install 2fa for your new dev node, [this](https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-14-04) article makes it short and easy to setup.
