#
# Cookbook Name:: mailcatcher
# Recipe:: default
#
# Copyright 2013, Bryan te Beek
#

case node['platform_family']
    when "debian"
        package "sqlite"
        package "libsqlite3-dev"
    when "fedora", "suse"
        package "libsqlite3-dev"
    when "rhel"
        "sqlite-devel"
end

# Install MailCatcher
# gem_package "mailcatcher"

execute "mailcatcher" do
  command %Q{
    rbenv shell #{node['mailcatcher']['ruby']}
    gem install mailcatcher
  }
  action :run
end

template "/etc/init/mailcatcher.conf" do
  source "mailcatcher.upstart.conf.erb"
  mode 0644
  notifies :restart, "service[mailcatcher]", :immediately
end

service "mailcatcher" do
  provider Chef::Provider::Service::Init::Redhat
  supports :restart => true
  action :nothing
end

# # Start MailCatcher
# bash "mailcatcher" do
#   not_if "netstat -anp | grep :#{node['mailcatcher']['http-port']}"
#   code command
# end