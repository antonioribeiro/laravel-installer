l4i
===

Laravel 4 Install Script for Linux

This script will install a working development structure of Laravel 4 with a basic Twitter Booststrap template.

### Motivation

When I first said I was building this script someone asked me "does Laravel 4 need an installation script?", actually it doesn't, it's easy to get into it and it's better if you can install it manually, but if you're doing it many times, creating small projects from scratch with it, this script can save you a lot of time. Also, if you are a newbie, it takes some time and work until you get a real working version of Laravel 4, because you have to understand and install Composer, install PHPUnit, install some basic packages, create a VirtualHost on your webserver, point it correctly to your app directory and set the right permissions on storage folder. I saw myself in this place when I first tried to go to L4, when it wasn't even in beta and it was not pretty since I'm still trying to become a PHP coder.

### Requirements

You basically need a Linux box with PHP and a webserver (nginx, apache2 or lighthttpd) installed.

Your user need to have writing permissions to the installation directory, this script will not use sudo to create you directories and download files, but will use it to install needed software.

### Process of installation

* Git clone the current laravel app repository
* Install Composer
* Install PHPUnit (using Composer)
* Install Composer packages
* Create VirtualHost (currently apache2 only) and restart webserver
* Download, install and configure Twitter Bootstrap from git
* Configure a main template, a home view using main template and a route to home, so we can see Laravel 4 and Blade running

### Warnings

This is a bash Debian (Debian and Ubuntu) based installation, for now, so if you are on MacOS, Fedora, CentOS, etc. it may not work.

This script will not create an entry in your hosts file and you will not have acess to your site using a hostname

After installing this script you will have access to your site using the following pattern:
````
 http://ip-address/sitename/
````

There is also a rewrite condition in .htaccess to clean your url, to make it clear and look like `http://ip-address/sitename/user/1`.

If you need something different from this, you'll have to tweak your .htaccess and/or your webserver virtual hosts configuration.

### Screenshots

Selecting aditional packages
![l4i screenshot](http://puu.sh/1QM19)

Page after installing Laravel 4 with this script
![l4i screenshot](http://puu.sh/1PI8I)

### Screencast

http://www.screenr.com/IlX7

### Installed software

In the process of intalling Laravel 4, this script will also try to install, if needed, the following applications in your system:

* Composer (http://getcomposer.org/)
* git 
* curl
* php5-mcrypt
* PHPUnit (composer install)
* Twitter Bootstrap

### Composer packages available to install

* raveren/kint (https://github.com/raveren/kint)
* meido/html (https://github.com/meido/html)
* meido/form (https://github.com/meido/form)
* meido/str (https://github.com/meido/str)
* machuga/authority (https://github.com/machuga/authority)
* jasonlewis/basset (https://github.com/jasonlewis/basset)
* bigelephant/string (https://github.com/bigelephant/string)
* cartalyst/sentry (https://github.com/cartalyst/sentry)

### Commands

This script will create the following commands in your system:

#### composer
This is an executable version of composer.phar 

#### artisan 
You can call this artisan from any place in your system and has 3 main options:

* Calling from a Laravel directory it will act as "php artisan", so you don't need to use php anymore for artisan
* Calling from outside a Laravel directory it will fire installFour script to let you create a new Laravel service environment
* Calling it from any place using the argument "new" (e.g.: artisan new) it will fire installFour installer script as well

### Installation and Examples

There is no need to clone this git repository, you just have to download the script:
```
wget -N --no-check-certificate -O installFour.sh https://raw.github.com/antonioribeiro/l4i/master/installFour.sh
```

And run it:
```
bash installFour.sh <install directory> <site name> <Install twitter bootstrap? YES or NO>
```

Examples of usage:
```
bash installFour.sh /var/www/blog blog YES
bash installFour.sh /home/taylor/www blog NO
bash installFour.sh /var/www/blog myBlog YES
```

### Tested Operating Systems

* Debian Squeeze 6.x
* Ubuntu Server 11.10

# Changelog

2013/01/22 00:58 (GMT-3) - Version 1.2.0

* artisan command now also has the ability to create new services, just execute "artisan new"
* installFour script now also asks for its parameters interactivelly

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