Laravel Installer Script 2.1.0
=======

A Laravel 3 and 4 Install Script for Linux

This Linux Bash Script will install Laravel and, if needed, all dependencies (webserver, php5 and extensions like mcrypt, phpunit and more)

### Installation and Usage

There is no need to clone this git repository, you just have to download the script:
```
wget --no-check-certificate -O -  \
  https://raw.github.com/antonioribeiro/laravel-installer/master/laravel.sh \
  > /tmp/laravel.sh

```

And run it:
```
time bash /tmp/laravel.sh
```

Other examples of usage
```
bash laravel.sh
bash laravel.sh /var/www/blog blog YES
bash laravel.sh /home/taylor/www blog NO
bash laravel.sh /var/www/blog myBlog YES
```

### Laravel Versions

This script will install one of those Laravel versions:

- Laravel 3.0 (currently 3.2.14)
- Laravel 4.0
- Laravel 4.1

### Supported Operating Systems

* Debian (tested on 6 and 7)
* Ubuntu (Desktop and Server)
* Redhat
* Fedora (tested on 17 and 18)
* CentOS (tested on 6.3)

### Requirements

You just need a Linux box with nothing else installed and script will install everything for you or you can use a working PHP development environment and it will install only Laravel and what is missing for it to work.

Web Server: a the moment it only knows how to install and configure apache2, if you need any other webserver (nginx, lighthttpd...), you'll need to do the virtual host creation part manually.

Your user need to have writing permissions to the installation directory, this script will not use sudo to create you directories and download files, but will use it to install needed software.

If this script needs to install software (apache, php5, you will need sudo or root permissions.

### Screencasts

Only 20 seconds to boot an application in Laravel 4

![Demo Screencast](http://www.screenr.com/bTIH)


### Installed software

In the process of installing the entire environment or just Laravel, this script will also try to install, if needed, the following applications in your system:

* Apache2
* PHP 5
* Composer (http://getcomposer.org/)
* git 
* curl
* wget
* unzip
* php5-mcrypt
* PHPUnit (composer install)
* less (http://lesscss.org/ and https://github.com/cloudhead/less.js) - optional
* Node.js and npm - optional
* Bower - optional

### Commands

This script will create the following commands in your system:

#### Composer
This is an executable version of composer.phar 

#### artisan 
You can call this artisan from any place in your system and has some options:

* Running it inside a Laravel directory (or subdirectory) it will act as "php artisan", so you don't need to use php anymore for artisan:
```
taylor@l4server:/var/www/blog> artisan
```

* Running from outside a Laravel directory it will fire laravel script to let you create a new Laravel service environment:
```
taylor@l4server:/> artisan
```

* Runnning it from any place using the argument "new" it will fire laravel installer script as well
```
taylor@l4server:/> artisan new
```

* Runnning it from any place using the argument "destroy" it will help you remove a site created with it:
```
taylor@l4server:/> artisan destroy
```
```
taylor@l4server:/> artisan destroy blog
```
```
taylor@l4server:/> artisan destroy blog -y
```

* Running "artisan update" from inside a Laravel directory (or subdirectory) it will try to "composer update" and "composer dump-autoload --optimize" site and phpunit:
```
taylor@l4server:/var/www/blog> artisan update
```

# Changelog

2013/12/29 16:45 (GMT-3) - Version 2.1.0

* Now using Laravel Craft PHAR installer for 4.1+ Laravel versions
* Installs Laravel Craft PHAR in the system, so you can just run `laravel` to create new applications

2013/12/06 18:01 (GMT-3) - Version 2.0.1

* Script renamed to laravel.sh

2013/12/06 13:59 (GMT-3) - Version 2.0.0

* Added Laravel 4.1 to install options
* Added Laravel 3 to install options
* Default is now Laravel to 4.1
* Dramatically improved speed on Node.js installation
* Correctly checking if MCrypt is installed
* Removed All meta repositories
* Removed Twitter Bootstrap installation, can be easily done via Bower
* Setting permissions (777 and 666) to app/storage or storage (for L3)
* Completely removed composer packages installation, you can do it by user `composer search` and `composer require`
* Added option to install Bower

2013/02/05 00:25 (GMT-3) - Version 1.7.0

* New command: "artisan installpackage [<filter>]". Will filter, show and let the user select a package from a list to install.
* Application Base (or app starter) is now selectable, but user can still type a different repository
* A separate file (starters.csv) was created to make it easier to maintain a list of available bases
* laravelbook / laravel4-starter added to list of bases
* noherczeg / pizzademo added to the list of bases
* laravelbook/laravel4-powerpack added to the list of packages
* laravelbook/ardent added to the list of packages
* Zizaco/confide added to the list of packages
* Zizaco/lessy added to the list of packages

2013/02/01 12:45 (GMT-3) - Version 1.6.7

* New command: "artisan update". Will execute composer self-update, composer update, phpunit composer update and composer dump-autoload --optimize on site and phpunit.

2013/01/28 00:05 (GMT-3) - Version 1.6.6

* Added anahkiasen/underscore-php package (https://github.com/Anahkiasen/underscore-php)
* New app boilerplate mention: ChrisBorgia's radiate

2013/01/27 21:33 (GMT-3) - Version 1.6.5

* Packages list are now on a separate file (packages.csv), easier to maintain by the community

2013/01/27 14:28 (GMT-3) - Version 1.6.0

* Our artisan command is now inside laravel.sh
* Added command "artisan destroy [site name] [-y]" to remove sites created with laravel

2013/01/26 16:52 (GMT-3) - Version 1.5.4

* Our Artisan command now search for the real artisan in the whole (max of 7 levels) directory tree below it, so you can still run it while being inside, e.g., site/app/database/migrations.

2013/01/26 02:25 (GMT-3) - Version 1.5.3

* Added package jasonlewis/expressive-date
* Added compilation of responsive.less to bootstrap-responsive.css

2013/01/25 23:41 (GMT-3) - Version 1.5.2

* Moved Twitter Bootstrap source files to public/vendor
* Moved css, js and img files to public/assets
* Added option to select a different Laravel app repository or branch

2013/01/25 00:06 (GMT-3) - Version 1.5.0

* Changed the way VirtualHosts are created, conf file now is hosted inside the site directory
* Added option to use Twitter Bootstrap source code, script will compile it to CSS
* Webserver restart rewritten
* Added option to install lessphp
* Added less (http://lesscss.org/)
* Added Node.js and npm to install less
* Added lessphp (another less compiler)

2013/01/23 12:12 (GMT-3) - Version 1.4.0

* Separating "Operating System" (Debian, Redhat) from "Distribution" (Ubuntu, Fedora, CentOS) and identifying them correctly
* Added CentOS and Fedora to the list of "Operating Systems"

2013/01/23 12:12 (GMT-3) - Version 1.3.0

* Optionally installs PHP and a webserver (apache), if it cannot find them
* Added support for some Redhat based distributions (Redhat, Fedora and CentOS)
* All script installation files were moved to /tmp/laravel-installer/
* Added a list of supported operating systems and a question if the user OS is not in this list
* CentoOS: added EPEL (http://fedoraproject.org/wiki/EPEL) repository to install php-mcrypt

2013/01/22 00:58 (GMT-3) - Version 1.2.0

* artisan command now also has the ability to create new services, just execute "artisan new"
* laravel script now also asks for its parameters interactivelly

2013/01/21 19:27 (GMT-3) - Version 1.1.0

* Implemented selection of packages during installation
* Twitter Bootstrap now is selectable during installation
* Added command "artisan"
* Added package meido/str 
* Added package machuga/authority 
* Added package jasonlewis/basset 
* Added package bigelephant/string 
* Added package cartalyst/sentry
* Home view modified to show i4l info and version

2013-01-19 19:27:49 - Version 1.0.0

* Version 1 released to public
