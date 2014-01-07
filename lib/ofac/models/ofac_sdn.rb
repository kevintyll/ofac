require 'active_record'

class OfacSdn < ActiveRecord::Base

  def self.possible_sdns(name_array, use_ors = false)
    name_conditions = []
    alt_name_conditions = []
    values = []
    name_array.each do |partial_name|
      name_conditions << '(lower(name) like ?)'
      alt_name_conditions << '(lower(alternate_identity_name) like ?)'
      values << "%#{partial_name.downcase}%"
    end
    if use_ors
      conditions = (name_conditions + alt_name_conditions).join(' or ')
    else
      name_conditions = name_conditions.join(' and ')
      alt_name_conditions = alt_name_conditions.join(' and ')
      conditions = "(#{name_conditions}) or (#{alt_name_conditions})"
    end
    # we need the values in there twice, once for the names and once for the alt_names
    OfacSdn.select([:name, :alternate_identity_name, :address, :city]).where(sdn_type: 'individual').where(conditions, *(values * 2))
  end

end
