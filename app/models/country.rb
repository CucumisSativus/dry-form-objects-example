class Country < ApplicationRecord
  has_many :states, class_name: 'Country::State'
end
