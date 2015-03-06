require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacSearcherTest < ActiveSupport::TestCase

  def setup
    loader = OfacXmlLoader.new

    sdn = File.open(File.dirname(__FILE__) + '/../files/test_sdn_data_load.xml')
    loader.load_sdn(sdn)

    sdn.close

    @searcher = OfacSearcher.new
  end

  context OfacSearcher do
    should "not be able to find what is not there" do
      list = @searcher.search({name: 'Test'})

      assert_equal(0, list.count)
    end

    should "find exact match on email" do
      list = @searcher.search({name: 'Test', email: 'accw@htg-sdn.com'})

      assert_equal(1, list.count)
      assert_equal(90, list.first[:score])
    end

    should "not find match on non-blocked email" do
      list = @searcher.search({name: 'Test', email: 'alexei@vidmich.com'})

      assert_equal(0, list.count)
    end
  end

end