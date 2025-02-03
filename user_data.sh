#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enaable httpd
echo "<h1>Hello from is  $(hostname -f) EC2 instance </h1>" > /var/www/html/index.html
