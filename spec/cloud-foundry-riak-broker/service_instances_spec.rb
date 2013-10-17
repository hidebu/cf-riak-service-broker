require "spec_helper"

describe RiakBroker::ServiceInstances do
  let(:service_uuid) { SecureRandom.uuid }
  let(:plan_uuid) { SecureRandom.uuid }

  def app
    @app ||= RiakBroker::ServiceInstances
  end

  context "PUT /:id" do
    before(:each) do
      put(
        "/#{service_uuid}",
        { "plan_id" => plan_uuid }.to_json,
        { "CONTENT_TYPE" => "application/json" }
      )
    end

    it "should include a 201 status code" do
      last_response.status.should == 201
    end

    it "should include an empty JSON object" do
      last_response.body.should be_json_eql("{}")
    end

    it "should include a 409 status code" do
      put(
        "/#{service_uuid}",
        { "plan_id" => plan_uuid }.to_json,
        { "CONTENT_TYPE" => "application/json" }
      )
      last_response.status.should == 409
    end
  end

  context "DELETE /:id" do
    before(:each) do
      put(
        "/#{service_uuid}",
        { "plan_id" => plan_uuid }.to_json,
        { "CONTENT_TYPE" => "application/json" }
      )
      delete "/#{service_uuid}"
    end

    it "should include a 200 status code" do
      last_response.status.should == 200
    end

    it "should include a 404 status code" do
      delete "/#{SecureRandom.uuid}"
      last_response.status.should == 404
    end

    it "should include an empty JSON object" do
      last_response.body.should be_json_eql("{}")
    end
  end
end
