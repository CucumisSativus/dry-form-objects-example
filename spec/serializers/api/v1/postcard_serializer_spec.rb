require 'rails_helper'

RSpec.describe Api::V1::PostcardSerializer do
  let(:address) { 'Random Street 10/19' }
  let(:city) { 'Random City' }
  let(:zip_code) { '12345' }
  let(:content) { 'Hey Mom, some random content here!' }


  context 'country with states' do
    let(:country) do
      Country.new(name: 'The United States of America', is_state_required: true)
    end

    let(:state) do
      Country::State.new(name: 'Wyoming', country: country)
    end
    let(:base_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        country: country,
        state: state,
      }
    end

    let(:postcard) { Postcard.new(base_params) }
    let(:json) { JSONAPI::Serializer.serialize(postcard, namespace: Api::V1) }

    it 'has proper attributes' do
      attributes = json.dig('data', 'attributes')
      aggregate_failures 'serialization attributes' do
        expect(attributes['address']).to eq(address)
        expect(attributes['city']).to eq(city)
        expect(attributes['zip-code']).to eq(zip_code)
        expect(attributes['content']).to eq(content)
        expect(attributes['country']).to eq(country.name)
        expect(attributes['state']).to eq(state.name)
      end
    end
  end

  context 'country without states' do
    let!(:country) do
      Country.create!(name: 'Poland', is_state_required: false)
    end
    let(:base_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        country: country,
      }
    end

    let(:postcard) { Postcard.new(base_params) }
    let(:json) { JSONAPI::Serializer.serialize(postcard, namespace: Api::V1) }

    it 'has proper attributes' do
      attributes = json.dig('data', 'attributes')
      aggregate_failures 'serialization attributes' do
        expect(attributes['address']).to eq(address)
        expect(attributes['city']).to eq(city)
        expect(attributes['zip-code']).to eq(zip_code)
        expect(attributes['content']).to eq(content)
        expect(attributes['country']).to eq(country.name)
      end
    end
  end
end
