module RiakBroker
#  SERVICE_INSTANCES = { }
  SERVICE_INSTANCES = { }
# add masuda
  SERVICE_BINDINGS = { }
# add masuda

  class ServiceInstances < Sinatra::Base
    before do
      content_type "application/json"
    end

    helpers do
      def set_backend_bucket_prop(backend, bucket_uuid)
        bucket_props = { "props" => { "backend" => backend } }

puts("MASUDA: service_instances.rb:ServiceInstances Class:set_backend_bucket_prop Method")
puts("MASUDA: backend ==> #{backend}, bucket_uuid==> #{bucket_uuid}")

# masuda comment out
#        RestClient.put(
#          "http://#{CONFIG["riak_hosts"].sample}:8098/buckets/#{bucket_uuid}/props",
#          bucket_props.to_json,
#          content_type: :json,
#          accept: :json
#        )
      end

      def set_backend(plan_id, bucket_uuid)
        if plan_id == BITCASK_PLAN_ID
          set_backend_bucket_prop("bitcask_mult", bucket_uuid)
        elsif plan_id == LEVELDB_PLAN_ID
          set_backend_bucket_prop("eleveldb_mult", bucket_uuid)
        end
      end

      def add_service(service_id, plan_id)
puts "MASUDA:service_id==>#{service_id}"
#        SERVICE_INSTANCES[service_id] = {
#          plan_id: plan_id,
#      }
#        SERVICE_INSTANCES.store(service_id, plan_id)
        SERVICE_INSTANCES[service_id] = plan_id
puts "MASUDA:SERVICE_INSTANCES==>#{SERVICE_INSTANCES}"
puts "MASUDA:add no kata==>#{service_id.class}"

        set_backend(plan_id, service_id)
      end

      def remove_service(service_id)
        SERVICE_INSTANCES.delete(service_id)
      end

      def already_provisioned?(service_id)
puts "MASUDA:SERVICE_INSTANCES==>#{SERVICE_INSTANCES}"
puts "MASUDA:already no kata==>#{service_id.class}"

        SERVICE_INSTANCES.key?(service_id)
      end

# add masuda
      def create_binding(binding_id, service_id)
        SERVICE_BINDINGS[binding_id] = service_id
      end

      def destroy_binding(binding_id)
        SERVICE_BINDINGS.delete(binding_id)
      end
      def already_bound?(binding_id)
puts "MASUDA:SERVICE_BINDINGS==>#{SERVICE_BINDINGS}"
        SERVICE_BINDINGS.member?(binding_id)
      end
# add masuda
    end


    put "/:id" do
puts("===== Start instances put =====")
      service_id  = params[:id]
      plan_id     = JSON.parse(request.body.read)["plan_id"]
p "----- MASUDA:Provision:service_id==>#{service_id}"
p "----- MASUDA:Provision:plan_id==>#{plan_id}"

      unless already_provisioned?(service_id)
        add_service(service_id, plan_id)
        status 201

        body '{"dashboard_url" : "http://test_url"}'.to_json
#        {}.to_json
#{dashboard_url: "http://test_url"}.to_json
#         {hoge: "HELLO WORLD"}
#puts("MASUDA: to_json==>" + {dashboard_url: "http://test_url"}.to_json)
      else
        status 409
      end
puts("===== End instances put =====")
    end

    delete "/:id" do
puts("========== START instances delete ==========")
      service_id = params[:id]
puts("----- MASUDA:Unprovision:service_id==>#{service_id}")

      if already_provisioned?(service_id)
        remove_service(service_id)
        status 200
      else
        status 404
      end
puts("========== END instances delete ==========")
#      body {}.to_json
       body '{}'.to_json
    end

#======================================== bind ========================================
# bindの処理をこっちに持ってきた。
    put "/*/service_bindings/:id" do
p "===== START instances(bindings) put ====="
      binding_id  = params[:id]
#      service_id  = JSON.parse(request.body.read)["service_instance_id"]
       service_id = params[:service_id]
p "----- MASUDA:Binding:binding_id==>#{binding_id}"
p "----- MASUDA:Binding:instance_id==>#{params[:instance_id]}"
#
#      unless already_bound?(binding_id)
#        create_binding(binding_id, service_id)
#        status 201
#
#        {
#          "credentials" => {
#            "uris" => CONFIG["riak_hosts"].map { |host| "http://#{host}:8098/buckets/#{service_id}" },
#            "bucket" => service_id,
#            "port" => 8098,
#            "hosts" => CONFIG["riak_hosts"]
#          }
#        }.to_json
p "===== END instances(bindings) put ====="         
        status 201
        body '{"dashboard_url" : "http://test_url"}'.to_json
#      else
#        status 409
#      end
    end

    delete "/*/service_bindings/:id" do
p "===== START bindings delete ====="
      binding_id = params[:id]
p "----- MASUDA:Unbinding:binding_id==>#{binding_id}"
p "----- MASUDA:Unbinding:SERVICE_BINDINGS==>#{SERVICE_BINDINGS}"
#      if already_bound?(binding_id)
#        destroy_binding(binding_id)
        status 200
#      else
#        status 404
#      end

      body '{}'.to_json
    end
p "===== END bindings delete ====="
#======================================== bind ========================================

  end
end
