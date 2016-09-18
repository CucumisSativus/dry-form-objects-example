require 'rails_helper'

RSpec.describe Postcard::CreateAndSendViaEmail do
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
  let(:email) { 'email@example.com' }

  context 'postcard to a country which requires state' do
    let(:base_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        email: email,
        country_id: country_with_states.id,
        state_id: state.id,
      }
    end

    let(:command) { described_class.new(base_params) }

    it 'creates new postcard' do
      expect do
        command.call
      end.to change { Postcard.count }.by(1)
    end

    it 'delivers email' do
      expect do
        command.call
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'returns new postcard' do
      returned = command.call
      expect(returned).to be_a(Dry::Monads::Either::Right)
      expect(returned.value).to be_a(Postcard)
    end
  end

  context 'postcard to a country which does not require state' do
    let(:base_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        email: email,
        country_id: country_without_states.id,
      }
    end

    let(:command) { described_class.new(base_params) }

    it 'creates new postcard' do
      expect do
        command.call
      end.to change { Postcard.count }.by(1)
    end

    it 'delivers email' do
      expect do
        command.call
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'returns new postcard' do
      returned = command.call
      expect(returned).to be_a(Dry::Monads::Either::Right)
      expect(returned.value).to be_a(Postcard)
    end
  end

  describe 'dalidation' do
     let(:base_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        email: email,
        country_id: country_without_states.id,
      }
    end

    let(:command) { described_class.new(base_params) }

     it 'validates presence of address' do
       call_action_without_parameter(base_params, :address)
     end

     it 'validates presence of city' do
       call_action_without_parameter(base_params, :city)
     end

     it 'validates presence of zip_code' do
       call_action_without_parameter(base_params, :zip_code)
     end

     it 'validates presence of content' do
       call_action_without_parameter(base_params, :content)
     end

     it 'validates presence of email' do
       call_action_without_parameter(base_params, :email)
     end

     it 'validates presence of country_id' do
       call_action_without_parameter(base_params, :country_id)
     end

    it 'checks if country exists' do
      postcard_count = Postcard.count
      deliveries_count = ActionMailer::Base.deliveries.count

      result = described_class.new(base_params.merge(country_id: -1)).call
      expect(postcard_count).to eq(Postcard.count)
      expect(deliveries_count).to eq(ActionMailer::Base.deliveries.count)
      expect(result).to be_a(Dry::Monads::Either::Left)
    end

    it 'checks if state exists' do
      new_params = base_params.merge(country_id: country_with_states.id, state_id: -1)
      postcard_count = Postcard.count
      deliveries_count = ActionMailer::Base.deliveries.count

      result = described_class.new(new_params).call
      expect(postcard_count).to eq(Postcard.count)
      expect(deliveries_count).to eq(ActionMailer::Base.deliveries.count)
      expect(result).to be_a(Dry::Monads::Either::Left)
    end
  end

  def call_action_without_parameter(parameters, parameter_to_discard)
    postcard_count = Postcard.count
    deliveries_count = ActionMailer::Base.deliveries.count
    result = described_class.new(parameters.merge(parameter_to_discard => nil)).call
    expect(postcard_count).to eq(Postcard.count)
    expect(deliveries_count).to eq(ActionMailer::Base.deliveries.count)
    expect(result).to be_a(Dry::Monads::Either::Left)
  end
end
