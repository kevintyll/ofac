require 'rake'
require 'ofac/models/ofac_sdn'
require 'ofac/models/ofac_sdn_loader'
require 'ofac/models/ofac'

# Load rake file
import "#{File.dirname(__FILE__)}/tasks/ofac.rake"