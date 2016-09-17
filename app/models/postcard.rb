class Postcard < ApplicationRecord
  belongs_to :country
  belongs_to :state, class_name: 'Country::State', required: false

  delegate :name, to: :country, prefix: true
  delegate :name, to: :state, prefix: true, allow_nil: true
end
