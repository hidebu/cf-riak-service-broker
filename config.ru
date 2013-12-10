#!/usr/bin/env rackup

require File.expand_path("../config/boot.rb", __FILE__)

use Rack::Auth::Basic, "Cloud Foundry Riak Service Broker" do |username, password|
  [ username, password ] == [ CONFIG["username"], CONFIG["password"] ]
p "MASUDA:========>#{username},#{password}"
end

p "===== START config.ru ====="
run Rack::URLMap.new({
  "/v2/catalog"            => RiakBroker::Catalog,
  "/v2/service_instances"  => RiakBroker::ServiceInstances
#  "/v2/service_bindings"   => RiakBroker::ServiceBindings
#  "/v2/service_instances"   => RiakBroker::ServiceBindings

})
