require "dry/matcher/either_matcher"
module Api
  module V1
    class PostcardsController < ApiController
      def create
        result =Postcard::CreateForm.new(postcard_params).save
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
        {
          address: params[:address],
          city: params[:city],
          zip_code: params[:zip_code],
          content: params[:content],
          country: Country.find_by(id: params[:country_id]),
          state: Country::State.find_by(id: params[:state_id])
        }
      end
    end
  end
end
