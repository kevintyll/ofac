require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacSdnIndividualLoaderTest < ActiveSupport::TestCase

  context OfacSdnIndividualLoader do
    should "load table from files multiple times and always have the same record count with only individual sdn_type records" do
      assert_equal(0, OfacSdnIndividual.count)
      load_test_sdn_file
      # there are 19 records total but only 8 unique individual records
      assert_equal(8, OfacSdnIndividual.count)
      load_test_sdn_file
      assert_equal(8, OfacSdnIndividual.count)
    end

    should 'only load the first 8 parts of the first and alternate identity first names' do
      load_test_sdn_file
      test = OfacSdnIndividual.find_by(last_name: 'ABDELNUR')
      # original value of both name and alternate identity name is A Really Very Extraordinary Incredibly Long First Name Extra
      assert_equal 'A', test.first_name_1
      assert_equal 'A', test.alternate_first_name_1
      assert_equal 'REALLY', test.alternate_first_name_2
      assert_equal 'REALLY', test.first_name_2
      assert_equal 'VERY', test.alternate_first_name_3
      assert_equal 'VERY', test.first_name_3
      assert_equal 'EXTRAORDINARY', test.alternate_first_name_4
      assert_equal 'EXTRAORDINARY', test.first_name_4
      assert_equal 'INCREDIBLY', test.alternate_first_name_5
      assert_equal 'INCREDIBLY', test.first_name_5
      assert_equal 'LONG', test.alternate_first_name_6
      assert_equal 'LONG', test.first_name_6
      assert_equal 'FIRST', test.alternate_first_name_7
      assert_equal 'FIRST', test.first_name_7
      assert_equal 'NAME', test.alternate_first_name_8
      assert_equal 'NAME', test.first_name_8
    end

    should 'upcase and remove punctuation' do
      load_test_sdn_file
      test = OfacSdnIndividual.find_by(last_name: 'AGUIAR')
      # original value of first name is al-Rahman
      assert_equal 'ALRAHMAN', test.first_name_1
    end
    should "create flattened_csv_file_for_mysql_import" do
      #since, I'm using sqlight3 for it's in memory db, I can't test the mysql load
      #but I can test the csv file creation.
      sdn = File.new(File.dirname(__FILE__) + '/../files/test_sdn_data_load.pip')
      address = File.new(File.dirname(__FILE__) + '/../files/test_address_data_load.pip')
      alt = File.new(File.dirname(__FILE__) + '/../files/test_alt_data_load.pip')

      csv = OfacSdnIndividualLoader.new.send(:convert_to_flattened_csv, sdn, address, alt)
      correctly_formatted_csv = File.open(File.dirname(__FILE__) + '/../files/valid_flattened_file.csv')

      csv.rewind
      generated_file = csv.readlines
      #compare the values of each csv line, with the correctly formated "control file"
      correctly_formatted_csv.each_with_index do |line, i|
        csv_line = generated_file[i]
        correctly_formatted_record_array = line.split('|')
        csv_record_array = csv_line.split('|')
        (0..9).each do |i| #skip indices 10 and 11, they are the created_at and updated_at fields, they will never match.
          assert_equal correctly_formatted_record_array[i], csv_record_array[i]
        end
      end
    end

  end
end
