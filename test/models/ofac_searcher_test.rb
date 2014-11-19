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
    should "not find what is not there" do
      list = @searcher.search({name: 'Test'})

      puts "list: #{list}"

      assert_equal(0, list.count)
    end
  end

end