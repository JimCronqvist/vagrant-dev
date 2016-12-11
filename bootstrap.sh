#!/usr/bin/env bash

echo "-------------------------------------"
echo "------------ Bootstrap --------------"
echo "-------------------------------------"

# Ensure we use the closest mirror for apt-get
RELEASE=$(lsb_release -cs)
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt ${RELEASE} main restricted universe multiverse" > /tmp/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt ${RELEASE}-updates main restricted universe multiverse" >> /tmp/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt ${RELEASE}-backports main restricted universe multiverse" >> /tmp/sources.list
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt ${RELEASE}-security main restricted universe multiverse" >> /tmp/sources.list
echo "" >> /tmp/sources.list
cat /etc/apt/sources.list >> /tmp/sources.list
cp /tmp/sources.list /etc/apt/sources.list

# Download needed installation files
cd ~ && rm -f ~/install.sh && wget https://raw.githubusercontent.com/JimCronqvist/ubuntu-scripts/master/install.sh && chmod +x install.sh
cd ~ && rm -f ~/vhost.sh && wget https://raw.githubusercontent.com/JimCronqvist/ubuntu-scripts/master/vhost.sh && chmod +x vhost.sh

# Install the server
./install.sh -o 1  # Step: Install all available updates
./install.sh -o 3  # Step: Basic installation
./install.sh -o 7  # Step: Install webtools (git, npm, uglify)
./install.sh -o 8  # Step: Install Apache2
./install.sh -o 10 # Step: Install PHP7 + Composer
./install.sh -o 15 # Step: Install Redis

# Apache2 configurations
a2enmod vhost_alias
a2enmod proxy_http

cat <<EOF > /etc/apache2/sites-available/general.conf
<VirtualHost *:80>
	UseCanonicalName Off
	ServerName x.localhost
	ServerAlias *.locahost
	VirtualDocumentRoot /var/www/%1/public

	<Directory "/var/www/*/public">
		Options -Indexes +FollowSymLinks
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>

	RewriteEngine on
	RewriteCond %{HTTP_HOST} ^(.*)\.localhost$ [NC]
	RewriteCond /var/www/%1/public/ !-d
	RewriteRule (.*) http://localhost/%1\$1 [P,L]
	#RewriteRule (.*) http://localhost/%1\$1 [L,R=302]

	ErrorLog /error.log
	CustomLog /access.log combined
</VirtualHost>
EOF

a2ensite general.conf
./vhost.sh localhost /var/www
sed -i 's/-Indexes/+Indexes/' /etc/apache2/sites-enabled/localhost.conf
service apache2 reload

# Run custom install scripts if any exist
DIR=$(dirname "$(readlink -f "$0")")
echo $DIR
for i in {1..9}
do
	INSTALL_FILENAME=$DIR"/install"$i".sh"
	if [ -f $INSTALL_FILENAME ]; then
		echo "$INSTALL_FILENAME was found, executing:"
		bash $INSTALL_FILENAME
	fi
done

echo "The script has now completed and you are ready to go!"