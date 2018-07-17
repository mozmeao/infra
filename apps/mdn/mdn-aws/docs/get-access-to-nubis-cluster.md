# Getting access to the MDN Nubis cluster

[Nubis][nubis-project] uses Amazon Web Services (AWS)
[Identify and Access Management][iam] (IAM) keys to grant access and
permission. For more information, see the
[nubis-deploy documentation][nubis-deploy-docs].

[nubis-project]: https://github.com/nubisproject
[iam]: https://aws.amazon.com/iam/
[nubis-deploy-docs]: https://github.com/nubisproject/nubis-deploy/blob/develop/SECURITY.md

## IAM key installation with aws-vault
As a developer, your IAM credentials would be created by a Nubis cluster
administrator, and sent encrypted using your public PGP key. See
[mana.mozilla.org][mana-gpg] for more information on generating and publishing a
public PGP key.

[mana-gpg]: https://mana.mozilla.org/wiki/x/-Q-5AQ

In May 2018, Ed Lim emailed me (jwhitlock) credentials as two files:

* ``mozilla-mdn.kubeconfig.asc`` - PGP-encoded Kubernetes configuration
* ``jwhitlock-iam.asc`` - PGP-encoded IAM credentials

From previous efforts I already had:

* Tools installed with [Homebrew][homebrew]:
  - ``kubectl``, for Kubernetes access
  - ``gnupg``, for ``gpg``
  - ``pinentry-mac``, for a GUI entry for gpg passphrases
  - ``wget``, to download files
* A folder ``~/.kube/`` for Kubernetes configuration files
* Google Authenticator on my phone for 2-factor authentication (2FA) with a
  one-time password (OTP). Authy is another popular choice.

I used ``gpg`` to decrypt the files:

```
gpg -d mozilla-mdn.kubeconfig.asc > ~/.kube/mozilla-mdn.config
gpg -d jwhitlock-iam.asc  #  output to terminal
```

The ``keybase`` equivalent would be:

```
keybase pgp decrypt --infile mozilla-mdn.kubeconfig.asc --outfile ~/.kube/mozilla-mdn.config
keybase pgp decrypt --infile jwhitlock-iam.asc
```

I used ``wget`` to fetch Ed's helper script [aws-vault-setup][setup-gist]:

```
wget https://gist.githubusercontent.com/limed/de59cf0dfe4d42ce6d17dea8a08e82e3/raw/8cce9c4986604695dee5274dc93db201c69bd1fe/aws-vault-setup
bash aws-vault-setup
```

[setup-gist]: https://gist.github.com/limed/de59cf0dfe4d42ce6d17dea8a08e82e3

This checks that the prerequisites are installed:

* [aws-vault](https://github.com/99designs/aws-vault)
* [jq](https://github.com/stedolan/jq) (available in Homebrew)
* [aws](https://aws.amazon.com/cli/)

After installing the prerequisites and re-running, the script prompted for some
parameters:

```
AWS Access Key ID: <First line of iam>
AWS Secret Access Key: <Second line of iam file>
AWS Account name: mozilla-mdn
LDAP UID (not your email address): jwhitlock
```

I was prompted to create a password for ``aws-vault``. The output was:

```
Adding mozilla-mdn to aws-vault
Added credentials to profile "mozilla-mdn" in vault
Creating virtual mfa device

Setting up AWS config file
Everything setup using and OTP app scan the QR code generated in the jwhitlock.png file
Once your account has been added to your OTP app, run this command to complete setup:
    aws-vault exec -n mozilla-mdn -- aws iam enable-mfa-device --user-name jwhitlock --serial-number arn:aws:iam::<some_numbers>:mfa/jwhitlock --authentication-code-1 <auth code 1> --authentication-code-2 <auth code 2>

Check your OTP app for <auth code 1> and <auth code 2>
```

The ``--serial-number`` option in the long command matched the third line of
the encrypted IAM file. I opened the PNG file and scanned it into Google
Authenticator:

```
open jwhitlock.png
```

This created a new entry for Amazon Web Services, jwhitlock@mozilla-mdn.  I got
a 6-digit authentication code, waited a few seconds, and got a second code, and
ran the suggested command. There was no output.

I then tried ``aws-vault login mozilla-mdn-admin``. I was prompted for my
aws-vault keychain password, and then on the command line:

```
Enter token for arn:aws:iam::<numbers>:mfa/jwhitlock:
```

I entered by 6-digit code from Authenticator, and it opened a webpage on
aws.amazon.com that told me I need to log out of AWS first. I logged out by
following the link, and ran ``aws-vault login mozilla-mdn-admin`` again. There
was no prompt for the keychain password, just for the MFA token. This time, I
was logged into the AWS website. After switching the region to US West
(Oregon), I could see the EC2 instances.

``aws-vault exec mozilla-mdn-admin aws s3 ls`` worked (after MFA prompt), and
showed the S3 buckets.

``aws-vault exec mozilla-mdn-admin`` prompted for the keychain password, and
opened a local bash shell. There was a ``AWS_SECURITY_TOKEN``" in the
environment.

I could then run:

``KUBECONFIG=~/.kube/mozilla-mdn.config kubectl -n default get namespaces``

with the output (at the time):
```
NAME          STATUS    AGE
default       Active    1d
kube-public   Active    1d
kube-system   Active    1d
```

# Access with the SSO dashboard

The Single Sign-on (SSO) Dashboard can also be used to logs, graphs, reports, and AWS:

https://sso.core.us-west-2.mozilla-mdn.nubis.allizom.org

The dashboard is available through Mozilla's SSO login to users in the LDAP
group ``team_mdn``. Logout may be required to apply LDAP changes to your
account.
