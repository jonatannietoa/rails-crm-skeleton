require "rails_helper"

RSpec.describe "Customers", type: :request do
  let(:affinity_payload) do
    {
      name: "Acme Inc.",
      email: "ops@acme.example",
      metadata: {
        source: "affinity",
        external_id: "aff_org_12345",
        entity_type: "organization",
        list_entry_id: "le_987",
        fields: { "Status" => "Customer", "ARR" => "120000" },
        tags: %w[strategic emea],
      },
    }
  end

  describe "POST /customers" do
    it "creates a customer with its CRM metadata and returns the read model" do
      post "/customers", params: affinity_payload, as: :json

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["id"]).to be_present
      expect(body["name"]).to eq("Acme Inc.")
      expect(body["email"]).to eq("ops@acme.example")
      expect(body.dig("metadata", "source")).to eq("affinity")
      expect(body.dig("metadata", "external_id")).to eq("aff_org_12345")
      expect(body.dig("metadata", "fields", "ARR")).to eq("120000")
      expect(body.dig("metadata", "tags")).to contain_exactly("strategic", "emea")
    end

    it "rejects an invalid entity type with 422" do
      payload = affinity_payload.deep_merge(metadata: { entity_type: "planet" })

      post "/customers", params: payload, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["error"]).to match(/entity type/)
    end

    it "rejects a duplicate email with 409" do
      post "/customers", params: affinity_payload, as: :json
      post "/customers", params: affinity_payload.deep_merge(metadata: { external_id: "aff_org_2" }), as: :json

      expect(response).to have_http_status(:conflict)
    end
  end

  describe "GET /customers/:id" do
    it "returns a previously created customer" do
      post "/customers", params: affinity_payload, as: :json
      id = response.parsed_body["id"]

      get "/customers/#{id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(id)
      expect(response.parsed_body.dig("metadata", "entity_type")).to eq("organization")
    end

    it "returns 404 for an unknown id" do
      get "/customers/00000000-0000-0000-0000-000000000000"

      expect(response).to have_http_status(:not_found)
    end
  end
end
