require 'test/unit'
require 'turn'
require 'shoulda'
require 'mocks/test/ofac_sdn_loader'

# for RubyMine
require 'minitest/reporters'
MiniTest::Reporters.use! [MiniTest::Reporters::RubyMineReporter.new] if ENV["RUBYMINE_TESTUNIT_REPORTER"]

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ofac'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Test::Unit::TestCase
  def setup_ofac_sdn_table
    ActiveRecord::Base.connection.tables.each { |table| ActiveRecord::Base.connection.drop_table(table) }
    create_ofac_sdn_table
  end

  private

  def create_ofac_sdn_table
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(:version => 1) do
        create_table :ofac_sdns do |t|
          t.text      :name
          t.string    :sdn_type
          t.string    :program
          t.string    :title
          t.string    :vessel_call_sign
          t.string    :vessel_type
          t.string    :vessel_tonnage
          t.string    :gross_registered_tonnage
          t.string    :vessel_flag
          t.string    :vessel_owner
          t.text      :remarks
          t.text      :address
          t.string    :city
          t.string    :country
          t.string    :address_remarks
          t.string    :alternate_identity_type
          t.text      :alternate_identity_name
          t.string    :alternate_identity_remarks
          t.timestamps
        end
        add_index :ofac_sdns, :sdn_type
      end
    end
  end

end
