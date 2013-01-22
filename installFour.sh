#!/bin/bash

## This is your playground
L4I_VERSION=1.3.0
L4I_BRANCH=v1.3.0
L4I_REPOSITORY="-b $L4I_BRANCH https://github.com/antonioribeiro/l4i.git"
L4I_REPOSITORY_DIR=/tmp/l4i
L4I_REPOSITORY_GIT="$L4I_REPOSITORY_DIR/git"
LARAVEL_APP_BRANCH=" -b develop "
LARAVEL_APP_REPOSITORY="https://github.com/laravel/laravel.git"
BASH_DIR=`type -p bash`
BIN_DIR=`dirname $BASH_DIR`
GIT_APP=git
CURL_APP=curl
PHP_APP=php
UNZIP_APP=unzip
SUDO_APP=sudo
COMPOSER_APP=composer
ARTISAN_APP=artisan
PHPUNIT_APP=phpunit
PHPUNIT_DIR=/etc/phpunit
PHPUNIT_DIR_ESCAPED=`message $PHPUNIT_DIR | sed s,/,\\\\\\\\\\/,g`
PHP_APP=php
PHP_SUHOSIN_CONF=/etc/php5/cli/conf.d/suhosin.ini
PHP_MINIMUN_VERSION=5.2.0
INSTALL_DIR=$1
SITE_NAME=$2
INSTALL_DIR_ESCAPED="***will be set on checkParameters***"
LOG_FILE="***will be set on showLogFile***"
SUPPORTED_OPERATING_SYSTEMS="Debian|Ubuntu|Linux Mint|Redhat"

        EP_NAME=("raveren/kint" "meido/html"                          "meido/form"                          "meido/str"                        "machuga/authority"  "jasonlewis/basset"              "bigelephant/string"                            "cartalyst/sentry")
     EP_VERSION=("dev-master"   "1.1.*"                               "1.1.*"                               "dev-master"                       "dev-develop"        "dev-master"                     "dev-master"                                    "2.0.*")
  EP_ALIAS_NAME=(""             "HTML"                                "Form"                                "Str"                              ""                   "Basset"                         "String"                                        "Sentry")
EP_ALIAS_FACADE=(""             "Meido\\\HTML\\\HTMLFacade"           "Meido\\\Form\\\FormFacade"           "Meido\\\Str\\\StrFacade"          ""                   "Basset\\\Facades\\\Basset"      "BigElephant\\\String\\\StringFacade"           "Cartalyst\\\Sentry\\\Facades\\\Laravel\\\Sentry")
    EP_PROVIDER=(""             "Meido\\\HTML\\\HTMLServiceProvider"  "Meido\\\Form\\\FormServiceProvider"  "Meido\\\Str\\\StrServiceProvider" ""                   "Basset\\\BassetServiceProvider" "BigElephant\\\String\\\StringServiceProvider"  "Cartalyst\\\Sentry\\\SentryServiceProvider")

#################################################################### 
# kwnown errors 

#### composer -> The contents of https://packagist.org/p/providers-stale.json do not match its signature,
#### ** Usually this one is harmless and will not compromise your installation

#################################################################### 

function main() {
    showHeader
    cleanL4IRepository
    createLogDirectory

    checkOS
    checkParameters
    showLogFile 

    checkSudo
    getIPAddress

    checkPHP
    checkWebserver
    checkApp $CURL_APP
    checkApp $UNZIP_APP installUnzip
    checkApp $GIT_APP

    downloadL4IRepository

    checkComposer $INSTALL_DIR
    checkPHPUnit
    checkMCrypt
    downloadSkeleton
    installAdditionalPackages
    installOurArtisan
    composerUpdate
    installTwitterBootstrap
    createVirtualHost $INSTALL_DIR
    setGlobalPermissions
}

function downloadL4IRepository {
    message "Downloading l4i git repository..."
    git clone $L4I_REPOSITORY $L4I_REPOSITORY_GIT 2>&1 | tee -a $LOG_FILE &> /dev/null
    checkErrors "An error ocurred while trying to clone L4I git repository."
}

function installTwitterBootstrap() {
    inquireYN "Install Twitter Bootstrap? " "y" "n"
    if [ "$answer" == "y" ]; then 
        message "Installing Twitter Bootstrap..."
        wget --no-check-certificate -O $L4I_REPOSITORY_DIR/twitter.bootstrap.zip http://twitter.github.com/bootstrap/assets/bootstrap.zip 2>&1 | tee -a $LOG_FILE &> /dev/null
        rm -rf $L4I_REPOSITORY_DIR/twitter.bootstrap 2>&1 | tee -a $LOG_FILE &> /dev/null
        unzip $L4I_REPOSITORY_DIR/twitter.bootstrap.zip -d $L4I_REPOSITORY_DIR/twitter.bootstrap 2>&1 | tee -a $LOG_FILE &> /dev/null
        rm $L4I_REPOSITORY_DIR/twitter.bootstrap.zip
        cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/css $INSTALL_DIR/public
        cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/js $INSTALL_DIR/public
        cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/img $INSTALL_DIR/public

        rm $INSTALL_DIR/app/views/hello.php 2>&1 | tee -a $LOG_FILE &> /dev/null
        mkdir $INSTALL_DIR/app/views/layouts 2>&1 | tee -a $LOG_FILE &> /dev/null
        mkdir $INSTALL_DIR/app/views/views 2>&1 | tee -a $LOG_FILE &> /dev/null

        cp $L4I_REPOSITORY_GIT/layout.main.blade.php $INSTALL_DIR/app/views/layouts/main.blade.php  2>&1 | tee -a $LOG_FILE &> /dev/null
        cp $L4I_REPOSITORY_GIT/view.home.blade.php $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null

        perl -pi -e "s/hello/views.home/g" $INSTALL_DIR/app/routes.php 2>&1 | tee -a $LOG_FILE &> /dev/null
        perl -pi -e "s/%l4i_branch%/$L4I_BRANCH/g" $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null
        perl -pi -e "s/%l4i_version%/$L4I_VERSION/g" $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null
    fi
}

function installUnzip() {
    message "Installing unzip..."
    installPackage unzip
}

function getIPAddress() {
    IPADDRESS=`$SUDO_APP ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1`
    if [[ "$IPADDRESS" == "" ]]; then
        IPADDRESS=`$SUDO_APP ifconfig | sed -n 's/.*inet \([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1`
    fi
    if [[ "$IPADDRESS" == "" ]]; then
        inquireText "Please type the IP address of your box:"
        IPADDRESS=$answer
    fi
}

function createVirtualHost() {
    if [[ "$WEBSERVER" == "apache2" ]]; then
        message "Creating apache2 VirtualHost..."

        conf=$VHOST_CONF_DIR/$VHOST_CONF_FILE

        $SUDO_APP cp $L4I_REPOSITORY_GIT/apache.directory.template $conf  2>&1 | tee -a $LOG_FILE &> /dev/null

        $SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" $conf  2>&1 | tee -a $LOG_FILE &> /dev/null
        $SUDO_APP perl -pi -e "s/%installDir%/$INSTALL_DIR_ESCAPED/g" $conf  2>&1 | tee -a $LOG_FILE &> /dev/null

        if [[ "$VHOST_ENABLE_COMMAND" != "" ]]; then
            $SUDO_APP $VHOST_ENABLE_COMMAND $SITE_NAME 2>&1 | tee -a $LOG_FILE &> /dev/null
        fi

        $SUDO_APP $WS_RESTART_COMMAND 2>&1 | tee -a $LOG_FILE &> /dev/null

        cp $INSTALL_DIR/public/.htaccess $INSTALL_DIR/public/.htaccess.ORIGINAL  2>&1 | tee -a $LOG_FILE &> /dev/null
        cp $L4I_REPOSITORY_GIT/htaccess.template $INSTALL_DIR/public/.htaccess  2>&1 | tee -a $LOG_FILE &> /dev/null

        $SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" $INSTALL_DIR/public/.htaccess  2>&1 | tee -a $LOG_FILE &> /dev/null

        message "Your Laravel 4 installation should be available now at http://$IPADDRESS/$SITE_NAME"
    fi
}

function installAdditionalPackages() {
    message "Configuring additional packages..."

    total=${#EP_NAME[*]}

    for (( i=0; i<=$(( $total -1 )); i++ ))
    do
        name="${EP_NAME[$i]}"
        version="${EP_VERSION[$i]}"
        alias_name="${EP_ALIAS_NAME[$i]}"
        alias_facade="${EP_ALIAS_FACADE[$i]}"
        provider="${EP_PROVIDER[$i]}"

        inquireYN "Do you wish to install package $name? " "y" "n"

        if [ "$answer" == "y" ]; then
             installComposerPackage $name $version $alias_name $alias_facade $provider
        fi        
    done    
}

function installComposerPackage() {
    $PHP_APP $L4I_REPOSITORY_GIT/json.edit.php $INSTALL_DIR $1 $2
    log "$PHP_APP $L4I_REPOSITORY_GIT/json.edit.php $INSTALL_DIR $1 $2"

    if [ "$3$4" != "" ]; then
        addAppAlias $3 $4
    fi

    if [ "$5" != "" ]; then
        addAppProvider $5
    fi
}

function checkPHP() {
    php=`$PHP_APP -v 2>&1 | tee -a $LOG_FILE &> /dev/null `
    checkErrors "PHP is not installed."

    echo "<?php echo PHP_VERSION;" > /tmp/phpver.php
    phpver=`php /tmp/phpver.php`

    if [[ "$phpver" < "$PHP_MINIMUN_VERSION" ]]; then
      abortIt "Your PHP version is $phpver, minumum required is $PHP_MINIMUN_VERSION."
    fi

    message "PHP $phpver is available."
}

function checkPHPUnit() {
    phpunit=`type -p $PHPUNIT_APP`
    if [ "$phpunit" == "" ]; then
        installPHPUnit
    fi
}

# function installPHP() {
#     # message "Installing PHP..."
#     # sudo apt-get --yes intall php5
# }

function locateWebserverProcess() {
    ws_process=
    ws_process=`$SUDO_APP ps -eaf |grep apache2 |grep -v grep |wc -l` && [ "$ws_process" -gt "0" ] && ws_process=apache2
    ws_process=`$SUDO_APP ps -eaf |grep nginx |grep -v grep |wc -l` && [ "$ws_process" -gt "0" ] && ws_process=nginx
    ws_process=`$SUDO_APP ps -eaf |grep lighthttpd |grep -v grep |wc -l` && [ "$ws_process" -gt "0" ] && ws_process=lighttpd
    ws_process=`$SUDO_APP ps -eaf |grep httpd |grep -v grep |wc -l` && [ "$ws_process" -gt "0" ] && ws_process=httpd
}

function checkWebserver() {
    locateWebserverProcess
    WEBSERVER=$ws_process
    VHOST_ENABLE_COMMAND=
    VHOST_CONF_DIR=/etc/apache2/sites-available
    VHOST_CONF_FILE=$SITE_NAME
    WS_RESTART_COMMAND="service $WEBSERVER restart"
    VHOST_ENABLE_COMMAND="a2ensite"

    if [[ "$WEBSERVER" == "" ]]; then
        abortIt "Looks like there is no webserver software intalled or runnig."
    fi

    if [[ "$WEBSERVER" == "httpd" ]]; then
        VHOST_CONF_DIR=/etc/httpd/conf.d
        VHOST_CONF_FILE=$SITE_NAME.conf
        VHOST_ENABLE_COMMAND=
        WEBSERVER=apache2 # httpd usually is also apache2, with some differences covered here
    fi

    message "Webserver ($WEBSERVER) is installed."
}

function installPHPUnit() {
    if [ "$CAN_I_RUN_SUDO" == "YES" ]; then
        message "Installing PHPUnit..."
        $SUDO_APP mkdir -p $PHPUNIT_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null
        $SUDO_APP chmod 777 $PHPUNIT_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null 
        $SUDO_APP cp $L4I_REPOSITORY_GIT/phpunit.composer.json $PHPUNIT_DIR/composer.json
        $SUDO_APP perl -pi -e "s/%phpunit_dir%/$PHPUNIT_DIR_ESCAPED/g" $PHPUNIT_DIR/composer.json  2>&1 | tee -a $LOG_FILE &> /dev/null
        cd $PHPUNIT_DIR
        composerUpdate $PHPUNIT_DIR
        $SUDO_APP chmod +x $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit 2>&1 | tee -a $LOG_FILE &> /dev/null
        $SUDO_APP ln -s $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit $BIN_DIR/$PHPUNIT_APP 2>&1 | tee -a $LOG_FILE &> /dev/null
    fi 
}

function installComposer() {
    message "Installing Composer..."
    cd $INSTALL_DIR
    if [ -f $PHP_SUHOSIN_CONF ]; then
        perl -pi -e "s/;suhosin.executor.include.whitelist =$/suhosin.executor.include.whitelist = phar/g" $PHP_SUHOSIN_CONF  2>&1 | tee -a $LOG_FILE &> /dev/null
    fi

    $CURL_APP -s http://getcomposer.org/installer | $PHP_APP
    checkErrors "Composer installation failed."

    COMPOSER_APP=$BIN_DIR/composer
    $SUDO_APP mv composer.phar $COMPOSER_APP  2>&1 | tee -a $LOG_FILE &> /dev/null
    $SUDO_APP chmod +x $COMPOSER_APP  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function checkComposer() {
    checkComposerInstalled
    if [ "$RETURN_VALUE" != "TRUE" ]; then
        installComposer
        checkComposerInstalled
        if [ "$RETURN_VALUE" != "TRUE" ]; then
            message "composer is not installed and I was not able to install it"
        fi
    fi

    if [ "$RETURN_VALUE" == "TRUE" ]; then
        message "Found composer at $COMPOSER_PATH."
    fi
}

function checkComposerInstalled() {
    [[ -f $COMPOSER_APP ]] && COMPOSER_PATH=$COMPOSER_APP

    [[ -z "$COMPOSER_PATH" ]] && COMPOSER_PATH=`type -p $COMPOSER_APP`
    [[ -z "$COMPOSER_PATH" ]] && COMPOSER_PATH=`type -p $COMPOSER_APP.phar`

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
    message "Downloading Laravel 4 skeleton from $LARAVEL_APP_REPOSITORY..."

    git clone $LARAVEL_APP_BRANCH $LARAVEL_APP_REPOSITORY $INSTALL_DIR  2>&1 | tee -a $LOG_FILE &> /dev/null

    checkErrors "An error ocurred while trying to clone Laravel 4 git repository."

    ### Installing using zip file, git is better but I'll keep this for possible future use
    # 
    # wget -N --output-document=/tmp/laravel-develop.zip https://github.com/laravel/laravel/archive/develop.zip
    # unzip /tmp/laravel-develop.zip -d $INSTALL_DIR
    # mv $INSTALL_DIR/laravel-develop/* $INSTALL_DIR
    # mv $INSTALL_DIR/laravel-develop/.git* $INSTALL_DIR
    # rm -rf $INSTALL_DIR/laravel-develop/
    
    ### niallobrien's larave4-template
    #git clone https://github.com/niallobrien/laravel4-template.git $INSTALL_DIR
    #fixing typo
    #perl -pi -e "s/\`/\'/g" $INSTALL_DIR/app/config/app.php
}

function installApp() {
    installPackage $1 $2
}

function checkMCrypt() {
    if [[ "$OPERATING_SYSTEM" == "Debian" ]] || [[ "$OPERATING_SYSTEM" == "Ubuntu" ]]; then
        installPackage php5-mcrypt
    else
        installPackage php-mcrypt
    fi
}

function checkApp() {
    log "Locating app $1... "

    if [ "$2" == "" ]; then
        installer=installApp
    else 
        installer=$2
    fi

    program=`type -p $1`

    if [[ "$program" == "" ]]; then
        message -n "Trying to install $1 (with command $installer)..."
        $installer $1 2>&1 | tee -a $LOG_FILE &> /dev/null
        if ! type -p $1 2>&1 | tee -a $LOG_FILE &> /dev/null; then
            message ""
            message ""
            message "Looks like $1 is not installed or not available for this application."
            exit 0
        fi
        message " done."
    else 
        message "$1 is installed and available."
    fi
}

function checkErrors() {
    if [ $? -gt 0 ]; then
        message $1
        abortIt "Please check log file at $LOG_FILE."
    fi
}

function checkParameters() {
    if [ ! $INSTALL_DIR ]; then
        inquireText "Please type the installation directory:" $PWD

        if [ "$answer" == "" ]; then
            message 
            abortIt "----> You need to provide installation directory (example: /var/www/myapp)."
        fi

        INSTALL_DIR=$answer
    fi

    INSTALL_DIR_ESCAPED=`message $INSTALL_DIR | sed s,/,\\\\\\\\\\/,g`

    if [ -f $INSTALL_DIR ]; then
       abortIt "You provided a regular file name, not a directory, next time, please, specify a directory."
    fi

    if [ -d $INSTALL_DIR ]; then
        if [ "$(ls -A $INSTALL_DIR)" ]; then
           abortIt "Directory $1 is not empty."
        fi
    else 
        makeInstallDirectory
    fi

    if [ ! $SITE_NAME ]; then
        SITE_NAME=$(basename $INSTALL_DIR)
        inquireText "Please type the site name (e.g.: blog):" $SITE_NAME

        if [ "$answer" == "" ]; then
            message 
            abortIt "----> You need to provide a site name (myapp)."
        fi

        SITE_NAME=$answer
    fi

    #log file is set again, now for site
    LOG_FILE=$L4I_REPOSITORY_DIR/log/l4i.$SITE_NAME.install.log
}

function makeInstallDirectory {

    mkdir $INSTALL_DIR
    checkErrors "Error creating directory $INSTALL_DIR"
}

function checkSudo {
    if [[ $EUID -ne 0 ]]; then
        message "Your sudo password is required for some commands."
        sudo -k
        sudo message -n 
        CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
        [ ${CAN_I_RUN_SUDO} -gt 0 ] && CAN_I_RUN_SUDO="YES" || CAN_I_RUN_SUDO="NO"
    else 
        # user is root, no need to run sudo
        CAN_I_RUN_SUDO=YES
        SUDO_APP=
    fi
}

function showUsage() {
    message
    message
    message "installFour script"
    message "  Installs a Laravel 4 development environment"
    message
    message "     Usage:  bash installFour <directory> <site name>"
    message
    message "  Examples:  bash installFour /var/www/blog blog"
    message "             bash installFour /home/taylor/www blog"
    message
    message
}

function addAppProvider() {
    message "addAppProvider $1" 2>&1 | tee -a $LOG_FILE &> /dev/null

    perl -pi -e "s/WorkbenchServiceProvider',/WorkbenchServiceProvider',\n\t\t'$1',/g" $INSTALL_DIR/app/config/app.php  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function addAppAlias() {
    message "addAppAlias $1" 2>&1 | tee -a $LOG_FILE &> /dev/null

    perl -pi -e "s/View',/View',\n\t\t'$1'       \=\> '$2',/g" $INSTALL_DIR/app/config/app.php  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function composerUpdate() {
    [ "$1" == "" ] && directory=$INSTALL_DIR || directory=$1
    cd $directory
    message "Updating Composer packages on $directory..."
    $COMPOSER_APP update  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function setGlobalPermissions() {
    $SUDO_APP chmod -R 777 $INSTALL_DIR/app/storage/  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function installPackage() {
    if [ "DIDUPDATED" == "" ]; then
        message "$PACKAGER_NAME updating..."
        $PACKAGE_UPDATE_COMMAND 2>&1 | tee -a $LOG_FILE &> /dev/null
        DIDUPDATED=YES
    fi

    $SUDO_APP $PACKAGE_INSTALL_COMMAND $1 $2 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function checkOS() {
    OPERATING_SYSTEM=Unknown
    findProgram lsb_release lsb_program

    if [ "$lsb_program" != "" ] ; then
        OPERATING_SYSTEM=$($lsb_program -si)
    else
        [[ -f /etc/redhat-release ]] && OPERATING_SYSTEM=Redhat
    fi

    if [ "$OPERATING_SYSTEM" == "Debian" ] ||  [ "$OPERATING_SYSTEM" == "Ubuntu" ]; then
        PACKAGER_NAME="apt-get"
        PACKAGE_UPDATE_COMMAND="apt-get --yes update "
        PACKAGE_INSTALL_COMMAND="apt-get --yes install "
    fi

    if [ "$OPERATING_SYSTEM" == "Redhat" ]; then
        PACKAGER_NAME="yum"
        PACKAGE_UPDATE_COMMAND="yum -y update "
        PACKAGE_INSTALL_COMMAND="yum -y install "
    fi

    if grep -q "$OPERATING_SYSTEM" <<< "$SUPPORTED_OPERATING_SYSTEMS"; then
        message "Your operating system ($OPERATING_SYSTEM) is fully supported."
    else
        message
        message "Supported operating systems: $SUPPORTED_OPERATING_SYSTEMS"
        inquireYN "Looks like your operating system ($OPERATING_SYSTEM) is not supported by this scrit, but it still can work, do you wish to continue anyway? " "y" "n"

        if [ "$answer" != "y" ]; then
            message "Aborting."
            exit 1
        fi        
    fi
}

function inquireYN()  {
  message -n "$1 [$2/$3]? "
  read answer
  finish="-1"
  while [ "$finish" = '-1' ]
  do
    finish="1"
    if [ "$answer" = '' ];
    then
      answer=""
    else
      case $answer in
        y | Y | yes | YES ) answer="y";;
        n | N | no | NO ) answer="n";;
        *) finish="-1";
           message -n 'Invalid response -- please reenter:';
           read answer;;
       esac
    fi
  done
}

function inquireText()  {
  answer=""
  while [ "$answer" = "" ]
  do
    # read -e -p "$1 " -i "$2" answer ######### -i is present on bash version 4 only
    read -e -p "$1 [hit enter for $2] " answer
    if [ "$answer" == "" ]; then
        answer=$2
    fi
  done
}

function createLogDirectory() {
    #this is a temporary name for our log file
    LOG_FILE=/tmp/l4i.log
    mkdir -p $L4I_REPOSITORY_DIR/log/ 2>&1 | tee -a $LOG_FILE &> /dev/null
    checkErrors "You might not have permissions to create files in $L4I_REPOSITORY_DIR/log/, please check log: $LOG_FILE."
}

function showLogFile() {
    LOG_FILE=$L4I_REPOSITORY_DIR/log/l4i.$SITE_NAME.install.log

    message "A log of this installation is available at $LOG_FILE."
}

function installOurArtisan() {
    $SUDO_APP cp $L4I_REPOSITORY_GIT/artisan $BIN_DIR/artisan  2>&1 | tee -a $LOG_FILE &> /dev/null
    $SUDO_APP chmod +x $BIN_DIR/artisan 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function abortIt() {
    if [ "$1" != "" ]; then
        message $1
    fi
    message "Aborted."
    exit 1
}

function showHeader() {
    clear
    message "l4i - The Laravel 4 Installer Script"
    message ""
}

function cleanL4IRepository() {
    rm -rf $L4I_REPOSITORY_DIR  2>&1 | tee -a $LOG_FILE &> /dev/null
    checkErrors "You're not allowed to write in $L4I_REPOSITORY_DIR."
}

function findProgram() {
    program=`type -p $1`
    eval $2=\$program
}

function message() {
    if [ "$1" != "" ]; then
        command="echo $1 $2 $3 $4 $5 $6 $7 $8 $9"
        ${command}
    else
        echo
    fi

    log "--- $1 $2 $3 $4 $5 $6 $7 $8 $9"
}

function log() {
    if [ "$LOG_FILE" != "" ]; then
        echo "$1 $2 $3 $4 $5 $6 $7 $8 $9" 2>&1 | tee -a $LOG_FILE &> /dev/null
    fi
}

main
