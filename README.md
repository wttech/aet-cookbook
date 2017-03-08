AET Cookbook
============

This cookbook prepare virtual machine for [Automated Exploratory Tests][aet-github] (AET).

It may be used to quickly create platform for AET demo
or to setup an environment for AET development.
Required artifacts are downloaded by this cookbook
from [AET GitHub releases page][aet-releases].

## Supported Platforms

Because this cookbook is used for demo instances or development platforms
we are not supporting a wide range of platforms.
CentOS release 6.7 (Final) is supported currently.

## Usage

For demo instance *default* recipe should be used.
For development purpose use `aet::_develop` and `aet::default` recipes.
The `aet::_develop` recipe provides additional user used by Maven to upload AET artifacts.

### Preparing virtual machine

Include `aet` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[aet::_develop]",
    "recipe[aet::default]"
  ]
}
```

### Using AET

After you have AET instance up and running you could prepare a Maven project to run AET tests.
Please refer to the [AET documentation][aet-wiki] on how to setup a test suite.


## AET Components

The cookbook installs following components required by AET:

* [Karaf framework][karaf] (ver [2.3.9][karaf-2.3.9]) - OSGi environment for AET bundles
* [Active MQ][active-mq] (ver. [5.13.1][active-mq-5.13.1]) - for communication between AET components
* [Mongo DB][mongo-db] - for storing tests results
* [Apache HTTP server][apache] - for AET reports Web Application
* [Browsermob][browsermob] (ver. [2.1.4][browsermob-2.1.4]) - proxy for collecting additional browsing data
* [XVFB][xvfb] - for running firefox in virtual screen
* [Firefox][firefox] (ver. [38.6.0esr][firefox-38.6.0esr]) - for collecting screenshots of pages and other data
* [Tomcat][tomcat] (ver. [8.0.36][tomcat-8.0.36]) - for serving sample site that is used by maintenance tests

Those components may be installed on separate machines
provided they have been configured to work with each other.
The configuration is done within [Karaf Web Console][karaf-web-console].

### Validation of AET components

* **Karaf** - Karaf Web Console should be available at
`http://192.168.123.100:8181/system/console/bundles`.
Default credentials: `karaf/karaf`.
* **Active MQ** - Active MQ Web Console should be available at
`http://192.168.123.100:8161`
Default credentials: `admin/admin`.
* **Mongo DB** - `curl -I 192.168.123.100:27017` responding with _Empty response_
means that Mongo is listening on default port.
* **Apache HTTP Server**  - could be checked with `curl -I 192.168.123.100`
* **Tomcat** - could be checked with `curl -I 192.168.123.100:9090`
* **Browsermob** - try `curl -I 192.168.123.100:8080`.
Expected response is:

```
HTTP/1.1 404 Not Found
Cache-Control: must-revalidate,no-cache,no-store
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 1267
Server: Jetty(7.3.0.v20110203)
```


## Recipes

Recipes below are presented in groups.
Each group (except common) should be installed on same system.

### Common

* `java::default` - Uses [JAVA cookbook][java-cookbook].
Installs [JAVA JDK][java-jdk-7] required by other AET components.
Please notice that Karaf for AET works with JAVA ver. 1.7 only.

### Active MQ

Recipes:

* `aet::activemq` - creates dedicated user
(configured with `node['aet']['activemq']['user']` and `node['aet']['activemq']['group']`),
downloads and install binary distribution of [Active MQ][active-mq]
(using binary package from `node['aet']['activemq']['source']`).
Registers Active MQ as a service (`/etc/init.d/activemq`).

### Apache and AET report web application

Recipes:

* `aet::apache` - Uses [Apache cookbook][apache-cookbook]. Installs Apache HTTP server.
Additionally creates a folder (`node['aet']['apache']['log_dir']`)
for apache logs and creates a link from `/var/log/httpd` to that folder.
Enables *proxy*, *proxy_http* and *headers* modules.
If `aet::_develop` recipe is used, then apache service is run with *develop* system user.
* `aet::deploy_reports` - checks if `node['aet']['version']` is currently linked
as _current_ folder. If no then downloads that version of AET reports web application
and extract it into `node['aet']['apache']['report_base_dir']/aet_reports/#{ver}`.
Creates a link from `node['aet']['apache']['report_base_dir']/aet_reports/current`
to the version folder. Setup virtual host for serving a content from the _current_ folder.
If `aet::_develop` recipe is used this is done with *develop* user.

### Karaf, Browsermob, XVFB and Firefox

Recipes:

* `aet::karaf` - Creates dedicated system user for [Karaf][karaf] service.
If `aet::_develop` recipe is used, then this user is overwritten by *develop* user.
Downloads Karaf and extracts it into `node['aet']['karaf']['root_dir']`.
Creates a symbolic link from `node['aet']['karaf']['root_dir']/current`
to extracted Karaf instance. Updates karaf OSGi version to _org.apache.felix.framework-4.2.1.jar_.
Sets the JAVA settings for Karaf (updated OSGi version in `config.properties` file,
Web Console credentials in `users.properties` file,
HTTP port in `org.ops4j.pax.wweb.cfg` file).
Creates symbolic link from Karaf log dir to `node['aet']['karaf']['log_dir']`.
Registers Karaf as a service (`/etc/init.d/karaf`) and starts it.
* `aet::deploy_bundles` - Check if `node['aet']['karaf']['root_dir']/current/deploy/bundles`
is a link to current version (`node['aet']['version']`). If not, then downloads bundles,
extracts them to the `node['aet']['karaf']['root_dir']/aet_bundles/#{ver}` folder, creates link
to that folder from `node['aet']['karaf']['root_dir']/current/deploy/bundles`
and schedules Karaf restart.
If `aet::_develop` recipe is used this is done with *develop* user.
* `aet::deploy_configs` - Similar to `aet::deploy_bundles`
* `aet::deploy_features` - Similar to `aet::deploy_bundles`
* `aet::postdeploy_restart` - Check if karaf restart was scheduled
(if `/tmp/karaf-restart` file exists). If so, then stops Karaf service,
deletes Karaf cache folders and starts Karaf again.
* `aet::browsermob` - Creates dedicated user for [Browsermob][browsermob] service.
Installs Browsermob into `node['aet']['browsermob']['root_dir']`.
Registers it as a service (`/etc/init.d/browsermob`) and starts it.
* `aet::firefox` - Creates dedicated user for firefox folders permissions.
Downloads (from `node['aet']['firefox']['source']`) and installs Firefox browser.
Configures Firefox to use virtual display from XVFB.
* `aet::xvfb` - Creates dedicated user for xvfb. Installs XVFB service
and configures it to use `node['aet']['xvfb']['log_dir']` as log dir.
The resolution for virtual screen may be set by `node['aet']['xvfb']['resolution']`.
The default value is `'1280x1024x24'`.

### Tomcat and Sample Site

Recipes:

* `aet::tomcat` - Creates dedicated user for [Tomcat][tomcat] service.
If `aet::_develop` recipe is used, then this user is overwritten by *develop* user.
Downloads tomcat and installs it into `node['aet']['tomcat']['base_dir']`.
Configures JAVA settings, tomcat port and [tomcat users][tomcat-users].
Registers tomcat as a service (`/etc/init.d/tomcat`) and enables it.
* `aet::deploy_sample_site` - Checks if
`node['aet']['karaf']['root_dir']/tomcat/aet_sample_site/current`
is a link to current version (`node['aet']['version']`) of sample site.
If not, then downloads required version, extracts it to
`node['aet']['karaf']['root_dir']/tomcat/aet_sample_site/#{ver}`,
creates a link from *current* to this version and restarts tomcat.
If `aet::_develop` recipe is used this is done with *develop* user.

### _develop recipe

* `aet::_develop` - Please note that this recipe is not included by default.
If included it will override system users for Tomcat, Karaf and Apache
with develop user. This has been done in order to enable uploads of AET artifacts to these services.

### Mongo DB

Recipes:

* `aet::mongo` - Installs Mongo DB with [MongoDB cookbook][mongodb3-cookbook]

## X Window

Recipes:

* `aet::display` - Installs X Window for the convenience of virtual machine users.
* `aet::reboot` - After X Window is installed the system needs one reboot.
This cookbook schedules reboot of virtual machine. The reboot is done only once.

## Attributes

See [attributes/][aet-cookbook-github-attributes] folder for default values.

* `node['aet']['version']` - version of AET to set-up. Used by _deploy_ recipes. (default: `'2.0.2'`)
* `node['aet']['base_link']` - base link for AET release artifacts. (default: `'https://github.com/Cognifide/AET/releases/download'`)
* `node['aet']['activemq']['root_dir']` - parent folder for [Active MQ][active-mq] installation (default: `'/opt/aet/activemq'`)
* `node['aet']['activemq']['log_dir']` - log dir for Active MQ (default: `'/var/log/activemq'`)
* `node['aet']['activemq']['user']` - system user for Active MQ service (default: `'activemq'`)
* `node['aet']['activemq']['group']` - system group for Active MQ service (default: `'activemq'`)
* `node['aet']['activemq']['login']` - login for Active MQ [Web Console][active-mq-webconsole] (default: `'admin'`)
* `node['aet']['activemq']['password']` - password for Active MQ [Web Console][active-mq-webconsole] (default: `'admin'`)
* `node['aet']['activemq']['java_min_mem']` - min heap for Active MQ (default: `'64M'`)
* `node['aet']['activemq']['java_max_mem']` - max heap for Active MQ (default: `'1024M'`)
* `node['aet']['activemq']['java_min_perm_mem']` - min permanent space for Active MQ (default: `'64M'`)
* `node['aet']['activemq']['java_max_perm_mem']` - max permanent space for Active MQ (default: `'128M'`)
* `node['aet']['activemq']['jmx_port']` - port to use by Active MQ (default: `'11199'`)
* `node['aet']['activemq']['jmx_ip']` - IP for Active MQ JMX (default: `node['ipaddress']`)
* `node['aet']['activemq']['enable_debug']` - enables JAVA debug agent on port 5006 (default: `false`)
* `node['aet']['activemq']['src_cookbook']['env']` - source cookbook for file template of env (default: `'aet'`)
* `node['aet']['activemq']['src_cookbook']['activemq_xml']` - source cookbook for file template of activemq.xml (default: `'aet'`)
* `node['aet']['activemq']['src_cookbook']['jetty_prop']` - source cookbook for file template of log4j.properties (default: `'aet'`)
* `node['aet']['activemq']['src_cookbook']['log4j_prop']` - source cookbook for file template of jetty-realm.properties (default: `'aet'`)
* `node['aet']['apache']['report_base_dir']` - folder for AET reports web application (default: `'/opt/aet/apache'`)
* `node['aet']['apache']['log_dir']` - apache logs folder (will be linked from `/var/log/httpd`) (default: `'/var/log/apache'`)
* `node['aet']['apache']['src_cookbook']['reports_conf']` - source cookbook for file template of reports vhost (default: `'aet'`)
* `node['aet']['browsermob']['root_dir']` - parent folder for [Browsermob][browsermob] installation (default: `'aet'`)
* `node['aet']['browsermob']['log_dir']` - Browsermob logs folder (default: `'/var/log/browsermob'`)
* `node['aet']['browsermob']['user']` - system user for Browsermob service (default: `'browsermob'`)
* `node['aet']['browsermob']['group']` - system group for Browsermob service (default: `'browsermob'`)
* `node['aet']['browsermob']['port']` - port for Browsermob proxy (default: `'8080'`)
* `node['aet']['browsermob']['src_cookbook']['init_script']` - source cookbook for file template of browsermob init script (default: `'aet'`)
* `node['aet']['firefox']['root_dir']` - parent folder for Firefox browser installation (default: `'/opt/aet/firefox'`)
* `node['aet']['firefox']['src_cookbook']['bin']` - source cookbook for file template of firefox start script (default: `'aet'`)
* `node['aet']['karaf']['user']` - system user for Karaf service (default: `'karaf'`)
* `node['aet']['karaf']['group']` - system group for Karaf service (default: `'karaf'`)
* `node['aet']['karaf']['ssh_password']` - [hashed password][#hashed-passwords] for develop user
* `node['aet']['karaf']['login']` - login for Karaf instance (WebConsole, SSH) (default: `'karaf'`)
* `node['aet']['karaf']['password']` - password for Karaf instance (WebConsole, SSH) (default: `'karaf'`)
* `node['aet']['karaf']['root_dir']` - parent folder for Karaf installation (default: `'/opt/aet/karaf'`)
* `node['aet']['karaf']['log_dir']` - log dir for Karaf (default: `'/var/log/karaf'`)
* `node['aet']['karaf']['enable_debug']` - enables JAVA debug agent on port 5005 (default: `false`)
* `node['aet']['karaf']['web_port']` - HTTP port for Karaf (default: `'8181'`)
* `node['aet']['karaf']['ssh_port']` - SSH port for Karaf (default: `'8101'`)
* `node['aet']['karaf']['java_min_mem']` - min heap for Karaf (default: `'512M'`)
* `node['aet']['karaf']['java_max_mem']` - max heap for Karaf (default: `'1024M'`)
* `node['aet']['karaf']['java_min_perm_mem']` - min permanent space for Karaf (default: `'64M'`)
* `node['aet']['karaf']['java_max_perm_mem']` - max permanent space for Karaf (default: `'128M'`)
* `node['aet']['karaf']['src_cookbook']['setenv']` - source cookbook for file template of setenv.sh (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['config_prop']` - source cookbook for file template of config.properties (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['custom_prop']` - source cookbook for file template of custom.properties (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['users_prop']` - source cookbook for file template of users.properties (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['bundles_cfg']` - source cookbook for file template of org.apache.felix.fileinstall-deploy-bundles.cfg (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['features_cfg']` - source cookbook for file template of org.apache.felix.fileinstall-deploy-features.cfg (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['shell_cfg']` - source cookbook for file template of org.apache.karaf.shell.cfg (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['ops4j_cfg']` - source cookbook for file template of org.ops4j.pax.web.cfg (default: `'aet'`)
* `node['aet']['karaf']['src_cookbook']['init_script']` - source cookbook for file template of karaf init script (default: `'aet'`)
* `node['aet']['tomcat']['base_dir']` - parent folder for Tomcat installation (default: `'/opt/aet/tomcat'`)
* `node['aet']['tomcat']['log_dir']` - log dir for Tomcat (default: `'/var/log/tomcat'`)
* `node['aet']['tomcat']['user']` - system user for Tomcat service (default: `'tomcat'`)
* `node['aet']['tomcat']['group']` - system group for Tomcat service (default: `'tomcat'`)
* `node['aet']['tomcat']['debug_enabled']` - enables JAVA debug agent on port (default: `false`)
* `node['aet']['tomcat']['debug_port']` - default value is `'29090'`
* `node['aet']['tomcat']['jmx_enabled']` - enables JMX for Tomcat (default: `true`)
* `node['aet']['tomcat']['jmx_port']` - default value is `'19090'`
* `node['aet']['tomcat']['port']` - default value is `'9090'` (as *8080* is used by Browsermob)
* `node['aet']['tomcat']['min_heap']` - min heap for Tomcat (default: `'256'`)
* `node['aet']['tomcat']['max_heap']` - max heap for Tomcat (default: `'512'`)
* `node['aet']['tomcat']['max_permsize']` - max permanent space for Tomcat (default: `'256'`)
* `node['aet']['tomcat']['connector']['maxswallowsize']` - for Tomcat [maxSwallowSize][tomcat-max-swallow] (default: `'2097152'`)
* `node['aet']['tomcat']['login']` - login for Tomcat instance (i.e. Manager app) (default: `'admin'`)
* `node['aet']['tomcat']['password']` - password for Tomcat instance (i.e. Manager app) (default: `'admin'`)
* `node['aet']['tomcat']['src_cookbook']['setenv']` - source cookbook for file template of setenv.sh (default: `'aet'`)
* `node['aet']['tomcat']['src_cookbook']['server_xml']` - source cookbook for file template of server.xml (default: `'aet'`)
* `node['aet']['tomcat']['src_cookbook']['users_xml']` - source cookbook for file template of tomcat-users.xml (default: `'aet'`)
* `node['aet']['tomcat']['src_cookbook']['init_script']` - source cookbook for file template of tomcat init script (default: `'aet'`)
* `node['aet']['xvfb']['user']` - system user for XVFB (default: `'xvfb'`)
* `node['aet']['xvfb']['group']` - system group for XVFB (default: `'xvfb'`)
* `node['aet']['xvfb']['log_dir']` - log dir for XVFB (default: `'/var/log/xvfb'`)
* `node['aet']['xvfb']['src_cookbook']['init_script']` - source cookbook for file template of xvfb init script (default: `'aet'`)
* `node['aet']['develop']['user']` - user for develop instance
* `node['aet']['develop']['group']` - group for develop instance
* `node['aet']['develop']['ssh_password']` - hashed password for develop user (generated with `openssl passwd -1 "password"`)

### Hashed passwords

In order to generate hashed password for an user please use following command:

```
[vagrant@aet-vagrant ~]$ openssl passwd -1 "password"
$1$WxkKLOya$9ZOsQs7YdfjZB1wsaJPkW0
[vagrant@aet-vagrant ~]$
```

## New cookbook version

Deployment of new versions of this cookbook is managed with [Stove][stove].
Chef Supermarket login and [key][chef-keys] is required for new version deployment.

Inside the `aet-cookbook` install [bundler][bundler]:

```
gem install bundle
```

Then install gems required by stove (which is already added to `Gemfile`):

```
bundle install
```

Follow the instructions from the [Stove homepage][stove].

## License and Authors

Authors:

* Karol Drazek (<karol.drazek@cognifide.com>)
* Jakub Kubiczak (<jakub.kubiczak@cognifide.com>)

License: [Apache License, Version 2.0][apache-license]

[apache-license]: http://www.apache.org/licenses/LICENSE-2.0
[apache-cookbook]: https://supermarket.chef.io/cookbooks/apache2

[aet-github]: https://github.com/Cognifide/AET
[aet-wiki]: https://github.com/Cognifide/AET/wiki
[aet-releases]: https://github.com/Cognifide/AET/releases
[aet-cookbook-github-attributes]: https://github.com/Cognifide/aet-cookbook/tree/master/attributes

[active-mq]: http://activemq.apache.org/
[active-mq-5.13.1]: https://archive.apache.org/dist/activemq/5.13.1/apache-activemq-5.13.1-bin.tar.gz
[active-mq-webconsole]: http://activemq.apache.org/web-console.html

[browsermob]: https://bmp.lightbody.net/
[browsermob-2.1.4]: https://github.com/lightbody/browsermob-proxy/releases/tag/browsermob-proxy-2.1.4

[mongo-db]: https://docs.mongodb.com/

[tomcat-max-swallow]: https://tomcat.apache.org/tomcat-8.0-doc/config/http.html

[karaf]: http://karaf.apache.org/index.html
[karaf-2.3.9]: https://archive.apache.org/dist/karaf/2.3.9/apache-karaf-2.3.9.tar.gz
[karaf-web-console]: https://karaf.apache.org/manual/latest-2.x/users-guide/web-console.html

[apache]: https://httpd.apache.org/

[firefox]: https://www.mozilla.org/en-US/firefox/products/
[firefox-38.6.0esr]: https://ftp.mozilla.org/pub/firefox/releases/38.6.0esr/linux-x86_64/en-US/firefox-38.6.0esr.tar.bz2

[xvfb]: https://en.wikipedia.org/wiki/Xvfb

[tomcat]: https://tomcat.apache.org/index.html
[tomcat-8.0.36]: http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.36/
[tomcat-users]: https://tomcat.apache.org/tomcat-8.0-doc/manager-howto.html#Configuring_Manager_Application_Access

[java-cookbook]: https://supermarket.chef.io/cookbooks/java
[java-jdk-7]: http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

[mongodb3-cookbook]: https://supermarket.chef.io/cookbooks/mongodb3

[stove]: http://sethvargo.github.io/stove/
[chef-keys]: https://supermarket.chef.io/profile/edit#keys

[bundler]: https://github.com/bundler/bundler
