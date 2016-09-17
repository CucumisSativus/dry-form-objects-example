module Api
  module V1
    class PostcardSerializer
      include JSONAPI::Serializer

      attributes :address, :city, :zip_code, :content

      attribute :country do
        object.country_name
      end

      attribute :state do
        object.state_name
      end
    end
  end
end
