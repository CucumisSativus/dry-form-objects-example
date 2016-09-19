require 'dry/matcher/either_matcher'
class Postcard
  class CreateAndSendViaEmail < Dry::Types::Struct
    include Dry::Monads::Either::Mixin
    constructor_type(:symbolized)

    attribute :address, Types::Coercible::String
    attribute :city, Types::Coercible::String
    attribute :zip_code, Types::Coercible::String
    attribute :content, Types::Coercible::String
    attribute :country_id, Types::Form::Int
    attribute :state_id, Types::Form::Int
    attribute :email, Types::Coercible::String

    def call
      validate.bind do |valid_attributes|
        Postcard::CreateForm.new(valid_attributes).save.bind do |valid_postcard|
          PostcardMailer.send_postcard(to_email: email, postcard: valid_postcard).deliver_now
          Right(valid_postcard)
        end
      end
    end

    private

    def validate
      errors = ActionSchema.call(action_attributes).messages
      return Left(errors) if errors.present?
      Right(action_attributes)
    end

    def country
      @country ||= Country.find_by(id: country_id)
    end

    def state
      @state ||= Country::State.find_by(id: state_id)
    end

    def action_attributes
      @action_attributes ||= to_hash.except(:state_id, :country_id).merge(country: country, state: state)
    end

    ActionSchema = Dry::Validation.Schema do
      required(:email).filled
    end
  end
end
