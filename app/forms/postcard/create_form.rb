class Postcard
  module Types
    include Dry::Types.module
    Country = Dry::Types::Definition
                .new(::Country)
    CountryState = Dry::Types::Definition
                     .new(::Country::State)
  end

  class CreateForm < Dry::Types::Struct
    include Dry::Monads::Either::Mixin

    constructor_type(:schema)

    ZIP_CODE_FORMAT = /\d{5}/
    MINIMAL_CONTENT_LENGTH = 20

    attribute :address, Types::Coercible::String
    attribute :city, Types::Coercible::String
    attribute :zip_code, Types::Coercible::String
    attribute :content, Types::Coercible::String
    attribute :country, Types::Country
    attribute :state, Types::CountryState


    def save
      errors = PostcardSchema.call(to_hash).messages(full: true)
      return Left(errors) if errors.present?
      Right(Postcard.create!(to_hash))
    rescue ActiveRecord::RecordInvalid => e
      Left(e.record.errors.full_messages)
    end

    private

    PostcardSchema = Dry::Validation.Schema do
      configure do
        config.messages_file = Rails.root.join('config/locales/errors.yml')
        def state_required?(country)
          country.is_state_required
        end
      end
      required(:address).filled
      required(:city).filled
      required(:zip_code).filled(format?: ZIP_CODE_FORMAT)
      required(:content).filled(min_size?: MINIMAL_CONTENT_LENGTH)
      required(:state).maybe
      required(:country).filled

      rule(country_requires_state: [:country, :state]) do |country, state|
        country.state_required? > state.filled?
      end
    end
  end
end
