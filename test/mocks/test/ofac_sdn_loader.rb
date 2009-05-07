require 'ofac/models/ofac_sdn_loader'

class OfacSdnLoader

  def self.load_current_sdn_file
    sdn = File.new(File.dirname(__FILE__) + '/../../files/test_sdn_data_load.pip')
    address = File.new(File.dirname(__FILE__) + '/../../files/test_address_data_load.pip')
    alt = File.new(File.dirname(__FILE__) + '/../../files/test_alt_data_load.pip')
    active_record_file_load(sdn, address, alt)
    sdn.close
    address.close
    alt.close
  end

  #Gives access to the private convert_to_flattened_csv method
  def self.create_csv_file(sdn, address, alt)
    convert_to_flattened_csv(sdn, address, alt)
  end

end
