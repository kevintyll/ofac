class Company < ActiveRecord::Base
  belongs_to :ofac_sdn_individual
end
