require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacXmlLoaderTest < ActiveSupport::TestCase

  context OfacXmlLoader do

    should "load emails from XML multiple times and always have the same record count" do
      assert_equal(0, Email.count)
      load_test_sdn_file
      assert_equal(2, Email.count)
      load_test_sdn_file
      assert_equal(2, Email.count)
    end

    should "give nil ofac_sdn_individual to email object representing company" do  # because only individuals are stored into OfacSdnIndividual
      load_test_sdn_file

      first = Email.first
      assert_equal('advance@sudanmail.net', first.email)
      assert_nil(first.ofac_sdn_individual)

      last = Email.first(2).last
      assert_equal('accw@htg-sdn.com', last.email)
      assert_nil(last.ofac_sdn_individual)
    end

    should "parse company names" do
      assert_equal(0, Company.count)
      load_test_sdn_file
      assert_equal(8, Company.count)
    end

    should "parse websites" do
      assert_equal(0, Website.count)
      load_test_sdn_file
      assert_equal(1, Website.count)
      assert_equal('www.csc-sb.hr', Website.first.website)
    end
  end

  def load_test_sdn_file
    loader = OfacXmlLoader.new

    sdn = File.open(File.dirname(__FILE__) + '/../files/test_sdn_data_load.xml')
    loader.load_sdn(sdn)

    sdn.close
  end

end
