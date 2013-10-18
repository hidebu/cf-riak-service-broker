module RiakBroker
  class ServiceInstances < Sinatra::Base
    SERVICE_INSTANCES = { }

    before do
      content_type "application/json"
    end

    helpers do
      def add_service(service_id, plan_id)
        SERVICE_INSTANCES[service_id] = plan_id
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
