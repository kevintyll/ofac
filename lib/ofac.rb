require 'ofac/engine'

module Ofac
  # the Ofac module conflicts with the old Ofac class.  Add a new method to the module for backward compatibility
  def self.new(identity)
    OfacIndividual.new(identity)
  end
end