name              'aet'
maintainer        'Karol Drazek'
maintainer_email  'karol.drazek@cognifide.com'
license           'Apache 2.0'
description       'Installs/Configures aet'
long_description  'Installs/Configures aet'
version           '3.0.1-SNAPSHOT'

depends           'apache2', '~> 5.0.1'
depends           'java', '~> 2.1.0'
depends           'sc-mongodb', '~> 1.0.1'

%w(
  centos-7
  windows-2016
).each do |os|
  supports os
end

source_url        'https://github.com/Cognifide/aet-cookbook'
issues_url        'https://github.com/Cognifide/aet-cookbook/issues'
