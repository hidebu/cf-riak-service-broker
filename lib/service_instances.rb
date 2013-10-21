module RiakBroker
  SERVICE_INSTANCES = { }

  class ServiceInstances < Sinatra::Base
    before do
      content_type "application/json"
    end

    helpers do
      def set_backend_bucket_prop(backend, bucket_uuid)
        bucket_props = { "props" => { "backend" => backend } }

        RestClient.put(
          "http://#{CONFIG["riak_hosts"].sample}:8098/buckets/#{bucket_uuid}/props",
          bucket_props.to_json,
          content_type: :json,
          accept: :json
        )
      end

      def set_backend(plan_id, bucket_uuid)
        if plan_id == BITCASK_PLAN_ID
          set_backend_bucket_prop("bitcask_mult", bucket_uuid)
        elsif plan_id == LEVELDB_PLAN_ID
          set_backend_bucket_prop("eleveldb_mult", bucket_uuid)
        end
      end

      def add_service(service_id, plan_id)
        bucket_uuid = SecureRandom.uuid

        SERVICE_INSTANCES[service_id] = {
          plan_id: plan_id,
          bucket_uuid: bucket_uuid
        }

        set_backend(plan_id, bucket_uuid)
      end

      def remove_service(service_id)
        SERVICE_INSTANCES.delete(service_id)
      end

      def already_provisioned?(service_id)
        SERVICE_INSTANCES.key?(service_id)
      end
    end

    put "/:id" do
      service_id  = params[:id]
      plan_id     = JSON.parse(request.body.read)["plan_id"]

      unless already_provisioned?(service_id)
        add_service(service_id, plan_id)
        status 201

        {}.to_json
      else
        status 409
      end
    end

    delete "/:id" do
      service_id = params[:id]

      if already_provisioned?(service_id)
        remove_service(service_id)
        status 200
      else
        status 404
      end

      {}.to_json
    end
  end
end
