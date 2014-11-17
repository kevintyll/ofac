require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacXmlLoaderTest < ActiveSupport::TestCase

  def setup
    OfacSdnIndividual.create(id: 10190)
  end

  context OfacXmlLoader do

    should "load emails from XML multiple times and always have the same record count" do
      assert_equal(0, Email.count)
      load_test_sdn_file
      assert_equal(2, Email.count)
      load_test_sdn_file
      assert_equal(2, Email.count)
    end

  end

  def load_test_sdn_file
    loader = OfacXmlLoader.new

    sdn = File.open(File.dirname(__FILE__) + '/../files/test_sdn_data_load.xml')
    loader.load_sdn(sdn)

    sdn.close
  end

end
