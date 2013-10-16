#!/usr/bin/env rackup

require File.expand_path("../config/boot.rb", __FILE__)

run Rack::URLMap.new({
  "/catalog"            => RiakBroker::Catalog
})
