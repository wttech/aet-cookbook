name              'aet'
maintainer        'Karol Drazek'
maintainer_email  'karol.drazek@cognifide.com'
license           'Apache 2.0'
description       'Installs/Configures aet'
long_description  'Installs/Configures aet'
version           '5.1.1'

depends           'apache2', '~> 3.3.1'
depends           'java', '~> 2.2.0'
depends           'sc-mongodb', '~> 1.2.0'

%w(
  centos-6.8
).each do |os|
  supports os
end

source_url        'https://github.com/Cognifide/aet-cookbook'
issues_url        'https://github.com/Cognifide/aet-cookbook/issues'
