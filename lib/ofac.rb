require 'rake'
require 'ofac/ruby_string_extensions'
require 'ofac/ofac_match'
require 'ofac/models/ofac_sdn'
require 'ofac/models/ofac_sdn_loader'
require 'ofac/models/ofac'

# Load rake file
load "#{File.dirname(__FILE__)}/tasks/ofac.rake"