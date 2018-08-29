# unreleased

* Selenium grid hub upgrade from 3.8.1 to 3.14.0
* Dependant cookbooks upgrade and change for Mongo DB cookbook

# 4.0.1

* Fix for missing attributes, README updated

# 4.0.0

* Karaf upgrade to version 4.2.0
* Karaf upgrade to version 4.1.5
* Fix for Karaf cache clearing

# 3.0.0

* Fix for Karaf service script
* Selenium Grid recipes added for hub and node with Firefox 38.6
* Gzip compression added for Apache (Report application)

# 2.0.1

* Attribute for Firefox log folder introduced

# 2.0.0

* Changes for cookbook to run AET with JAVA 8
* Karaf upgrade to version 4.1.4
* ActiveMQ version upgrade to 5.15.2
* Folders for AET artifacts reorganized
* Not needed Karaf templates removed
* One recipe instead of three for AET artifacts: *deploy_aet_for_karaf*
* README updated

# 1.4.15

* Switch to OpenJDK, as JAVA 7 is unable to be automatically downloaded by Java Cookbook. 

# 1.4.14

* Karaf IP configurable in vhost template

# 1.4.13

* Update Browsermob version to 2.1.4
* Fix for developer user homedir creation
* Default AET deployment version changed to 2.0.2
* Adding source cookbooks for all templates
* Fixing missing homedirs for services

# 1.4.12

* Fix for deploy_reports recipe
* Spare attribute removed from `.kitchen.yml` file

# 1.4.11

* Fixes and improvements before going open source

# 1.4.10

* `aet::_develop` made private recipe

# 1.4.9

* default URL for Tomcat download changed

# 1.4.8

* new user added for deploying AET artifacts within build lifecycle
* folders paths for AET artifacts moved out of current Karaf instance
* `deploy_configs` recipe renamed
* removed code for checking if deploy to Karaf is required

# 1.4.7

* Adding CORS to /api proxy in aet vhost

# 1.4.6

* Fixing issues with reports

# 1.4.5

* AET release of 1.4.3 version

# 1.4.4

* Fixing browsermob init script

# 1.4.3

* Switching links to public ones
* Splitting Karaf deploy to three independent recipes
* Using supermarket version of maven recipe
* Adding Apache to handle reporting
* Adding report deployment
* Adding Tomcat and package deployment
* Removing Jetty from cookbook

# 1.4.0

* Support for Jetty on Vagrant added (sample app for sanity tests)

# 0.1.0

* Initial release of aet
