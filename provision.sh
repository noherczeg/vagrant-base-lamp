#!/bin/bash

apache_config_file="/etc/apache2/envvars"
apache_vhost_file="/etc/apache2/sites-available/vagrant_vhost.conf"
php_config_file="/etc/php/5.6/apache2/php.ini"
xdebug_config_file="/etc/php/5.6/mods-available/xdebug.ini"
mysql_config_file="/etc/mysql/mysql.conf.d/mysqld.cnf"
default_apache_index="/var/www/html/index.html"

# This function is called at the very bottom of the file
main() {
	repositories_go
	update_go
	server_go
	tools_go
	apache_go
	mysql_go
	php_go
	autoremove_go
}

repositories_go() {
	add-apt-repository ppa:ondrej/php
}

server_go() {
	# Additional Locales
	locale-gen hu_HU
	locale-gen hu_HU.UTF-8
	update-locale
}

update_go() {
	# Update the server
	apt-get update
}

autoremove_go() {
	apt-get -y autoremove
}

tools_go() {
	# Install basic tools
	apt-get -y install build-essential binutils-doc git
}

apache_go() {
	# Install Apache
	apt-get -y install apache2

	sed -i "s/^\(.*\)www-data/\1vagrant/g" ${apache_config_file}
	sed -i 's/vagrant/ubuntu/g' ${apache_config_file}
	chown -R ubuntu:ubuntu /var/log/apache2

	if [ ! -f "${apache_vhost_file}" ]; then
	    cat /vagrant/provision-files/apache.conf > ${apache_vhost_file}
	fi

	a2dissite 000-default
	a2ensite vagrant_vhost

	a2enmod rewrite

	systemctl restart apache2.service
}

php_go() {
	apt-get -y install php5.6 php5.6-curl php5.6-mysql php5.6-sqlite php5.6-xdebug php5.6-mbstring php5.6-mcrypt php5.6-xml php5.6-apcu

	sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${php_config_file}
	sed -i "s/display_errors = Off/display_errors = On/g" ${php_config_file}

	if [ ! -f "{$xdebug_config_file}" ]; then
	    cat /vagrant/provision-files/xdebug.conf > ${xdebug_config_file}
	fi

	systemctl restart apache2.service

	# Install latest version of Composer globally
	if [ ! -f "/usr/local/bin/composer" ]; then
		curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
	fi
}

mysql_go() {
	# Install MySQL
	echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
	echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
	apt-get -y install mysql-client mysql-server

	sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${mysql_config_file}

	# Allow root access from any host
	echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
	echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

	if [ -d "/vagrant/provision-sql" ]; then
		echo "Executing all SQL files in /vagrant/provision-sql folder ..."
		echo "-------------------------------------"
		for sql_file in /vagrant/provision-sql/*.sql
		do
			echo "EXECUTING $sql_file..."
	  		time mysql -u root --password=root < $sql_file
	  		echo "FINISHED $sql_file"
	  		echo ""
		done
	fi

	systemctl restart mysql.service
}

main
exit 0
