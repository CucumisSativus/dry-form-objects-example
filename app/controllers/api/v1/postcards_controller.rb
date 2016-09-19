require "dry/matcher/either_matcher"
module Api
  module V1
    class PostcardsController < ApiController
      def create
        result =Postcard::CreateAndSendViaEmail.new(postcard_params).call
        Dry::Matcher::EitherMatcher.call(result) do |m|
          m.success do |postcard|
            render json: JSONAPI::Serializer.serialize(postcard, namespace: Api::V1), status: :ok
          end

          m.failure do |errors|
            render json: JSONAPI::Serializer.serialize_errors(errors), status: :unprocessable_entity
          end
        end
      end

      private

      def postcard_params
        params.permit(:address, :city, :zip_code, :content, :country_id, :state_id, :email).to_h
      end
    end
  end
end
