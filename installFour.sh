#!/bin/bash

## This is your playground

BASH_DIR=`which bash`
BIN_DIR=`dirname $BASH_DIR`
GIT_APP=git
CURL_APP=curl
PHP_APP=php
UNZIP_APP=unzip
SUDO_APP=sudo
COMPOSER_APP=composer
PHPUNIT_APP=phpunit
PHPUNIT_DIR=/etc/phpunit
PHP_APP=php
INSTALL_DIR=$1
SITE_NAME=$2
TWITTERBOOTSTRAP=$3

#################################################################### 

function main() {
    checkSudo
    checkPHP
    checkWebserver
    checkParameters $INSTALL_DIR $SITE_DIR
    checkApp $GIT_APP
    checkApp $CURL_APP
    [ "$TWITTERBOOTSTRAP" == "YES" ] && checkApp $UNZIP_APP installUnzip
    checkComposer $INSTALL_DIR
    checkPHPUnit
    checkMCrypt
    downloadSkeleton
    # configureExtraPackages
    [ "$TWITTERBOOTSTRAP" == "YES" ] && installTwitterBootstrap
    createVirtualHost $INSTALL_DIR
}

function installTwitterBootstrap() {
    wget --output-document=/tmp/twitter.bootstrap.zip http://twitter.github.com/bootstrap/assets/bootstrap.zip
    rm -rf /tmp/tb
    unzip /tmp/twitter.bootstrap.zip -d /tmp/tb
    cp -a /tmp/tb/bootstrap/css $INSTALL_DIR/public
    cp -a /tmp/tb/bootstrap/js $INSTALL_DIR/public
    cp -a /tmp/tb/bootstrap/img $INSTALL_DIR/public

    rm $INSTALL_DIR/app/views/hello.php
    mkdir $INSTALL_DIR/app/views/layouts
    mkdir $INSTALL_DIR/app/views/views

    wget --output-document=$INSTALL_DIR/app/views/layouts/main.blade.php -N https://raw.github.com/antonioribeiro/l4i/master/layout.main.blade.php
    wget --output-document=$INSTALL_DIR/app/views/views/home.blade.php -N https://raw.github.com/antonioribeiro/l4i/master/view.home.blade.php

    perl -pi -e "s/hello/views.home/g" $INSTALL_DIR/app/routes.php
}

function installUnzip() {
    $SUDO_APP apt-get --yes unzip $1 &> /dev/null
    $SUDO_APP yum --assumeyes unzip $1 &> /dev/null
}

function getIPAddress() {
    IPADDRESS=`$SUDO_APP ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1`
}

function createVirtualHost() {
    if [ $WEBSERVER == "apache2" ]; then
        $SUDO_APP rm /etc/apache2/sites-available/$SITE_NAME
        echo "Alias /$SITE_NAME \"$INSTALL_DIR/public\"" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "<Directory $INSTALL_DIR>" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "  Options Indexes Includes FollowSymLinks MultiViews" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "  AllowOverride AuthConfig FileInfo" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "  Order allow,deny" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "  Allow from all" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null
        echo "</Directory>" | $SUDO_APP tee -a /etc/apache2/sites-available/$SITE_NAME &> /dev/null

        $SUDO_APP a2ensite $SITE_NAME
        $SUDO_APP service apache2 restart
        getIPAddress
        echo "You Laravel 4 installation should be availabel now at http://$IPADDRESS/$SITE_NAME"
    fi
}

function configureExtraPackages() {
    wget --output-document=/tmp/json.edit.php -N https://raw.github.com/antonioribeiro/l4i/master/json.edit.php

    $PHP_APP /tmp/json.edit.php $INSTALL_DIR "raveren/kint" "dev-master"
    $PHP_APP /tmp/json.edit.php $INSTALL_DIR "meido/html" "1.1.*"
    $PHP_APP /tmp/json.edit.php $INSTALL_DIR "meido/form" "1.1.*"

    addAppProvider "Meido\\\Form\\\Providers\\\FormServiceProvider"
    addAppProvider "Meido\\\HTML\\\Providers\\\HTMLServiceProvider"

    addAppAlias "Form" "Meido\\\Form\\\Facades\\\Form"
    addAppAlias "HTML" "Meido\\\HTML\\\Facades\\\HTML"

    $SUDO_APP chmod -R 777 $INSTALL_DIR/app/storage/

    composerUpdate
}

function checkPHP() {
    php=`$PHP_APP -v` &> /dev/null
    checkErrors "PHP is not installed. Aborted."

    echo "PHP is installed."
}

function checkPHPUnit() {
    phpunit=`which $PHPUNIT_APP`
    if [ "$phpunit" == "" ]; then
        installPHPUnit
    fi
}

function installPHP() {
    sudo apt-get --yes intall php5 
}

function checkWebserver() {
    WEBSERVER=
    webserver=`ps -eaf |grep apache2 |grep -v grep |wc -l` && [ "$webserver" -gt "0" ] && WEBSERVER=apache2
    webserver=`ps -eaf |grep nginx |grep -v grep |wc -l` && [ "$webserver" -gt "0" ] && WEBSERVER=nginx
    webserver=`ps -eaf |grep lighthttpd |grep -v grep |wc -l` && [ "$webserver" -gt "0" ] && WEBSERVER=lighttpd

    if [ "$WEBSERVER" == "" ]; then
        echo "Looks like there is no webserver software intalled or runnig. Aborted."
        exit 1
    fi

    echo "Webserver ($WEBSERVER) is installed."
}

function installPHPUnit() {
    if [ "$CAN_I_RUN_SUDO" == "YES" ]; then
        $SUDO_APP mkdir -p $PHPUNIT_DIR
        $SUDO_APP chmod 777 $PHPUNIT_DIR
        echo '{' > $PHPUNIT_DIR/composer.json
        echo '    "name": "phpunit",' >> $PHPUNIT_DIR/composer.json
        echo '    "description": "PHPUnit",' >> $PHPUNIT_DIR/composer.json
        echo '    "require": {' >> $PHPUNIT_DIR/composer.json
        echo '        "phpunit/phpunit": "3.7.*"' >> $PHPUNIT_DIR/composer.json
        echo '    },' >> $PHPUNIT_DIR/composer.json
        echo '    "config": {' >> $PHPUNIT_DIR/composer.json
        echo '        "bin-dir": "$PHPUNIT_DIR"' >> $PHPUNIT_DIR/composer.json
        echo '    }' >> $PHPUNIT_DIR/composer.json
        echo '}' >> $PHPUNIT_DIR/composer.json
        cd $PHPUNIT_DIR
        composerUpdate $PHPUNIT_DIR
        $SUDO_APP chmod +x $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit
        $SUDO_APP ln -s $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit $BIN_DIR/$PHPUNIT_APP
    fi 
}

function installComposer() {
    echo "Trying to install composer..."
    cd $INSTALL_DIR
    perl -pi -e "s/;suhosin.executor.include.whitelist =$/suhosin.executor.include.whitelist = phar/g" /etc/php5/cli/conf.d/suhosin.ini
    curl -s http://getcomposer.org/installer | $PHP_APP
    checkErrors "Composer installation failed. Aborted."

    COMPOSER_APP=$BIN_DIR/composer
    $SUDO_APP mv composer.phar $COMPOSER_APP
    $SUDO_APP chmod +x $COMPOSER_APP
}

function checkComposer() {
    checkComposerInstalled
    if [ "$RETURN_VALUE" != "TRUE" ]; then
        installComposer
        checkComposerInstalled
        if [ "$RETURN_VALUE" != "TRUE" ]; then
            echo "composer is not installed and I was not able to install it"
        fi
    fi

    if [ "$RETURN_VALUE" == "TRUE" ]; then
        echo "Found composer at $COMPOSER_PATH."
    fi
}

function checkComposerInstalled() {
    [[ -f $COMPOSER_APP ]] && COMPOSER_PATH=$COMPOSER_APP

    [[ -z "$COMPOSER_PATH" ]] && COMPOSER_PATH=`which $COMPOSER_APP`
    [[ -z "$COMPOSER_PATH" ]] && COMPOSER_PATH=`which $COMPOSER_APP.phar`

    for element in $INSTALL_DIR $BIN_DIR /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
    do
        [[ -z "$COMPOSER_PATH" ]] && [ -f $element/$COMPOSER_APP ] && COMPOSER_PATH="$element/$COMPOSER_APP"
        [[ -z "$COMPOSER_PATH" ]] && [ -f $element/$COMPOSER_APP ] && COMPOSER_PATH="$element/$COMPOSER_APP.phar"
    done
    
    if [[ -z "$COMPOSER_PATH" ]]; then
        RETURN_VALUE=FALSE
    else 
        RETURN_VALUE=TRUE
    fi
}

function downloadSkeleton() {
    #git clone -b develop https://github.com/laravel/laravel.git $INSTALL_DIR
    #git clone https://github.com/niallobrien/laravel4-template.git $INSTALL_DIR

    wget -N --output-document=/tmp/laravel-develop.zip https://github.com/laravel/laravel/archive/develop.zip
    unzip /tmp/laravel-develop.zip -d $INSTALL_DIR
    mv $INSTALL_DIR/laravel-develop/* $INSTALL_DIR
    mv $INSTALL_DIR/laravel-develop/.git* $INSTALL_DIR
    rm -rf $INSTALL_DIR/laravel-develop/
    
    perl -pi -e "s/\`/\'/g" $INSTALL_DIR/app/config/app.php
}

function installApp() {
    if [ "CAN_I_RUN_SUDO" == "YES"]; then
        $SUDO_APP apt-get --yes install $1 &> /dev/null
        $SUDO_APP yum --assumeyes install $1 &> /dev/null
    else 
        #try to install anyway
        apt-get --yes install $1 &> /dev/null
        yum --assumeyes install $1 &> /dev/null
    fi
}

function checkMCrypt() {
    $SUDO_APP apt-get --yes install php5-mcrypt &> /dev/null
    $SUDO_APP yum --assumeyes install php5-mcrypt &> /dev/null
}

function checkApp() {
    if [ "$2" == "" ]; then
        installer=installApp
    else 
        installer=$2
    fi

    if ! type -p $1 > /dev/null; then
        echo -n "Trying to install $1..."
        $installer $1 &> /dev/null
        if ! type -p $1 > /dev/null; then
            echo ""
            echo ""
            echo "Looks like $1 is not installed or not available for this application."
            exit 0
        fi
        echo " done."
    else 
        echo "$1 is installed and available."
    fi
}

function checkErrors() {
    if [ $? -gt 0 ]; then
        echo $1
        exit 1
    fi
}

function checkParameters() {
    if [ ! $INSTALL_DIR ]; then
        showUsage
        echo "----> You need to provide installation directory (example: /var/www/myapp)."
        echo
        exit 1
    fi

    if [ ! $SITE_NAME ]; then
        showUsage
        echo "----> You need to provide a site name (myapp)."
        echo
        exit 1
    fi

    if [ ! $TWITTERBOOTSTRAP ]; then
        showUsage
        echo "----> Twitter Bootstrap install parameter was not provided."
        echo
        exit 1
    fi

    if [ -f $INSTALL_DIR ]; then
       echo "You provided a regular file name, not a directory, please specify a directory."
       exit 1
    fi

    if [ -d $INSTALL_DIR ]; then
        if [ "$(ls -A $1)" ]; then
           echo "Directory $1 is not empty."
           exit 1
        fi
    else 
        mkdir $INSTALL_DIR
        checkErrors "Error creating directory $INSTALL_DIR"
    fi
}

function checkSudo {
    if [[ $EUID -ne 0 ]]; then
        echo "Your sudo password is required for some commands."
        sudo -k
        sudo echo -n 
        CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
        [ ${CAN_I_RUN_SUDO} -gt 0 ] && CAN_I_RUN_SUDO="YES" || CAN_I_RUN_SUDO="NO"
    else 
        # user is root, no need to run sudo
        CAN_I_RUN_SUDO=YES
        SUDO_APP=
    fi
}

function showUsage() {
    echo
    echo
    echo "installFour script"
    echo "  Installs a Laravel 4 development environment"
    echo
    echo "     Usage:  bash installFour <directory> <site name> <install twitter bootstrap template?>"
    echo
    echo "  Examples:  bash installFour /var/www/blog/ blog YES"
    echo "             bash installFour /home/taylor/www blog NO"
    echo "             bash installFour /var/www/blog/ myBlog YES"
    echo
    echo
}

function addAppProvider() {
    perl -pi -e "s/WorkbenchServiceProvider',/WorkbenchServiceProvider',\n\t\t'$1',/g" $INSTALL_DIR/app/config/app.php
}

function addAppAlias() {
    perl -pi -e "s/View',/View',\n\t\t'$1'       \=\> '$2',/g" $INSTALL_DIR/app/config/app.php
}

function composerUpdate() {
    [ "$1" == "" ] && directory=$INSTALL_DIR || directory=$1
    cd $directory
    $COMPOSER_APP install
    $COMPOSER_APP update
    $COMPOSER_APP dump-autoload
}

clear
main $1
