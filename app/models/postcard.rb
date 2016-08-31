class Postcard < ApplicationRecord
  belongs_to :country
  belongs_to :state, class_name: 'Country::State', required: false
end
