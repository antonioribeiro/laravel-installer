l4i
===

Laravel 4 Install Script for Linux

This script will install a working development structure of Laravel 4 with a basic Twitter Booststrap template.

### Motivation

Some people asked me if Laravel 4 needed a installation script, actually it doesn't, it's better if you can install it manually, but if you're doing it many times, this script can save you a lot of time. Also, if you are a newbie, it takes some time and work until you get a working version of Laravel 4 really working, because you have to understand and install Composer, install PHPUnit, install some basic packages, create a Virtual Host on your webserver, point it correctly to your app directory and set the right permissions on storage folder...

### Requirements

You basically need a Linux box with PHP and a webserver (nginx, apache2 or lighthttpd) installed.

Your user need to have writing permissions to the installation directory, this script will not use sudo to create you directories and download files, but will use it to install needed software.

### Process of installation

* Git clone the current laravel app repository
* Install Composer
* Install PHPUnit (using Composer)
* Install packages: meido/Form, meido/HTML, raveren/kint
* Create VirtualHost (currently apache2 only) and restart webserver
* Download, install and configure Twitter Bootstrap from git
* Configure a main template, a home view using main template and a route to home, so we can see Laravel 4 and Blade running

### Warnings

This script will not create an entry in your hosts file and you will not have acess to your site using a hostname

After installing this script you will have access to your site using the following pattern:
````
 http://ip-address/sitename/
````

There is also a rewrite condition in .htaccess to clean your url, to make it clear and look like `http://ip-address/sitename/user/1`.

If you need something different from this, you'll have to tweak your .htaccess and/or your webserver virtual hosts configuration.

### Screenshot 

![image from redmond barry building unimelb](http://puu.sh/1PI8I)

### Screencast

http://www.screenr.com/IlX7

### Installed software

In the process of intalling Laravel 4, this script will also try to install, if needed, the following applications in your system:

* Composer (http://getcomposer.org/)
* git 
* curl
* PHPUnit (composer install)
* Twitter Bootstrap

### Installation and Examples

There is no need to clone this git repository, you just have to download the script:
```
wget -N --output-document=installFour.sh https://raw.github.com/antonioribeiro/l4i/master/installFour.sh
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
* Ubuntu Derver 11.10
