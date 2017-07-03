#! /bin/sh
#
# Vagrant provision script
#
# ### WIP ###
#

yum makecache fast
yum update -y
yum clean all

yum makecache fast
yum install -y centos-release-scl
yum clean all

yum makecache fast
yum group install -y "Development Tools"
yum install -y rh-ruby24-rubygem-bundler rh-ruby24-ruby-devel

sudo -u vagrant scl enable rh-ruby24 'bundler install --gemfile=/vagrant/chef/Gemfile --path=/home/vagrant/.local/lib/ruby/gems --binstubs=/home/vagrant/.local/bin'

yum clean all
