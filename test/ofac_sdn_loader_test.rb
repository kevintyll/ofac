require 'test_helper'

class OfacSdnLoaderTest < Test::Unit::TestCase

  context '' do
    setup do setup_ofac_sdn_table end

    should "load table from files multiple times and always have the same record count" do
      assert_equal(0,OfacSdn.count)
      OfacSdnLoader.load_current_sdn_file
      assert_equal(19, OfacSdn.count)
      OfacSdnLoader.load_current_sdn_file
      assert_equal(19, OfacSdn.count)
    end

    should "create flattened_csv_file_for_mysql_import" do
      #since, I'm using sqlight3 for it's in memory db, I can't test the mysql load
      #but I can test the csv file creation.
      sdn = File.new(File.dirname(__FILE__) + '/files/test_sdn_data_load.pip')
      address = File.new(File.dirname(__FILE__) + '/files/test_address_data_load.pip')
      alt = File.new(File.dirname(__FILE__) + '/files/test_alt_data_load.pip')

      csv = OfacSdnLoader.create_csv_file(sdn, address, alt) #this method was created in the mock only to call the private convert_to_flattened_csv method
      correctly_formatted_csv = File.open(File.dirname(__FILE__) + '/files/valid_flattened_file.csv')

      csv.rewind
      generated_file = csv.readlines
      #compare the values of each csv line, with the correctly formated "control file"
      correctly_formatted_csv.each_with_index do |line,i|
        csv_line = generated_file[i]
        correctly_formatted_record_array = line.split('|')
        csv_record_array = csv_line.split('|')
        (0..18).each do |i| #skip indices 19 and 20, they are the created_at and updated_at fields, they will never match.
          assert_equal correctly_formatted_record_array[i], csv_record_array[i]
        end
      end
    end

  end
end
