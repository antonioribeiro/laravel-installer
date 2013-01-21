#!/bin/bash

## This is your playground
L4I_VERSION=1.1.0
L4I_BRANCH=master
L4I_REPOSITORY="-b $L4I_BRANCH https://github.com/antonioribeiro/l4i.git"
L4I_REPOSITORY_DIR="/tmp/l4i-git-repository"
LARAVEL_APP_BRANCH=" -b develop "
LARAVEL_APP_REPOSITORY="https://github.com/laravel/laravel.git"
BASH_DIR=`which bash`
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
PHP_APP=php
INSTALL_DIR=$1
INSTALL_DIR_ESCAPED=`echo $INSTALL_DIR | sed s,/,\\\\\\\\\\/,g`
SITE_NAME=$2
LOG_FILE=/tmp/l4i.$SITE_NAME.install.log

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
    showLogFile
    checkOS
    checkSudo
    checkPHP
    checkWebserver
    checkParameters $INSTALL_DIR $SITE_DIR
    checkApp $GIT_APP
    checkApp $CURL_APP
    checkApp $UNZIP_APP installUnzip
    checkComposer $INSTALL_DIR
    checkPHPUnit
    checkMCrypt
    downloadL4IRepository
    downloadSkeleton
    installAdditionalPackages
    checkArtisan
    composerUpdate
    installTwitterBootstrap
    createVirtualHost $INSTALL_DIR
    setGlobalPermissions
}

function downloadL4IRepository {
    echo "Downloading l4i git repository..."
    rm -rf $L4I_REPOSITORY_DIR  &>> $LOG_FILE
    git clone $L4I_REPOSITORY $L4I_REPOSITORY_DIR &>> $LOG_FILE
}

function installTwitterBootstrap() {
    inquire "Install Twitter Bootstrap? " "y" "n"
    if [ "$answer" == "y" ]; then 
        echo "Installing Twitter Bootstrap..."
        wget --no-check-certificate -O /tmp/twitter.bootstrap.zip http://twitter.github.com/bootstrap/assets/bootstrap.zip &>> $LOG_FILE
        rm -rf /tmp/tb &>> $LOG_FILE
        unzip /tmp/twitter.bootstrap.zip -d /tmp/tb &>> $LOG_FILE
        cp -a /tmp/tb/bootstrap/css $INSTALL_DIR/public
        cp -a /tmp/tb/bootstrap/js $INSTALL_DIR/public
        cp -a /tmp/tb/bootstrap/img $INSTALL_DIR/public

        rm $INSTALL_DIR/app/views/hello.php &>> $LOG_FILE
        mkdir $INSTALL_DIR/app/views/layouts &>> $LOG_FILE
        mkdir $INSTALL_DIR/app/views/views &>> $LOG_FILE

        cp $L4I_REPOSITORY_DIR/layout.main.blade.php $INSTALL_DIR/app/views/layouts/main.blade.php  &>> $LOG_FILE
        cp $L4I_REPOSITORY_DIR/view.home.blade.php $INSTALL_DIR/app/views/views/home.blade.php &>> $LOG_FILE

        perl -pi -e "s/hello/views.home/g" $INSTALL_DIR/app/routes.php &>> $LOG_FILE
        perl -pi -e "s/%l4i_branch%/$L4I_BRANCH/g" $INSTALL_DIR/app/views/views/home.blade.php &>> $LOG_FILE
        perl -pi -e "s/%l4i_version%/$L4I_VERSION/g" $INSTALL_DIR/app/views/views/home.blade.php &>> $LOG_FILE
    fi
}

function installUnzip() {
    echo "Installing unzip..."
    installPackage unzip
}

function getIPAddress() {
    IPADDRESS=`$SUDO_APP ifconfig | sed -n 's/.*inet addr:\([0-9.]\+\)\s.*/\1/p' | grep -v 127 | head -n 1`
}

function createVirtualHost() {
    if [ $WEBSERVER == "apache2" ]; then
        echo "Creating apache2 VirtualHost..."

        $SUDO_APP cp $L4I_REPOSITORY_DIR/apache.directory.template /etc/apache2/sites-available/$SITE_NAME  &>> $LOG_FILE

        $SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" /etc/apache2/sites-available/$SITE_NAME  &>> $LOG_FILE
        $SUDO_APP perl -pi -e "s/%installDir%/$INSTALL_DIR_ESCAPED/g" /etc/apache2/sites-available/$SITE_NAME  &>> $LOG_FILE

        $SUDO_APP a2ensite $SITE_NAME &>> $LOG_FILE
        $SUDO_APP service apache2 restart &>> $LOG_FILE
        getIPAddress 

        cp $INSTALL_DIR/public/.htaccess $INSTALL_DIR/public/.htaccess.ORIGINAL  &>> $LOG_FILE
        cp $L4I_REPOSITORY_DIR/htaccess.template $INSTALL_DIR/public/.htaccess  &>> $LOG_FILE

        $SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" $INSTALL_DIR/public/.htaccess  &>> $LOG_FILE

        echo "You Laravel 4 installation should be availabel now at http://$IPADDRESS/$SITE_NAME"
    fi
}

function installAdditionalPackages() {
    echo "Configuring additional packages..."

    total=${#EP_NAME[*]}

    for (( i=0; i<=$(( $total -1 )); i++ ))
    do
        name="${EP_NAME[$i]}"
        version="${EP_VERSION[$i]}"
        alias_name="${EP_ALIAS_NAME[$i]}"
        alias_facade="${EP_ALIAS_FACADE[$i]}"
        provider="${EP_PROVIDER[$i]}"

        inquire "Do you wish to install package $name? " "y" "n"

        if [ "$answer" == "y" ]; then
             installComposerPackage $name $version $alias_name $alias_facade $provider
        fi        
    done    
}

function installComposerPackage() {
    $PHP_APP $L4I_REPOSITORY_DIR/json.edit.php $INSTALL_DIR $1 $2
    echo "$PHP_APP $L4I_REPOSITORY_DIR/json.edit.php $INSTALL_DIR $1 $2" &>> $LOG_FILE

    if [ "$3$4" != "" ]; then
        addAppAlias $3 $4
    fi

    if [ "$5" != "" ]; then
        addAppProvider $5
    fi
}

function checkPHP() {
    php=`$PHP_APP -v &>> $LOG_FILE`
    checkErrors "PHP is not installed. Aborted."

    echo "PHP is installed."
}

function checkPHPUnit() {
    phpunit=`which $PHPUNIT_APP`
    if [ "$phpunit" == "" ]; then
        installPHPUnit
    fi
}

# function installPHP() {
#     # echo "Installing PHP..."
#     # sudo apt-get --yes intall php5
# }

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
        echo "Installing PHPUnit..."
        $SUDO_APP mkdir -p $PHPUNIT_DIR &>> $LOG_FILE
        $SUDO_APP chmod 777 $PHPUNIT_DIR &>> $LOG_FILE 
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
        $SUDO_APP chmod +x $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit &>> $LOG_FILE
        $SUDO_APP ln -s $PHPUNIT_DIR/vendor/phpunit/phpunit/composer/bin/phpunit $BIN_DIR/$PHPUNIT_APP &>> $LOG_FILE
    fi 
}

function installComposer() {
    echo "Installing Composer..."
    cd $INSTALL_DIR
    perl -pi -e "s/;suhosin.executor.include.whitelist =$/suhosin.executor.include.whitelist = phar/g" /etc/php5/cli/conf.d/suhosin.ini  &>> $LOG_FILE
    curl -s http://getcomposer.org/installer | $PHP_APP
    checkErrors "Composer installation failed. Aborted."

    COMPOSER_APP=$BIN_DIR/composer
    $SUDO_APP mv composer.phar $COMPOSER_APP  &>> $LOG_FILE
    $SUDO_APP chmod +x $COMPOSER_APP  &>> $LOG_FILE
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
    echo "Downloading Laravel 4 skeleton from $LARAVEL_APP_REPOSITORY..."

    git clone $LARAVEL_APP_BRANCH $LARAVEL_APP_REPOSITORY $INSTALL_DIR  &>> $LOG_FILE

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
    installPackage php5-mcrypt
}

function checkApp() {
    if [ "$2" == "" ]; then
        installer=installApp
    else 
        installer=$2
    fi

    if ! type -p $1 &>> $LOG_FILE; then
        echo -n "Trying to install $1..."
        $installer $1 &>> $LOG_FILE
        if ! type -p $1 &>> $LOG_FILE; then
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
    echo "     Usage:  bash installFour <directory> <site name>"
    echo
    echo "  Examples:  bash installFour /var/www/blog blog"
    echo "             bash installFour /home/taylor/www blog"
    echo
    echo
}

function addAppProvider() {
    echo "addAppProvider $1" &>> $LOG_FILE

    perl -pi -e "s/WorkbenchServiceProvider',/WorkbenchServiceProvider',\n\t\t'$1',/g" $INSTALL_DIR/app/config/app.php  &>> $LOG_FILE
}

function addAppAlias() {
    echo "addAppAlias $1" &>> $LOG_FILE

    perl -pi -e "s/View',/View',\n\t\t'$1'       \=\> '$2',/g" $INSTALL_DIR/app/config/app.php  &>> $LOG_FILE
}

function composerUpdate() {
    [ "$1" == "" ] && directory=$INSTALL_DIR || directory=$1
    cd $directory
    echo "Updating Composer packages on $directory..."
    $COMPOSER_APP update  &>> $LOG_FILE
}

function setGlobalPermissions() {
    $SUDO_APP chmod -R 777 $INSTALL_DIR/app/storage/  &>> $LOG_FILE
}

function installPackage() {
    if [ "DIDUPDATED" == "" ]; then
        echo "$PACKAGER_NAME updating..."
        $PACKAGE_UPDATE_COMMAND &>> $LOG_FILE
        DIDUPDATED=YES
    fi

    $SUDO_APP $PACKAGE_INSTALL_COMMAND $1 $2 &>> $LOG_FILE
}

function checkOS() {
    if type -p lsb_release &>> $LOG_FILE; then
        OPERATING_SYSTEM=$(lsb_release -si)
    else
        if type -p lsb_release &>> $LOG_FILE; then
            OPERATING_SYSTEM=Redhat
        fi        
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
}

inquire ()  {
  echo  -n "$1 [$2/$3]? "
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
           echo -n 'Invalid response -- please reenter:';
           read answer;;
       esac
    fi
  done
}

function showLogFile() {
    echo "A log of this installation is available at $LOG_FILE."
}

function checkArtisan() {
    if ! type -p $ARTISAN_APP &>> $LOG_FILE; then
        installArtisan
    fi
}

function installArtisan() {
    $SUDO_APP cp $L4I_REPOSITORY_DIR/artisan $BIN_DIR/artisan  &>> $LOG_FILE
    $SUDO_APP chmod +x $BIN_DIR/artisan &>> $LOG_FILE
}

clear
main
