#!/bin/bash
#
#------------------
# Generate a vhost, user, db table and credentials for local development
# GT - August 2019
# ------------------

root_db_pass="<INSERT_YOUR_DB_ROOT_PASS_HERE>"
#always run as sudo
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "You must run this with privileges. Use sudo ./create_account.sh"
    exit
fi


echo "Type the domain that you want to create locally on this server eg. dev.hiphopshop.gr"
read domain_name

echo "Create a username for this domain:"
read domain_user

# Check if user exists
while  id -u $domain_user > /dev/null 2>&1; do
    echo "User already exists please choose a different username:"  
    read domain_user
done

echo "Type in the Database Name (DB User will have the same name):"
read database_name
database_user=$database_name
#echo "Type in the Database Password:"
#read database_pass

#generate user password
domain_user_password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

#generate db password
database_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

#CREATE THE DATABASE
SQL_QUERY="CREATE DATABASE ${database_name};CREATE USER '${database_user}' IDENTIFIED BY '${database_pass}'; GRANT USAGE ON *.* TO '${database_user}'@localhost IDENTIFIED BY '${database_pass}'; GRANT USAGE ON *.* TO '${database_user}'@'%' IDENTIFIED BY '${database_pass}'; GRANT ALL privileges ON ${database_name}.* TO '${database_user}'@localhost; FLUSH PRIVILEGES;"


#debug for ${SQL_QUERY}"
#echo "SQL_QUERY ${SQL_QUERY}"
#EXECUTE THE SQL QUERY
echo "${SQL_QUERY}" | /usr/bin/mysql -u root -p${root_db_pass}

#CREATE THE USER
adduser $domain_user
usermod -a -G apache $domain_user
echo -e "$domain_user_password\n$domain_user_password"  | passwd $domain_user
mkdir /var/www/$domain_name
mkdir /var/www/$domain_name/public_html
chown -R $domain_user:apache /var/www/$domain_name
usermod -m -d /var/www/$domain_name $domain_user

#CREATE THE virtual host conf file
cat << EOF > /etc/httpd/vhosts/${domain_name}
<VirtualHost *:80>
    ServerName ${domain_name}
    ServerAlias www.${domain_name}
    ServerAdmin webmaster@${domain_name}
    DocumentRoot /var/www/${domain_name}/public_html

    <Directory /var/www/${domain_name}/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
    </Directory>

    ErrorLog /var/log/httpd/${domain_name}-error.log
    CustomLog /var/log/httpd/${domain_name}-access.log combined
</VirtualHost>
EOF
#RESTARTING APACHE FOR THE NEW VIRTUAL HOST
systemctl restart httpd.service

#NOTIFY THE USER ON HOW TO CONNECT
echo ""
echo ""
echo "--------------------"
echo "DATABASE CREDENTIALS"
echo "DB Name: $database_name"
echo "DB user: $database_user"
echo "DB Password: $database_pass"
echo "--------------------"
echo ""
echo ""
echo "--------------------"
echo "In order to connect through SSH/SFTP use the following credentials: "
echo "IP: 192.168.1.200"
echo "username: $domain_user"
echo "password: $domain_user_password"
echo "--------------------"
echo ""
echo ""
echo "add this live to your HOSTS FILE: "
echo "192.168.1.200 $domain_name"
echo "after you have modified your hosts file\nyou can visit http://$domain_name"
echo "PHPmyadmin https://192.168.1.200/phpmyadmin/ (using your DB credentials)"
echo ""
echo ""