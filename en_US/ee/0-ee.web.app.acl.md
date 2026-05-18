# Access control for web applications

To limit access from certain IP addresses/networks, please login to EE as
global admin, click `Server Settings` -> `Web Applications`, then click the
link `Access Control` right beside the web application name:

![](./images/ee/web-app-acl-1.png){: width="800px" }

Input the allowed IP addresses or CIDR networks, click `Save Changes`:
![](./images/ee/web-app-acl-2.png){: width="800px" }

After saved, it will show you `Allow access from X IP addresses or networks`:
![](./images/ee/web-app-acl-3.png){: width="800px" }

Click `Apply Now` on bottom-right corner to actually apply saved changes, it
will add ACL in Nginx config files for access control.
