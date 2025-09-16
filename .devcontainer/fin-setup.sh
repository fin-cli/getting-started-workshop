#!  /bin/bash

#Site configuration options
SITE_TITLE="Workshop - Getting Started with FIN-CLI"
ADMIN_USER=admin
ADMIN_PASS=password
ADMIN_EMAIL="admin@localhost.com"
#Space-separated list of plugin ID's to install and activate
PLUGINS="hello-dolly"

#Set to true to wipe out and reset your wordpress install (on next container rebuild)
FIN_RESET=true

echo "Setting up WordPress"
DEVDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd /var/www/html;
if $FIN_RESET ; then
    echo "Resetting FIN"
    fin plugin delete $PLUGINS
    fin db reset --yes
    rm fin-config.php;
fi

if [ ! -f fin-config.php ]; then 
    echo "Configuring";
    fin config create --dbhost="db" --dbname="wordpress" --dbuser="fin_user" --dbpass="fin_pass" --skip-check;
    fin core install --url="http://localhost:8080" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASS" --skip-email;
    fin plugin install $PLUGINS --activate

    #Data import
    cd $DEVDIR/data/
    for f in *.sql; do
        fin db import $f
    done

    cp -r plugins/* /var/www/html/fin-content/plugins
    for p in plugins/*; do
        fin plugin activate $(basename $p)
    done

else
    echo "Already configured"
fi