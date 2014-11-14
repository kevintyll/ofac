require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacXmlLoaderTest < ActiveSupport::TestCase

  context OfacXmlLoader do
    should "load emails from XML multiple times and always have the same record count" do
      assert_equal(0, OfacSdnIndividual.count)
      load_test_sdn_file
      # there are 19 records total but only 8 unique individual records
      assert_equal(8, OfacSdnIndividual.count)
      load_test_sdn_file
      assert_equal(8, OfacSdnIndividual.count)
    end

  end
end
