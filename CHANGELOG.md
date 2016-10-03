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
