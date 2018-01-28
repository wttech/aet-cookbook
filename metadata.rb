name              'aet'
maintainer        'Karol Drazek'
maintainer_email  'karol.drazek@cognifide.com'
license           'Apache 2.0'
description       'Installs/Configures aet'
long_description  'Installs/Configures aet'
version           '2.0.1'

depends           'apache2', '~> 3.2.2'
depends           'java', '~> 1.13'
depends           'mongodb3', '~> 5.2.0'

%w(
  centos-6.8
).each do |os|
  supports os
end

source_url        'https://github.com/Cognifide/aet-cookbook'
issues_url        'https://github.com/Cognifide/aet-cookbook/issues'
