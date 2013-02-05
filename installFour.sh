#!/bin/bash

L4I_VERSION=1.6.8
L4I_BRANCH=v1.6.8
LARAVEL_APP_DEFAULT_REPOSITORY="https://github.com/laravel/laravel.git"
LARAVEL_APP_DEFAULT_BRANCH="develop"
INSTALL_DIR=$1
SITE_NAME=$2

############################################  
## This is your playground

L4I_REPOSITORY="-b $L4I_BRANCH https://github.com/antonioribeiro/l4i.git"
L4I_REPOSITORY_DIR=/tmp/l4i
L4I_REPOSITORY_GIT="$L4I_REPOSITORY_DIR/git"
L4I_INSTALLED_APPS="/etc/l4i.installed.txt"
L4I_WEBSERVER_SUFFIX=l4i.conf

LARAVEL_APP_BRANCH=$LARAVEL_APP_DEFAULT_BRANCH
LARAVEL_APP_REPOSITORY=$LARAVEL_APP_DEFAULT_REPOSITORY
BASH_DIR=`type -p bash`
BIN_DIR=`dirname $BASH_DIR`
GIT_APP=git
CURL_APP=curl
WGET_APP=wget
UNZIP_APP=unzip
SUDO_APP=sudo
THIS=`basename $0`

COMPOSER_APP=composer

ARTISAN_APP=artisan

PHPUNIT_APP=phpunit
PHPUNIT_DIR=/etc/phpunit
PHPUNIT_DIR_ESCAPED=`echo $PHPUNIT_DIR | sed s,/,\\\\\\\\\\/,g`

LESSC_APP=lessc
LESSPHP_APP=plessc
LESSPHP_DIR=/etc/lessphp
LESSPHP_DIR_ESCAPED=`echo $LESSPHP_DIR | sed s,/,\\\\\\\\\\/,g`
LESS_APP=`type -p $LESS_COMPILER_APP`

NODEJS_VERSION="v0.8.18"

PHP_SUHOSIN_CONF=/etc/php5/cli/conf.d/suhosin.ini
PHP_MINIMUN_VERSION=5.3.7
PHP_INI=/etc/php/php.ini
PHP_CLI_APP=php
PHP_CGI_APP=php-cgi
APACHE_CONF=
INSTALL_DIR_ESCAPED="***will be set on checkParameters***"
LOG_FILE=$L4I_REPOSITORY_DIR/l4i.install.log

PACKAGE_MANAGER="dpkg"
PACKAGE_LIST_OPTION="-l"

SUPPORTED_OPERATING_SYSTEMS="Debian|Ubuntu|Linux Mint|Redhat|Fedora|CentOS"
#################################################################### 
# operating systems to be supported
#
# MacOS
# arch - almost done, but will have to study how to enable php on apache via bash
# Gentoo
#
#

#		EP_NAME=("raveren/kint" "meido/html"                          "meido/form"                          "meido/str"                        "machuga/authority"  "jasonlewis/basset"              "bigelephant/string"                            "cartalyst/sentry"                                 "jasonlewis/expressive-date"     )
#	 EP_VERSION=("dev-master"   "1.1.*"                               "1.1.*"                               "dev-master"                       "dev-develop"        "dev-master"                     "dev-master"                                    "2.0.*"                                            "1.*"                            )
#  EP_ALIAS_NAME=(""             "HTML"                                "Form"                                "Str"                              ""                   "Basset"                         "String"                                        "Sentry"                                           ""                               )
#EP_ALIAS_FACADE=(""             "Meido\\\HTML\\\HTMLFacade"           "Meido\\\Form\\\FormFacade"           "Meido\\\Str\\\StrFacade"          ""                   "Basset\\\Facades\\\Basset"      "BigElephant\\\String\\\StringFacade"           "Cartalyst\\\Sentry\\\Facades\\\Laravel\\\Sentry"  ""                               )
#	EP_PROVIDER=(""             "Meido\\\HTML\\\HTMLServiceProvider"  "Meido\\\Form\\\FormServiceProvider"  "Meido\\\Str\\\StrServiceProvider" ""                   "Basset\\\BassetServiceProvider" "BigElephant\\\String\\\StringServiceProvider"  "Cartalyst\\\Sentry\\\SentryServiceProvider"       "ExpressiveDateServiceProvider"  )

# former removed due to problems with meido
# changelog: * anahkiasen/former added to the list of packages
# "anahkiasen/former"              
# "dev-composer"                   
#  "Former"                        
#  "Former\\\Facades\\\Former"     
#  "Former\\\FormerServiceProvider"

#################################################################### 
# kwnown errors 

#### composer -> The contents of https://packagist.org/p/providers-stale.json do not match its signature,
#### ** Usually this one is harmless and will not compromise your installation

#### lessc: FATAL ERROR: v8::Context::New() V8 is no longer usable
#### ** Sometimes this error occurs for no reason 

#################################################################### 
# redirection

  # rm $INSTALL_DIR/app/views/hello.php 2>&1 | tee -a $LOG_FILE &> /dev/null
  # mkdir $INSTALL_DIR/app/views/layouts 2>&1 | tee -a $LOG_FILE &> /dev/null
  # mkdir $INSTALL_DIR/app/views/views 2>&1 | tee -a $LOG_FILE &> /dev/null

function main() {
	if [[ $THIS == 'artisan' ]]; then
		ourArtisan $@
	else 
		createSite $@
	fi
}

function createSite() {
	showHeader
	cleanL4IRepository
	createLogDirectory
	showLogFile 
	checkSudo
 
	checkOS
	installPackager
	updatePackagerApp

	checkWebserver
	checkPHP
	checkPackageManager
	configurePHP

	checkParameters

	getIPAddress

	checkApp $WGET_APP
	checkApp $CURL_APP
	checkApp $UNZIP_APP installUnzip
	checkApp $GIT_APP

	downloadL4IRepository

	checkComposer $INSTALL_DIR
	checkPHPUnit
	checkMCrypt
	downloadLaravel4Skeleton
	installAdditionalPackages
	installOurArtisan
	composerUpdate
	checkLessCompiler
	installTwitterBootstrap
	createVirtualHost $INSTALL_DIR
	setGlobalPermissions

	restartWebserver
}

function ourArtisan()  {
	if [ "$1" == "new" ] || [ "$1" == "NEW" ] || [ "$1" == "New" ]; then
		downloadAndRunInstallFour $2 $3 $4 $5 $6 $7 $8 $9
	fi

	if [ "$1" == "destroy" ] || [ "$1" == "DESTROY" ] || [ "$1" == "Destroy" ]; then
		destroySite $@
	fi

	if [ "$1" == "update" ] || [ "$1" == "UPDATE" ] || [ "$1" == "Update" ]; then
		updateAll $@
	fi

	if [ "$1" == "installpackage" ]; then
		addComposerPackage $@
	fi

 	runLaravelArtisan $@
}

function downloadAndRunInstallFour() {
	##
 	## Download and run an updated version of installFour every time we use it
 	##
	makeTemp

	wget -N --no-check-certificate -O $SCRIPT https://raw.github.com/antonioribeiro/l4i/$L4I_BRANCH/installFour.sh &> $LOG_FILE
	checkErrorsAndAbort "An error while downloading i4l script, please check the log file at $LOG_FILE"
	bash $SCRIPT $@

	removeTemp
}

function runLaravelArtisan() {
	findLaravelArtisan
	if [ "$ARTISAN_APP" != "" ] && [ -f $ARTISAN_APP ]; then 
		php $ARTISAN_APP $@
		exit 1
	fi
}

function destroySite() {
	cleanL4IRepository
	createLogDirectory
	checkOS
	locateWebserverConf

	if [[ "$APACHE_CONF" == "" ]]; then begin
		abortIt "Webserver configuration file not found."
	fi

	site=$2
	if [[ "$2" == "-y" ]]; then
		yes=YES
		site=$3
	fi

	if [[ "$3" == "-y" ]]; then
		yes=YES
	fi

	if [[ "$site" != "" ]]; then
		siteFilter=" | grep \"$site\" "
	fi

	command="cat $APACHE_CONF $siteFilter | grep -P \"^Include \/.*$L4I_WEBSERVER_SUFFIX$\" | cut -d\" \" -f2"

	array=(`eval $command`)
	count=${#array[*]}

	if [[ $count -eq 0 ]]; then
		message "No sites found."
		exit 1
	fi

	if [[ $count -gt 1 ]]; then
		if [[ "$yes" == "YES" ]]; then
			echo "You search resulted in more than one site, please choose one to destroy."
			yes=NO
		else
			echo "Please choose one site to destroy."
		fi

		for i in ${!array[*]} ; do 
			dir=`dirname ${array[$i]}` 
			echo "$i) $dir " ; 
		done

		inquireText "Site number:"

		if [ "$answer" -eq "$answer" ] 2>/dev/null; then
			site=array[$answer]
		else 
			site=
		fi

		if [[ "$site" == "" ]]; then
			abortIt "$answer is not a valid option."
		fi

		site=${array[$answer]}
	else
		site=${array[0]}
	fi

	dir=`dirname $site` 
	if [[ "$yes" != "YES" ]]; then
		inquireYN "Are you sure you want to completely destroy $dir and all related files?" "n"

		if [[ "$answer" == "y" ]]; then
			number=$RANDOM
			inquireText "To destroy, please type $number:" 
			if [[ "$number" == "$answer" ]]; then
				answer=y	
			else
				abortIt "You typed a wrong number, you might not be so sure."
			fi
		fi
	else
		answer=y
	fi

	if [[ "$answer" == "y" ]]; then
		zapSite $dir $site
	fi

	exit 1
}

function zapSite {
	dir=$1
	conf=$2
	conf_escaped=`echo $conf | sed s,/,\\\\\\\\\\/,g`

	checkSudo

	$SUDO_APP rm -rf $dir
	$SUDO_APP perl -pi -e "s/Include $conf_escaped\n//g" $APACHE_CONF 2>&1 | tee -a $LOG_FILE &> /dev/null

	restartWebserver
}

function downloadL4IRepository {
	message "Downloading l4i git repository..."
	git clone $L4I_REPOSITORY $L4I_REPOSITORY_GIT 2>&1 | tee -a $LOG_FILE &> /dev/null
	checkErrorsAndAbort "An error ocurred while trying to clone L4I git repository."
}

function installTwitterBootstrap() {
	if [[ "$LARAVEL_APP_REPOSITORY" != "$LARAVEL_APP_DEFAULT_REPOSITORY" ]]; then
		message "You are using a non default version of Laravel 4 app, Twitter Bootstrap may break your installation."
		question="Do you still wish to install Twitter Bootstrap?"
	else
		question="Install Twitter Bootstrap?"
	fi

	inquireYN "$question" "y"
	if [[ "$answer" == "y" ]]; then
		if [[ "$LESS_COMPILER_NAME" == "" ]]; then
			installBootstrapCSS
		else
			inquireYN "Do you wish to install the LESS version of Twitter Bootstrap?" "y"
			if [[ "$answer" == "y" ]]; then
				installBootstrapLess
			else 
				installBootstrapCSS
			fi
		fi
	fi
}

function installBootstrapLess() {
	message "Installing Twitter Bootstrap (less version)..."
	message "Cloning Bootstrap git repository..."

	mkdir -p $INSTALL_DIR/public/vendor/twitter/bootstrap  2>&1 | tee -a $LOG_FILE &> /dev/null
	git clone https://github.com/twitter/bootstrap.git $INSTALL_DIR/public/vendor/twitter/bootstrap  2>&1 | tee -a $LOG_FILE &> /dev/null
	mkdir -p $INSTALL_DIR/public/assets/js  2>&1 | tee -a $LOG_FILE &> /dev/null
	mkdir -p $INSTALL_DIR/public/assets/css  2>&1 | tee -a $LOG_FILE &> /dev/null
	mkdir -p $INSTALL_DIR/public/assets/img  2>&1 | tee -a $LOG_FILE &> /dev/null
	cp $INSTALL_DIR/public/vendor/twitter/bootstrap/js/* $INSTALL_DIR/public/assets/js  2>&1 | tee -a $LOG_FILE &> /dev/null
	cp $INSTALL_DIR/public/vendor/twitter/bootstrap/img/* $INSTALL_DIR/public/assets/img  2>&1 | tee -a $LOG_FILE &> /dev/null

	message "Compiling bootstrap..."

	if [[ "$LESS_COMPILER_NAME" == "$LESSC_APP" ]]; then
		compress=" --compress "
	fi
	if [[ "$LESS_COMPILER_NAME" == "$LESSPHP_APP" ]]; then
		compressed=" -c "
	fi

	compileLess $compressed $INSTALL_DIR/public/vendor/twitter/bootstrap/less/bootstrap.less $INSTALL_DIR/public/assets/css/bootstrap.min.css
	compileLess             $INSTALL_DIR/public/vendor/twitter/bootstrap/less/bootstrap.less $INSTALL_DIR/public/assets/css/bootstrap.css

	compileLess $compressed $INSTALL_DIR/public/vendor/twitter/bootstrap/less/responsive.less $INSTALL_DIR/public/assets/css/bootstrap-responsive.min.css
	compileLess             $INSTALL_DIR/public/vendor/twitter/bootstrap/less/responsive.less $INSTALL_DIR/public/assets/css/bootstrap-responsive.css

	installBootstrapTemplate
}

function compileLess() {
	compiled=false
	i=0
	message "Compiling less file from $1 to $2..."
	while true; do
		$LESS_APP $1 $2 $3 2>&1 | tee -a $LOG_FILE &> /dev/null
		if [ $? -eq 0 ]; then
			break
		fi

		if [[ $i -gt 3 ]]; then
			message "Error trying compile, please check log at $LOG_FILE."
			break
		fi

		i=$[$i+1]
	done
}

function installBootstrapTemplate() {
	message "Installing bootstrap template..."
	rm $INSTALL_DIR/app/views/hello.php 2>&1 | tee -a $LOG_FILE &> /dev/null
	mkdir $INSTALL_DIR/app/views/layouts 2>&1 | tee -a $LOG_FILE &> /dev/null
	mkdir $INSTALL_DIR/app/views/views 2>&1 | tee -a $LOG_FILE &> /dev/null

	cp $L4I_REPOSITORY_GIT/layout.main.blade.php $INSTALL_DIR/app/views/layouts/main.blade.php  2>&1 | tee -a $LOG_FILE &> /dev/null
	cp $L4I_REPOSITORY_GIT/view.home.blade.php $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null

	perl -pi -e "s/hello/views.home/g" $INSTALL_DIR/app/routes.php 2>&1 | tee -a $LOG_FILE &> /dev/null
	perl -pi -e "s/%l4i_branch%/$L4I_BRANCH/g" $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null
	perl -pi -e "s/%l4i_version%/$L4I_VERSION/g" $INSTALL_DIR/app/views/views/home.blade.php 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function findLessCompiler() {
	LESS_COMPILER_NAME=$LESSC_APP
	LESS_APP=`type -p $LESSC_APP`
	if [[ "$LESS_APP" == "" ]]; then
		LESS_COMPILER_NAME=$LESSPHP_APP
		LESS_APP=`type -p $LESSPHP_APP`
	fi
	if [[ "$LESS_APP" == "" ]]; then
		LESS_COMPILER_NAME=
	else 
		message "less compiler ($LESS_COMPILER_NAME) found at $LESS_APP"
	fi
}

function checkLessCompiler() {
	findLessCompiler
	if [[ "$LESS_COMPILER_NAME" == "" ]]; then
		inquireYN "Do you wish to install a less compiler?" "y"
		if [[ "$answer" == "y" ]]; then
			installNodeAndLess
			installLessPHP
			findLessCompiler
		fi
	fi
}

function installNodeAndLess() {
	program=`type -p npm`
	if [[ "$program" == "" ]]; then
		inquireYN "Looks like Node.js is not installed you really wish to install it?" "y"
		if [[ "$answer" == "y" ]]; then
			installNode
			program=`type -p npm`
		fi
	fi

	if [[ "$program" == "" ]]; then
		message "npm is not available to install less."
	else 
		installLess
	fi
}

function installNode() {
	installPackage make
	installPackage python

	if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
		installPackage build-essential
	fi
	if [[ "$OPERATING_SYSTEM" == "Redhat" ]]; then
		message "Installing development tools..."
		$PACKAGER_APP groupinstall -y "Development Tools"  2>&1 | tee -a $LOG_FILE &> /dev/null
	fi

	wget --no-check-certificate -O $L4I_REPOSITORY_DIR/node-$NODEJS_VERSION.tar.gz http://nodejs.org/dist/$NODEJS_VERSION/node-$NODEJS_VERSION.tar.gz 2>&1 | tee -a $LOG_FILE &> /dev/null
	checkErrors "Error downloading Node.js."
	if [[ "$ERROR" == "" ]]; then
		mkdir -p $L4I_REPOSITORY_DIR/node  2>&1 | tee -a $LOG_FILE &> /dev/null
		tar xvfz $L4I_REPOSITORY_DIR/node-$NODEJS_VERSION.tar.gz -C $L4I_REPOSITORY_DIR/node  2>&1 | tee -a $LOG_FILE &> /dev/null
		checkErrors "Error unpacking Node.js."

		cd $L4I_REPOSITORY_DIR/node/node-$NODEJS_VERSION

		./configure 2>&1 | tee -a $LOG_FILE &> /dev/null
		checkErrors "Error configuring Node.js."

		message "Compiling Node.js. This may take several minutes."
		message "You can follow this instalation by opening a new terminal and executing 'tail -f $LOG_FILE'."

		make 2>&1 | tee -a $LOG_FILE &> /dev/null
		checkErrors "Error making Node.js."

		make install 2>&1 | tee -a $LOG_FILE &> /dev/null
		checkErrors "Error installing Node.js."
	else
		message "Node.js installation aborted."
	fi
}

function installLess() {
	message "Installing less..."
	npm install -g less  2>&1 | tee -a $LOG_FILE &> /dev/null
	checkErrors "Error installing less."
}

function checkLessPHP() {
	LESS_APP=`type -p $LESS_COMPILER_APP`
	program=`type -p plessc`

	if [[ "$program" == "" ]]; then
		inquireYN "Do you wish to install lessphp?" "n"
		installLessPHP
	fi
}

function installLessPHP() {
	if [[ "$CAN_I_RUN_SUDO" == "YES" ]]; then
		inquireYN "Do you wish to install lessphp?" "n"
		if [[ "$answer" == "y" ]]; then
			message "Installing lessphp..."
			$SUDO_APP mkdir -p $LESSPHP_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null
			$SUDO_APP chmod 777 $LESSPHP_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null 
			$SUDO_APP cp $L4I_REPOSITORY_GIT/lessphp.composer.json $LESSPHP_DIR/composer.json
			composerUpdate $LESSPHP_DIR
			checkErrors "Error installing lessphp."
			$SUDO_APP chmod +x $LESSPHP_DIR/vendor/leafo/lessphp/plessc 2>&1 | tee -a $LOG_FILE &> /dev/null
			$SUDO_APP ln -s $LESSPHP_DIR/vendor/leafo/lessphp/plessc $BIN_DIR/$LESSPHP_APP 2>&1 | tee -a $LOG_FILE &> /dev/null
			$SUDO_APP ln -s $LESSPHP_DIR/vendor/leafo/lessphp/lessc.inc.php $BIN_DIR/lessc.inc.php 2>&1 | tee -a $LOG_FILE &> /dev/null
		fi 
	fi
}

function installBootstrapCSS() {
	message "Installing Twitter Bootstrap (CSS version)..."
	wget --no-check-certificate -O $L4I_REPOSITORY_DIR/twitter.bootstrap.zip http://twitter.github.com/bootstrap/assets/bootstrap.zip 2>&1 | tee -a $LOG_FILE &> /dev/null
	rm -rf $L4I_REPOSITORY_DIR/twitter.bootstrap 2>&1 | tee -a $LOG_FILE &> /dev/null
	unzip $L4I_REPOSITORY_DIR/twitter.bootstrap.zip -d $L4I_REPOSITORY_DIR/twitter.bootstrap 2>&1 | tee -a $LOG_FILE &> /dev/null
	rm $L4I_REPOSITORY_DIR/twitter.bootstrap.zip
	cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/css $INSTALL_DIR/public
	cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/js $INSTALL_DIR/public
	cp -a $L4I_REPOSITORY_DIR/twitter.bootstrap/bootstrap/img $INSTALL_DIR/public

	installBootstrapTemplate
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
	if [[ "$WEBSERVER" == "apache2" ]] || [[ "$WEBSERVER" == "httpd" ]]; then
		message "Creating $WEBSERVER VirtualHost..."

		conf=$INSTALL_DIR/$VHOST_CONF_FILE
		log "vhost conf = $conf"

		$SUDO_APP cp $L4I_REPOSITORY_GIT/apache.directory.template $conf  2>&1 | tee -a $LOG_FILE &> /dev/null

		$SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" $conf  2>&1 | tee -a $LOG_FILE &> /dev/null
		$SUDO_APP perl -pi -e "s/%installDir%/$INSTALL_DIR_ESCAPED/g" $conf  2>&1 | tee -a $LOG_FILE &> /dev/null

		# if [[ "$VHOST_ENABLE_COMMAND" != "" ]]; then
		# 	$SUDO_APP $VHOST_ENABLE_COMMAND $SITE_NAME 2>&1 | tee -a $LOG_FILE &> /dev/null
		# fi

		echo -e "\nInclude $conf" | $SUDO_APP tee -a $APACHE_CONF 2>&1 | tee -a $LOG_FILE &> /dev/null

		$SUDO_APP $WS_RESTART_COMMAND 2>&1 | tee -a $LOG_FILE &> /dev/null

		cp $INSTALL_DIR/public/.htaccess $INSTALL_DIR/public/.htaccess.ORIGINAL  2>&1 | tee -a $LOG_FILE &> /dev/null
		cp $L4I_REPOSITORY_GIT/htaccess.template $INSTALL_DIR/public/.htaccess  2>&1 | tee -a $LOG_FILE &> /dev/null

		$SUDO_APP perl -pi -e "s/%siteName%/$SITE_NAME/g" $INSTALL_DIR/public/.htaccess  2>&1 | tee -a $LOG_FILE &> /dev/null

		message "Your Laravel 4 installation should be available now at http://$IPADDRESS/$SITE_NAME"
	fi
}

function installAdditionalPackages() {
	message "Configuring additional packages..."

	loadPackagesArray

	total=${#EP_NAME[*]}

	for (( i=0; i<=$(( $total -1 )); i++ ))
	do
		name="${EP_NAME[$i]}"
		version="${EP_VERSION[$i]}"
		alias_name="${EP_ALIAS_NAME[$i]}"
		alias_facade="${EP_ALIAS_FACADE[$i]}"
		provider="${EP_PROVIDER[$i]}"

		if [[ "$name" != "$lastName" ]]; then
			inquireYN "Do you wish to install package $name?" "n"
		else
			answer=$lastAnswer			
		fi

		lastAnswer=$answer
		lastName=$name

		if [[ "$answer" == "y" ]]; then
			installComposerPackage $name $version $alias_name $alias_facade $provider
		fi        
	done    
}

function loadPackagesArray() {

	if [[ "$1" == "" ]];  then
		fileName=$L4I_REPOSITORY_GIT/packages.csv
	else
		fileName=$1
	fi

	if [[ "$2" != "" ]];  then
		cat $fileName | grep -i $2 > $fileName.tmp
		fileName=$fileName.tmp
	fi

	while IFS=, read -r col1 col2 col3 col4 col5; do
		col1=$(trim "$col1")
		col2=$(trim "$col2")
		col3=$(trim "$col3")
		col4=$(trim "$col4") ; col4=$(echo $col4 | sed 's/\\/\\\\\\\\/g')
		col5=$(trim "$col5") ; col5=$(echo $col5 | sed 's/\\/\\\\\\\\/g')

		substring=`echo $col1 | cut -b1-3`
		if [[ "$col1" != "NAME" ]] && [[ "$substring" != "---" ]]; then
			EP_NAME[${#EP_NAME[*]}]=$col1
			EP_VERSION[${#EP_VERSION[*]}]=$col2
			EP_ALIAS_NAME[${#EP_ALIAS_NAME[*]}]=$col3
			EP_ALIAS_FACADE[${#EP_ALIAS_FACADE[*]}]=$col4
			EP_PROVIDER[${#EP_PROVIDER[*]}]=$col5
		fi
	done < $fileName

}

function downloadStarters() {                 
	wget -N --no-check-certificate -O $L4I_REPOSITORY_DIR/starters.csv https://raw.github.com/antonioribeiro/l4i/$L4I_BRANCH/starters.csv  &> $LOG_FILE
}

function loadStartersArray() {

	while IFS=, read -r col1 col2 col3 col4 col5; do
		col1=$(trim "$col1")
		col2=$(trim "$col2")
		col3=$(trim "$col3")

		substring=`echo $col1 | cut -b1-3`
		if [[ "$col1" != "NAME" ]] && [[ "$substring" != "---" ]]; then
			ST_NAME[${#ST_NAME[*]}]=$col1
			ST_REPO[${#ST_REPO[*]}]=$col2
			ST_BRANCH[${#ST_BRANCH[*]}]=$col3
		fi
	done < $L4I_REPOSITORY_DIR/starters.csv

}

function installComposerPackage() {
	$PHP_CLI_APP $L4I_REPOSITORY_GIT/json.edit.php $INSTALL_DIR $1 $2
	log "$PHP_CLI_APP $L4I_REPOSITORY_GIT/json.edit.php $INSTALL_DIR $1 $2"

	if [[ "$3$4" != "" ]]; then
		addAppAlias "$3" "$4"
	fi

	if [[ "$5" != "" ]]; then
		addAppProvider "$5"
	fi
}

function checkPHP() {
	phpcli=`type -p $PHP_CLI_APP`
	phpcgi=`type -p $PHP_CGI_APP`

	if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
		phpcgi=$phpcli
	fi

	if [[ "$phpcli" == "" ]] || [[ "$phpcgi" == "" ]]; then
		message "Looks like PHP or part of it is not installed."
		if [[ "$php_install_attempt" == "" ]]; then
			inquireYN "Do you want to install PHP?" "y"
			if [[ "$answer" == "y" ]]; then
				php_install_attempt=YES
				installPHP
				checkPHP
			fi
		fi
	fi

	if [[ "$phpcli" == "" ]]; then
		message "PHP cli not found."
	fi
	if [[ "$phpcgi" == "" ]]; then
		message "PHP cgi not found."
	fi
	if [[ "$phpcli" == "" ]] || [[ "$phpcgi" == "" ]]; then
		abortIt "You'll need PHP to run Laravel 4, please install it."
	fi

	echo "<?php echo PHP_VERSION;" > /tmp/phpver.php
	phpver=`php /tmp/phpver.php | cut -d- -f1`

	vercomp $phpver $PHP_MINIMUN_VERSION
    case $? in
        0) op='=';;
        1) op='>';;
        2) abortIt "Your PHP version is $phpver, minumum required is $PHP_MINIMUN_VERSION.";;
    esac

	if [[ "$phpisavailable" == "" ]]; then 
		message "PHP $phpver is available."
		phpisavailable=YES
	fi
}

function checkPackageManager() {
	PACKAGE_MANAGER=`type -p $PACKAGE_MANAGER`
}

function checkPHPUnit() {
	phpunit=`type -p $PHPUNIT_APP`
	if [[ "$phpunit" == "" ]]; then
		installPHPUnit
	fi
}

# function installPHP() {
#     # message "Installing PHP..."
#     # sudo apt-get --yes intall php5
# }

function locateWebserver() {
	locateWebserverProc
	if [[ "$ws_process" == "" ]]; then 
		WEBSERVER=apache2
		restartWebserver
		locateWebserverProc
		if [[ "$ws_process" == "" ]]; then
			WEBSERVER=httpd
			restartWebserver
			locateWebserverProc
		fi
	fi
}

function locateWebserverProc() {
	ws_process=
	processes=`$SUDO_APP ps -eaf |grep apache2 |grep -v grep |wc -l` && [ "$processes" -gt "0" ] && ws_process=apache2
	processes=`$SUDO_APP ps -eaf |grep nginx |grep -v grep |wc -l` && [ "$processes" -gt "0" ] && ws_process=nginx
	processes=`$SUDO_APP ps -eaf |grep lighthttpd |grep -v grep |wc -l` && [ "$processes" -gt "0" ] && ws_process=lighttpd
	processes=`$SUDO_APP ps -eaf |grep httpd |grep -v grep |wc -l` && [ "$processes" -gt "0" ] && ws_process=httpd
}

function checkWebserver() {
	# locateWebserver
	locateWebserverProc
	WEBSERVER=$ws_process
	VHOST_ENABLE_COMMAND=
	VHOST_CONF_DIR=/etc/apache2/sites-available
	VHOST_ENABLE_COMMAND="a2ensite"

	buildRestartWebserverCommand

	if [[ "$WEBSERVER" == "" ]]; then
		message "Looks like there is no webserver software installed."
		if [[ "$webserver_install_attempt" == "" ]]; then
			inquireYN "Do you want to install a webserver?" "y"
			if [[ "$answer" == "y" ]]; then
				webserver_install_attempt=YES
				installWebserver
				checkWebserver
			fi
		fi
	fi

	if [[ "$WEBSERVER" == "" ]]; then
		abortIt "You need a webserver to run Laravel 4, please install one and restart."
	fi

	locateWebserverConf

	if [[ "$APACHE_CONF" == "" ]]; then
		abortIt "This script could not find your apache.conf (or httpd.conf) file."
	fi

	if [[ "$WEBSERVER" == "httpd" ]]; then
		if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
			VHOST_CONF_DIR=/etc/httpd/conf
		else
			VHOST_CONF_DIR=/etc/httpd/conf.d
		fi
		VHOST_ENABLE_COMMAND=
	fi

	if [[ "$webserverisinstalled" == "" ]]; then 
		message "Webserver ($WEBSERVER) is installed."
		webserverisinstalled=YES
	fi
}

function locateWebserverConf() {
	hasFile "$APACHE_CONF" APACHE_CONF

	if [[ "$APACHE_CONF" == "" ]]; then
		hasFile /etc/apache2/apache2.conf APACHE_CONF
	fi
	if [[ "$APACHE_CONF" == "" ]]; then
		hasFile /etc/httpd/httpd.conf APACHE_CONF
	fi
	if [[ "$APACHE_CONF" == "" ]]; then
		hasFile /etc/httpd/conf/httpd.conf APACHE_CONF
	fi
	if [[ "$APACHE_CONF" == "" ]]; then
		hasFile /etc/httpd/conf.d/httpd.conf APACHE_CONF
	fi
	if [[ "$APACHE_CONF" == "" ]]; then
		hasFile /etc/apache2/httpd.conf APACHE_CONF
	fi
}

function installPHPUnit() {
	if [[ "$CAN_I_RUN_SUDO" == "YES" ]]; then
		message "Installing PHPUnit..."
		$SUDO_APP mkdir -p $PHPUNIT_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null
		$SUDO_APP chmod 777 $PHPUNIT_DIR 2>&1 | tee -a $LOG_FILE &> /dev/null 
		$SUDO_APP cp $L4I_REPOSITORY_GIT/phpunit.composer.json $PHPUNIT_DIR/composer.json
		$SUDO_APP perl -pi -e "s/%phpunit_dir%/$PHPUNIT_DIR_ESCAPED/g" $PHPUNIT_DIR/composer.json  2>&1 | tee -a $LOG_FILE &> /dev/null
		composerUpdate $PHPUNIT_DIR
		checkErrorsAndAbort "Error installing PHPUnit."
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

	# execute "$CURL_APP -s http://getcomposer.org/installer | $PHP_CLI_APP"

	$CURL_APP -s http://getcomposer.org/installer | $PHP_CLI_APP  2>&1 | tee -a $LOG_FILE &> /dev/null
	checkErrorsAndAbort "Composer installation failed."

	COMPOSER_APP=$BIN_DIR/composer
	$SUDO_APP mv composer.phar $COMPOSER_APP  2>&1 | tee -a $LOG_FILE &> /dev/null
	$SUDO_APP chmod +x $COMPOSER_APP  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function checkComposer() {
	checkComposerInstalled
	if [[ "$RETURN_VALUE" != "TRUE" ]]; then
		installComposer
		checkComposerInstalled
		if [[ "$RETURN_VALUE" != "TRUE" ]]; then
			message "composer is not installed and I was not able to install it"
		fi
	fi

	if [[ "$RETURN_VALUE" == "TRUE" ]]; then
		message "Found Composer at $COMPOSER_PATH."
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

function downloadLaravel4Skeleton() {
	message "Downloading Laravel 4 skeleton from $LARAVEL_APP_REPOSITORY..."

	git clone -b $LARAVEL_APP_BRANCH $LARAVEL_APP_REPOSITORY $INSTALL_DIR  2>&1 | tee -a $LOG_FILE &> /dev/null

	checkErrorsAndAbort "An error ocurred while trying to clone Laravel 4 git repository."

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
	if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
		checkL4InstalledPackage "php5-mcrypt"
	else 
		checkL4InstalledPackage "php-mcrypt"
	fi

	if [[ "$installed" = "" ]]; then 
		if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
			installPackage php5-mcrypt
		else
			## Some CentOS will need this EPEL repository to install php-mcrypt
			if [[ $DISTRIBUTION > "CentOS release 1.0" ]] && [[ $DISTRIBUTION < "CentOS release 6.4" ]]; then
				message "Installing EPEL repository for CentOS..."
				wget --no-check-certificate -O $L4I_REPOSITORY_DIR/epel-release-6-8.noarch.rpm http://epel.gtdinternet.com/6/i386/epel-release-6-8.noarch.rpm 2>&1 | tee -a $LOG_FILE &> /dev/null
				$SUDO_APP yum -y install $L4I_REPOSITORY_DIR/epel-release-6-8.noarch.rpm 2>&1 | tee -a $LOG_FILE &> /dev/null
				checkErrorsAndAbort "Error trying to install EPEL repository for CentOS"
			fi
			installPackage php-mcrypt
			checkErrorsAndAbort "Error installing php-mcrypt."
			addL4InstalledApp "php-mcrypt"
		fi
	else
		message "php5-mcrypt is installed"
	fi
}

function addL4InstalledApp() {
	echo "$1" | $SUDO_APP tee -a $L4I_INSTALLED_APPS 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function checkL4InstalledApp() {
	installed=
	if [[ -f $L4I_INSTALLED_APPS ]]; then
		installed=`cat $L4I_INSTALLED_APPS | grep $1`
	fi
}

function checkL4InstalledPackage() {
	installed=
	if [[ "$PACKAGE_MANAGER" != "" ]] && [[ -f $L4I_INSTALLED_APPS ]]; then
		installed=`$PACKAGE_MANAGER $PACKAGE_LIST_OPTION | grep $1 `
	fi
}

function checkApp() {
	log "Locating app $1... "

	if [[ "$2" == "" ]]; then
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

function checkErrorsAndAbort() {
	if [ $? -gt 0 ]; then
		echo $1
		abortIt "Please check log file at $LOG_FILE."
	fi
}

function checkErrors() {
	ERROR=
	if [ $? -gt 0 ]; then
		message $1
		message "Please check log file at $LOG_FILE."
		echo
		ERROR=YES
	fi
}

function checkParameters() {
	if [ ! $INSTALL_DIR ]; then
		inquireText "Please type the installation directory:" $PWD

		if [[ "$answer" == "" ]]; then
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
		if [[ "$(ls -A $INSTALL_DIR)" ]]; then
		   abortIt "Directory $1 is not empty."
		fi
	else 
		makeInstallDirectory
	fi

	if [ ! $SITE_NAME ]; then
		SITE_NAME=$(basename $INSTALL_DIR)
		inquireText "Please type the site name (e.g.: blog):" $SITE_NAME

		if [[ "$answer" == "" ]]; then
			message 
			abortIt "----> You need to provide a site name (myapp)."
		fi

		SITE_NAME=$answer
	fi

	if [[ "$LARAVEL_APP_REPOSITORY" == "$LARAVEL_APP_DEFAULT_REPOSITORY" ]]; then
		message
		message "Select your Laravel 4 App Repository"
		message

		listStarters
		message "$(( $total )) I want a different repository"

		total=${#ST_NAME[*]}

		message 
		answer=
		while [[ "$answer" == "" ]]; do
			inquireText "Wich Laravel 4 App Repository do you want to use?" 0
			if [ `isnumber $answer` == "NO" ]; then
				answer=
				message "You must type a number."
			else 
				if [ $answer -lt 0 ] || [ $answer -gt $total ]; then
					message "Please type a number between 0 and $total"
					answer=
				fi
			fi
		done

		if [[ $answer -eq $total ]]; then
			readThirdPartyRepository
		else 
			message "Selected app repository: ${ST_NAME[$answer]}"
			LARAVEL_APP_REPOSITORY="${ST_REPO[$answer]}"
			LARAVEL_APP_BRANCH="${ST_BRANCH[$answer]}"
		fi
	fi

	VHOST_CONF_FILE=$SITE_NAME.$L4I_WEBSERVER_SUFFIX
}

function readThirdPartyRepository() {
	inquireText "Please type a git repository address:" $LARAVEL_APP_REPOSITORY
	if [[ "$answer" != "" ]]; then
		LARAVEL_APP_REPOSITORY=$answer

		inquireText "Please type the branch name to be used:" $LARAVEL_APP_BRANCH
		if [[ "$answer" != "" ]]; then
			LARAVEL_APP_BRANCH=$answer
		fi
	fi
}

function listStarters() {
	downloadStarters
	loadStartersArray

	total=${#ST_NAME[*]}

	for (( i=0; i<=$(( $total -1 )); i++ ))
	do
		echo "$i ${ST_NAME[$i]}"
	done    
}

function makeInstallDirectory {

	mkdir $INSTALL_DIR
	checkErrorsAndAbort "Error creating directory $INSTALL_DIR"
}

function checkSudo() {
	if [[ $EUID -ne 0 ]]; then
		message "Your sudo password is required for some commands."
		$SUDO_APP -k
		$SUDO_APP echo -n
		CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
		[ ${CAN_I_RUN_SUDO} -gt 0 ] && CAN_I_RUN_SUDO="YES" || CAN_I_RUN_SUDO="NO"
		if [[ "$CAN_I_RUN_SUDO" == "NO" ]]; then
			abortIt "You are not root and looks like you also cannot run sudo, you'll need more power to run this script."
		fi
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
	perl -pi -e 's/\\\\/\\/g' $INSTALL_DIR/app/config/app.php  2>&1 | tee -a $LOG_FILE &> /dev/null
}

function addAppAlias() {
	message "addAppAlias $1" 2>&1 | tee -a $LOG_FILE &> /dev/null

	perl -pi -e "s/View',/View',\n\t\t'$1'       \=\> '$2',/g" $INSTALL_DIR/app/config/app.php  2>&1 | tee -a $LOG_FILE &> /dev/null
	perl -pi -e 's/\\\\/\\/g' $INSTALL_DIR/app/config/app.php  2>&1 | tee -a $LOG_FILE &> /dev/null
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
	updatePackagerSources
	message "Installing $1..."
	$SUDO_APP $PACKAGER_INSTALL_COMMAND $1 $2 2>&1 | tee -a $LOG_FILE &> /dev/null
	checkErrorsAndAbort "An error ocurred while installing $1."
}

function checkOS() {
	OPERATING_SYSTEM=
	findProgram lsb_release lsb_program
	if [[ "$lsb_program" != "" ]] ; then
		OPERATING_SYSTEM=$($lsb_program -si)
	fi

	findProgram sw_vers sw_vers
	if [[ "$sw_vers" != "" ]] ; then
		os=$($sw_vers | grep "Mac OS X")
		if [[ "$os" != "" ]]; then
			OPERATING_SYSTEM="MacOS"
		fi
	fi

	if [[ -f /etc/debian_version ]]; then
		if [[ "$OPERATING_SYSTEM" == "" ]]; then
			DISTRIBUTION=`cat /etc/debian_version | cut -d \( -f 1`
		else 
			DISTRIBUTION=$OPERATING_SYSTEM
		fi
		OPERATING_SYSTEM=Debian
	fi

	if [[ -f /etc/redhat-release ]]; then
		if [[ "$OPERATING_SYSTEM" == "" ]]; then
			DISTRIBUTION=`cat /etc/redhat-release | cut -d \( -f 1`
		else 
			DISTRIBUTION=$OPERATING_SYSTEM
		fi
		OPERATING_SYSTEM=Redhat
	fi

	if [[ -f /etc/arch-release ]]; then
		OPERATING_SYSTEM=arch
		DISTRIBUTION=arch
	fi

	if [[ "$OPERATING_SYSTEM" == "Ubuntu" ]] || [[ "$OPERATING_SYSTEM" == "Linux Mint" ]]; then
		DISTRIBUTION=$OPERATING_SYSTEM
		OPERATING_SYSTEM=Debian
	fi

	if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
		PACKAGER_APP="apt-get"
		PACKAGER_UPDATE_COMMAND="$PACKAGER_APP --yes update "
		PACKAGER_INSTALL_COMMAND="$PACKAGER_APP --yes install "
		PACKAGE_MANAGER="dpkg"
		PACKAGE_LIST_OPTION="-l"
	fi

	if [[ "$OPERATING_SYSTEM" == "Redhat" ]]; then
		PACKAGER_APP="yum"
		PACKAGER_UPDATE_COMMAND=""
		PACKAGER_INSTALL_COMMAND="$PACKAGER_APP -y install "
		PACKAGE_MANAGER="rpm"
		PACKAGE_LIST_OPTION="-qa"
	fi

	if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
		PACKAGER_APP="pacman"
		PACKAGER_UPDATE_COMMAND="$PACKAGER_APP --noconfirm -Sy "
		PACKAGER_INSTALL_COMMAND="$PACKAGER_APP --noconfirm -S "
	fi

	if [[ "$OPERATING_SYSTEM" == "MacOS" ]]; then
		PACKAGER_APP="brew"
		PACKAGER_UPDATE_COMMAND="$PACKAGER_APP doctor "
		PACKAGER_INSTALL_COMMAND="$PACKAGER_APP --noconfirm -S "
	fi

	if [[ "$OPERATING_SYSTEM" == "" ]] ; then
		OPERATING_SYSTEM=Unkown
	fi
	
	if grep -q "$OPERATING_SYSTEM" <<< "$SUPPORTED_OPERATING_SYSTEMS"; then
		message "Your operating system ($OPERATING_SYSTEM) is fully supported."
		if [[ "$OPERATING_SYSTEM" == "$DISTRIBUTION" ]]; then
			message "Distribution and operating system have the same name."
		else
			message "Your distribution is \"$DISTRIBUTION\"."
		fi
	else
		message
		message "Supported operating systems: $SUPPORTED_OPERATING_SYSTEMS"
		inquireYN "Looks like your operating system ($OPERATING_SYSTEM) is not supported by this script, but it still can work, do you wish to continue anyway?" "n"

		if [[ "$answer" != "y" ]]; then
			message "Aborting."
			exit 1
		fi        
	fi
}

function inquireYN()  {
	if [[ "$2" == "y" ]]; then
		default=Y
	fi
	if [[ "$2" == "n" ]]; then
		default=N
	fi
	inquireText "$1" $default
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
		   inquireText "$1" $default;;
	   esac
	fi
	done
}

function inquireText()  {
	answer=""
	while [ "$answer" = "" ]
	do
		if [[ $BASH_VERSION > '3.9' ]]; then
		read -e -p "$1 " -i "$2" answer
	else
		read -e -p "$1 [hit enter for $2] " answer
		fi

	if [ "$answer" == "" ]; then
		answer=$2
	fi
	done
}

function createLogDirectory() {
	mkdir -p $L4I_REPOSITORY_DIR >/dev/null 2>&1
	checkErrorsAndAbort "You might not have permissions to create files in $L4I_REPOSITORY_DIR, please check log: $LOG_FILE."
}

function showLogFile() {
	message "A log of this installation is available at $LOG_FILE."
}

function installOurArtisan() {
	$SUDO_APP cp $L4I_REPOSITORY_GIT/installFour.sh $BIN_DIR/artisan  2>&1 | tee -a $LOG_FILE &> /dev/null
	$SUDO_APP chmod +x $BIN_DIR/artisan 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function abortIt() {
	if [ "$1" != "" ]; then
		echo $1
	fi
	echo "Aborted."
	exit 1
}

function showHeader() {
	clear
	## will not use message because it logs and log file might not be available at the moment
	echo "l4i - The Laravel 4 Installer Script"
	echo ""
}

function cleanL4IRepository() {
	if [ -d $L4I_REPOSITORY_DIR ]; then
		rm -rf $L4I_REPOSITORY_DIR >/dev/null 2>&1 
		checkErrorsAndAbort "You're not allowed to write in $L4I_REPOSITORY_DIR."
	fi
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
	if [[ "$LOG_FILE" != "" ]] && [[ -f $LOG_FILE ]]; then
		echo "$1 $2 $3 $4 $5 $6 $7 $8 $9" >>$LOG_FILE 2>&1
	fi
}

function installWebserver() {
	inquireYN "Do you want to install apache?" "y"
	if [[ "$answer" == "y" ]]; then
		if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
			installApp apache2
			WEBSERVER=apache2
		fi
		if [[ "$OPERATING_SYSTEM" == "Redhat" ]]; then
			installApp httpd
			WEBSERVER=httpd
		fi
		if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
			installApp apache
			WEBSERVER=httpd
		fi
		if [[ "$OPERATING_SYSTEM" == "MacOS" ]]; then
			abortIt "Unfortunately this app is unable to install a webserver Mac OS, but it should be already installed, check your system setup."
		fi

		restartWebserver
	fi
}

function restartWebserver() {
	buildRestartWebserverCommand
	message "Restarting $WEBSERVER..."
	$SUDO_APP $WS_RESTART_COMMAND stop 2>&1 | tee -a $LOG_FILE &> /dev/null
	sleep 3
	$SUDO_APP $WS_RESTART_COMMAND start 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function buildRestartWebserverCommand() {
	apachectl=`type -p apachectl`
	if [[ "$apachectl" == "" ]]; then 
		WS_RESTART_COMMAND="service $WEBSERVER "
	else 
		WS_RESTART_COMMAND="apachectl "
	fi
}

function installPHP() {
	if [[ "$OPERATING_SYSTEM" == "Debian" ]]; then
		installApp php5 
		installApp php5-common 
		installApp php5-cgi 
		installApp php5-cli
		installApp php-xml-parser
	fi
	if [[ "$OPERATING_SYSTEM" == "Redhat" ]]; then
		installApp php
		installApp php-common 
		installApp php-cli 
		installApp php-xml
	fi
	if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
		installApp php
		installApp php-apache
	fi
	if [[ "$OPERATING_SYSTEM" == "MacOS" ]]; then
		installApp php54
		installApp php54-mcrypt
	fi
}

function execute() {
	command=$1
	${command} >>$LOG_FILE 2>&1
	log ":execute: $1"
}

function updatePackagerSources() {
	if [[ "$packagerUpdated" == "" ]]; then
		packagerUpdated=YES
		if [[ "$PACKAGER_UPDATE_COMMAND" != "" ]]; then
			message "Running $PACKAGER_UPDATE_COMMAND..."
			$SUDO_APP $PACKAGER_UPDATE_COMMAND 2>&1 | tee -a $LOG_FILE &> /dev/null
		fi
	fi
}

function updatePackagerApp() {
	if [[ "$OPERATING_SYSTEM" == "arch" ]]; then
		message "Cheking and upgrading pacman..."
		$SUDO_APP $PACKAGER_INSTALL_COMMAND pacman 2>&1 | tee -a $LOG_FILE &> /dev/null
	fi
}

function configurePHP() {
	if [[ -f $PHP_INI ]]; then
		message "Checking php.ini options..."
		$SUDO_APP cp $PHP_INI $PHP_INI.backup
		$SUDO_APP perl -pi -e "s/;extension=phar.so/extension=phar.so/g" $PHP_INI 2>&1 | tee -a $LOG_FILE &> /dev/null
		$SUDO_APP perl -pi -e "s/^open_basedir =/;open_basedir =/g" $PHP_INI 2>&1 | tee -a $LOG_FILE &> /dev/null
		diff=`diff -q $PHP_INI $PHP_INI.backup | grep differ`
	fi
}

function hasFile() {
	file=$1
	var=$2

	if [[ "$file" != "" ]]; then
		if [[ -f $file ]]; then
			eval $var=\$file
		fi
	else 
		eval $var=
	fi
}

function checkApp() {
	log "Locating app $1... "

	if [[ "$2" == "" ]]; then
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

function installPackager() {
	if [[ "$OPERATING_SYSTEM" == "MacOS" ]]; then
		checkHomebrew
	fi
}

function checkHomebrew() {
	checkApp $PACKAGER_APP installHomebrew
	brew tap homebrew/dupes 2>&1 | tee -a $LOG_FILE &> /dev/null
	brew tap josegonzalez/php 2>&1 | tee -a $LOG_FILE &> /dev/null
}

function installHomebrew() {
	message "Installing Homebrew..."
	ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"  2>&1 | tee -a $LOG_FILE &> /dev/null
	checkApp $PACKAGER_APP installHomebrewFailed
}

function installHomebrewFailed() {
	abortIt "Homebrew installation failed."
}

function findLaravelArtisan() {
	originalApp=$ARTISAN_APP
	artisan=$ARTISAN_APP
	ARTISAN_APP=

	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../../../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../../../../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	artisan=../../../../../../../artisan
	[ "$ARTISAN_APP" == "" ] && [ -f $artisan ] && ARTISAN_APP=$artisan

	if [[ "$ARTISAN_APP" != "" ]]; then
		if [[ $ARTISAN_APP == $originalApp ]]; then
			ARTISAN_APP="./$ARTISAN_APP"
		fi
		INSTALL_DIR=`dirname $ARTISAN_APP`
	fi
}

function makeTemp() {
	SCRIPT=`mktemp`

	if [ "$SCRIPT" == "" ]; then
		SCRIPT=/tmp/$(basename $0).$$.tmp
	fi

	if [ "$SCRIPT" == "" ]; then
		rm -f /tmp/installFour.sh &> /dev/null
		sudo rm -f /tmp/installFour.sh &> /dev/null
		SCRIPT=/tmp/installFour.sh
	fi

	LOG=$SCRIPT.log
}

function removeTemp() {
	rm $SCRIPT
}

function vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

function updateAll() {
	findLaravelArtisan
	if [ "$ARTISAN_APP" == "" ]; then
		abortIt "You must be in a Laravel 4 directory to run this command."
	fi
	dir=`dirname $ARTISAN_APP`

	cd $dir
	message "Updating Composer (self-update)..."
	composer self-update
	message 

	message "Updating site (composer update)..."
	composer update
	message 

	message "Updating classmaps (composer dump-autoload --optimize)..."
	composer dump-autoload --optimize
	message 

	if [[ -f "$PHPUNIT_DIR/composer.json" ]]; then
		message "Updating phpunit..."
		cd $PHPUNIT_DIR
		composer update
		message "Updating phpunit classmaps (composer dump-autoload --optimize)..."
		composer dump-autoload --optimize
		message 
	fi

	message 
	message "All done."
	message 

	exit 1
}

function trim() {
    # Determine if 'extglob' is currently on.
    local extglobWasOff=1
    shopt extglob >/dev/null && extglobWasOff=0
    (( extglobWasOff )) && shopt -s extglob # Turn 'extglob' on, if currently turned off.
    # Trim leading and trailing whitespace
    local var=$1
    var=${var##+([[:space:]])}
    var=${var%%+([[:space:]])}
    (( extglobWasOff )) && shopt -u extglob # If 'extglob' was off before, turn it back off.
    echo -n "$var"  # Output trimmed string.
}

function isnumber() { printf '%f' "$1" &>/dev/null && echo "YES" || echo "NO"; }

function addComposerPackage() {
	downloadPackageList 
	loadPackagesArray $L4I_REPOSITORY_DIR/packages.csv $2

	total=${#EP_NAME[*]}

	if [[ $total -gt 0 ]]; then
		message
		message "Select a package to install"
		message
	fi

	for (( i=0; i<=$(( $total -1 )); i++ ))
	do
		name="${EP_NAME[$i]}"
		echo "$i $name"
	done    
	message "$total quit"

	message 
	answer=
	while [[ "$answer" == "" ]]; do
		inquireText "Package number:"
		if [ `isnumber $answer` == "NO" ]; then
			answer=
			message "You must type a number."
		else 
			if [ $answer -lt 0 ] || [ $answer -gt $total ]; then
				message "Please type a number between 0 and $total"
				answer=
			fi
		fi
	done

	if [[ $answer -ne $total ]]; then
		findLaravelArtisan

		name="${EP_NAME[$answer]}"
		version="${EP_VERSION[$answer]}"
		alias_name="${EP_ALIAS_NAME[$answer]}"
		alias_facade="${EP_ALIAS_FACADE[$answer]}"
		provider="${EP_PROVIDER[$answer]}"
		message "Installing selected app repository: $name"
		installComposerPackage $name $version $alias_name $alias_facade $provider

		message
		message "Composer updating..."
		$COMPOSER_APP update

		message
		message 'Running "composer dump-autoload --optimize"...'
		$COMPOSER_APP dump-autoload --optimize		
		message
		message "All done."
	fi

	exit 1
}

function downloadPackageList() {                 
	wget -N --no-check-certificate -O $L4I_REPOSITORY_DIR/packages.csv https://raw.github.com/antonioribeiro/l4i/$L4I_BRANCH/packages.csv  &> $LOG_FILE
}

main $@

