name              'aet'
maintainer        'Karol Drazek'
maintainer_email  'karol.drazek@cognifide.com'
license           'Apache 2.0'
description       'Installs/Configures aet'
long_description  'Installs/Configures aet'
version           '2.0.0'

depends           'apache2', '~> 3.2.2'
depends           'firewall', '~> 2.5.2'
depends           'java', '~> 1.13'
depends           'mongodb3', '~> 5.2.0'
depends           'notepadpp', '~> 1.0.0'
depends           'chef-sugar'

%w(
  centos-6.8
).each do |os|
  supports os
end

source_url        'https://github.com/Cognifide/aet-cookbook'
issues_url        'https://github.com/Cognifide/aet-cookbook/issues'
