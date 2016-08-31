require 'rails_helper'

RSpec.describe Postcard::CreateForm do
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


  context 'sending postcard to country with states' do
    let(:form_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        country: country_with_states,
        state: state
      }
    end

    it 'creates new postcard' do
      expect do
        described_class.new(form_params).save!
      end.to change { Postcard.count }.by(1)
    end
  end

  context 'sending postcard to country without states' do
    let(:form_params) do
      {
        address: address,
        city: city,
        zip_code: zip_code,
        content: content,
        country: country_without_states,
      }
    end

    it 'creates new postcard' do
      expect do
        described_class.new(form_params).save!
      end.to change { Postcard.count }.by(1)
    end
  end

  describe 'validations' do
    context 'presence' do
      let(:form_params) do
        {
          address: address,
          city: city,
          zip_code: zip_code,
          content: content,
          country: country_without_states,
        }
      end

      it 'checks address presence' do
        save_form_without_parameter(form_params, :address)
      end

      it 'checks city presence' do
        save_form_without_parameter(form_params, :city)
      end

      it 'checks zip_code presence' do
        save_form_without_parameter(form_params, :zip_code)
      end

      it 'checks content presence' do
        save_form_without_parameter(form_params, :content)
      end

      it 'checks country presence' do
        save_form_without_parameter(form_params, :country)
      end
    end

    context 'conditional presence' do
      let(:form_params) do
        {
          address: address,
          city: city,
          zip_code: zip_code,
          content: content,
          country: country_with_states,
          state: nil,
        }
      end

      it 'checks presence of state if country requires state' do
        expect do
          described_class.new(form_params).save!
        end.to raise_error CommandValidationFailed
      end
    end

    context 'zip_code format' do
      let(:form_params) do
        {
          address: address,
          city: city,
          zip_code: 'abcde',
          content: content,
          country: country_with_states,
          state: nil,
        }
      end

      it 'rejects wrong zip code format' do
        expect do
          described_class.new(form_params).save!
        end.to raise_error CommandValidationFailed
      end
    end

    context 'content length' do
      let(:form_params) do
        {
          address: address,
          city: city,
          zip_code: zip_code,
          content: ((0..9).map(&:to_s).join),
          country: country_with_states,
          state: nil,
        }
      end

      it 'rejects too small content' do
        expect do
          described_class.new(form_params).save!
        end.to raise_error CommandValidationFailed
      end
    end
  end

  def save_form_without_parameter(parameters, parameter_to_discard)
    expect do
      described_class.new(parameters.merge(parameter_to_discard => nil)).save!
    end.to raise_error CommandValidationFailed
  end
end
