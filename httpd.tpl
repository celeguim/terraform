#!/bin/bash
yum update -y
yum install httpd php -y
service httpd start
chkconfig httpd on

echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
echo "<?php echo gethostname(); ?>" > /var/www/html/hostname.php

