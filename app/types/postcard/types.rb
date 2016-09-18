class Postcard
  module Types
    include Dry::Types.module
    Country = Dry::Types::Definition
                .new(::Country)
    CountryState = Dry::Types::Definition
                     .new(::Country::State)
  end
end
