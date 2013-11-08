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

command = ["mailcatcher"]
command << "--http-ip #{node['mailcatcher']['http-ip']}"
command << "--http-port #{node['mailcatcher']['http-port']}"
command << "--smtp-ip #{node['mailcatcher']['smtp-ip']}" if node['mailcatcher']['smtp-ip']
command << "--smtp-port #{node['mailcatcher']['smtp-port']}"
command = command.join(" ")

# Start MailCatcher
bash "mailcatcher" do
  not_if "netstat -anp | grep :#{node['mailcatcher']['http-port']}"
  code command
end