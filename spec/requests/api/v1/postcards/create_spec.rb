require 'rails_helper'

RSpec.describe 'api user creates new postcard', type: :request do
  let(:api_path) { '/api/v1/postcards' }

  let!(:country_without_states) do
    Country.create!(name: 'Poland', is_state_required: false)
  end

  let!(:country_with_states) do
    Country.create!(name: 'The United States of America', is_state_required: true)
  end

  let(:state) do
    Country::State.create!(name: 'Wyoming', country: country_with_states)
  end

  let(:address) { 'Random Street 10/19' }
  let(:city) { 'Random City' }
  let(:zip_code) { '12345' }
  let(:content) { 'Hey Mom, some random content here!' }
  let(:base_params) do
    {
      address: address,
      city: city,
      zip_code: zip_code,
      content: content,
      country_id: country_without_states.id,
      email: 'email@example.com'
    }
  end

  context 'sending postcard to country which does not require states' do
    let(:request_params) { base_params }

    it 'creates new postcard' do
      expect do
        post api_path, params: request_params, headers: {}, as: :json
      end.to change { Postcard.count }.by(1)
    end

    it 'sends new postcard' do
      expect do
        post api_path, params: request_params, headers: {}, as: :json
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'has proper json format' do
      post api_path, params: request_params, headers: {}, as: :json
      expect(response).to be_success
      aggregate_failures 'response format' do
        attributes = JSON.parse(response.body).dig('data', 'attributes')
        expect(attributes['address']).to eq(address)
        expect(attributes['city']).to eq(city)
        expect(attributes['zip-code']).to eq(zip_code)
        expect(attributes['content']).to eq(content)
        expect(attributes['country']).to eq(country_without_states.name)
        expect(attributes['state']).not_to be_present
      end
    end
  end

  context 'sending postcard to country witch requires state' do
    let(:request_params) do
      base_params.merge(country_id: country_with_states.id, state_id: state.id)
    end

    it 'creates new postcard' do
      expect do
        post api_path, params: request_params, headers: {}, as: :json
      end.to change { Postcard.count }.by(1)
    end

    it 'sends new postcard' do
      expect do
        post api_path, params: request_params, headers: {}, as: :json
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'returns proper json format' do
      post api_path, params: request_params, headers: {}, as: :json
      expect(response).to be_success
      aggregate_failures 'response format' do
        attributes = JSON.parse(response.body).dig('data', 'attributes')
        expect(attributes['address']).to eq(address)
        expect(attributes['city']).to eq(city)
        expect(attributes['zip-code']).to eq(zip_code)
        expect(attributes['content']).to eq(content)
        expect(attributes['country']).to eq(country_with_states.name)
        expect(attributes['state']).to eq(state.name)
      end
    end
  end

  describe 'validations' do
    it 'validates presence of address' do
      perform_request_without_require_parameter(api_path, base_params, :address)
    end

    it 'validates presence of city' do
      perform_request_without_require_parameter(api_path, base_params, :city)
    end

    it 'validates presence of zip code' do
      perform_request_without_require_parameter(api_path, base_params, :zip_code)
    end

    it 'validates presence of content' do
      perform_request_without_require_parameter(api_path, base_params, :content)
    end

    it 'validates presence of country_id' do
      perform_request_without_require_parameter(api_path, base_params, :country_id)
    end

    it 'validates presence of email' do
      perform_request_without_require_parameter(api_path, base_params, :email)
    end

    it 'validates presence of state if country requires it' do
      params = base_params.merge(country_id: country_with_states.id)
      perform_request_without_require_parameter(api_path, params, :state_id)
    end
  end

  def perform_request_without_require_parameter(path, params, key_to_exclude)
    post path, params: params.merge(key_to_exclude => nil), headers: {}, as: :json
    expect(response).not_to be_success
    errors = JSON.parse(response.body)['errors']
    expect(errors).not_to be_empty
  end
end
