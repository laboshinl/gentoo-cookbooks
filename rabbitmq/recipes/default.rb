include_recipe "gentoo::portage"

gentoo_package_keywords "=net-misc/rabbitmq-server-3.3.4"

package "net-misc/rabbitmq-server" do
  action :upgrade
end

service "rabbitmq" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
  subscribes :restart, resources(:package => "net-misc/rabbitmq-server")
end

# TODO monit needs a pidfile, rabbitmq doesn't create any http://bit.ly/cfZWXC
# if node.run_list?("recipe[monit]")
#   monit_check "rabbitmq"
# end

if node.run_list?("recipe[nagios::nrpe]")
  nrpe_command "rabbitmq"
end

if node.run_list?("recipe[iptables]")
  ips = [node[:rabbitmq][:client_ips]].flatten.select { |i| i != "127.0.0.1" }
  iptables_rule "rabbitmq" do
    variables(:ips => ips)
    action !ips.empty? ? :create : :delete
  end
end
