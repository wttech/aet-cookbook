
%w(
    configs
    features
    bundles
).each do |artifact|

    # fileinstall configurations should be present
    describe file("/opt/aet/karaf/current/etc/org.apache.felix.fileinstall-aet_#{artifact}.cfg") do
        its('content') { should match(%r{# This file is managed by Chef}) }
        its('content') { should match(%r{# DO NOT CHANGE ANYTHING}) }
        its('content') { should match(%r{felix.fileinstall.dir=/opt/aet/karaf/aet_#{artifact}/current}) }
    end
    # artifacts versions folders should be linked
    describe file("/opt/aet/karaf/aet_#{artifact}/current") do
        it { should be_symlink }
    end

end
