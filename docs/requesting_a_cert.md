# Requesting an ACM certificate

### (non-SRE's) If you don't have access to AWS ACM

1. Create a new [Github issue](https://github.com/mozmar/infra) (or use an existing issue) and mention [@jgmize](https://github.com/jgmize) and [@metadave](https://github.com/metadave) saying that you would like to request a certificate. Please list ALL domains that you are requesting (including wildcard if needed).
2. Once the request has been received, we'll prioritize and notify you when the request is complete.

### (SRE's) If you have access to AWS ACM

1. Create a [Github issue](https://github.com/mozmar/infra) (or use an existing issue) and mention [@jgmize](https://github.com/jgmize) and [@metadave](https://github.com/metadave) saying that you would like to request a certificate. Please list ALL domains that you are requesting (including wildcard if needed).
2. from the AWS console, select the `Certificate Manager` app
3. click the `Request a certificate` button at the top left
4. Enter the domain names specified in the issue from step 1.
5. Click the `Review and request` button.
6. Click the `Confirm and request` button.
7. An email is now sent from AWS to the hostmaster (@jgmize in MozMEAO, and some additional admins from #webops). The domain admin needs to click the link in the email approving the new certificate(s).
8. The SRE that approved the cert should reply to the hostmaster email group that received the notification, stating that it has been approved.
9. An SRE will send you a GPG encrypted email containing the new cert and key.
10. An SRE can update and close the original Github issue requesting the certificate.

---

### Domains we manage

The list of domains we manage for ACM is as follows:

- .moz.works

