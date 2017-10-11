# Blocking an IP address

1. login to the AWS console
2. ensure you are in the `Oregon` region
3. search and select the `VPC` service in the AWS console
4. select `Network ACLs` from the navigation on the left side of the page
5. select the row containing the `portland.moz.works` VPC
6. click on the `Inbound Rules` tab
7. click `Edit`
8. click `Add another rule`
9. for `Rule#`, select a value < 100 and > 0
10. for `Type`, select `All Traffic`
11. for `Source`, enter the IP address in CIDR format. To block a single IP, append `/32` to the IP address.
    1. example: `196.52.2.54/32`    
12. for `Allow / Deny`, select `DENY`
13. click `Save`

There are limits that apply to using VPC ACLs documented [here](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Appendix_Limits.html#vpc-limits-nacls).

