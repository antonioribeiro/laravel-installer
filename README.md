l4i
===

Laravel 4 Install Script for Linux

This script will install a working directory of Larave 4 in any directory with a basic template of Twitter Booststrap installed.

### Requirements

You basically need a Linux box with PHP and a webserver (nginx, apache2 or lighthttpd) installed

### Screenshot 


### Installed software

In the process of making Laravel 4 work for you this script will also try to install the following applications in your system:

* Composer (http://getcomposer.org/)
* git 
* curl
* PHPUnit (composer install)
* Twitter Bootstrap

### Basic Usage

There is no need to clone this git repository, you just have to download the script and run it:
```
wget -N --output-document=installFour.sh https://raw.github.com/antonioribeiro/l4i/master/installFour.sh
bash installFour.sh <install directory> <site name> <Install twitter bootstrap? YES or NO>
```



### Tested Operating Systems

* Debian Squeeze 6.x
* Ubuntu Desktop and Server 12.04



