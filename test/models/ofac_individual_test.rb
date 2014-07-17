require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OfacIndividualTest < ActiveSupport::TestCase

  context OfacIndividual do
    setup do
      load_test_sdn_file
    end

    context '#score' do
      should "give a score of 0 if no name is given" do
        assert_equal 0, OfacIndividual.new({:address => '123 somewhere'}).score
        assert_equal 0, OfacIndividual.new({:name => ''}).score
        assert_equal 0, OfacIndividual.new({:name => ' '}).score
        assert_equal 0, OfacIndividual.new({:name => nil}).score
        assert_equal 0, OfacIndividual.new({:name => {:first_name => '', :last_name => ' '}}).score
        assert_equal 0, OfacIndividual.new({:name => {:first_name => '', :last_name => '  '}}).score
        assert_equal 0, OfacIndividual.new({:name => 'P T'}).score
      end

      should "give a score of 0 if there is no name match" do
        assert_equal 0, OfacIndividual.new({:name => 'Kevin T P'}).score
        assert_equal 0, OfacIndividual.new({:name => "O'Brian"}).score
        assert_equal 0, OfacIndividual.new({:name => {:first_name => 'Matthew', :last_name => "O'Brian"}}).score
        assert_equal 0, OfacIndividual.new({:name => 'Kevin', :address => '123 somewhere ln', :city => 'Clearwater'}).score
      end

      should "give a score of 60 if there is a name match" do
        assert_equal 60, OfacIndividual.new({:name => 'Oscar Hernandez'}).score
        assert_equal 60, OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => 'Hernandez'}}).score
      end

      should "be backward compatible with Ofac.new" do
        assert_equal 60, Ofac.new({:name => {first_name: 'Oscar', last_name: 'Hernandez'}}).score
      end

      should "stip punctuation from names and still match" do
        assert_equal 60, Ofac.new({:name => {first_name: "Al-Rahman", last_name: 'AGUIAR'}}).score
      end

      should "give a score of 30 if there is only a partial match" do
        assert_equal 30, OfacIndividual.new({:name => 'Oscar de la Hernandez'}).score
        assert_equal 30, OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => 'de la Hernandez'}}).score
      end

      should 'get a score when there are multiple first names' do
        assert_equal 36, OfacIndividual.new({:name => {:first_name => 'Incredibly Long Name', :last_name => 'No Match'}}).score
        assert_equal 36, OfacIndividual.new({:name => 'Incredibly Long Name No Match'}).score
      end

      should "handle first or last name not given" do
        assert_equal 60, OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => ''}}).score
        assert_equal 60, OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => nil}}).score
        assert_equal 60, OfacIndividual.new({:name => {:first_name => nil, :last_name => 'Oscar'}}).score
        assert_equal 60, OfacIndividual.new({:name => {:first_name => 'Oscar'}}).score
        assert_equal 60, OfacIndividual.new({:name => {:first_name => '', :last_name => 'Oscar'}}).score
        assert_equal 60, OfacIndividual.new({:name => {:last_name => 'Oscar'}}).score
      end

      should "deduct scores for non matches on address if data is in the database" do
        #if there is data for address or city in the database, and that info is passed in, then 10%
        #of the weight will be deducted if there is no match or sounds like match

        #name and city match
        assert_equal 89, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => 'no match'}).score
        #the record is pulled because clear is like clearwater, but it's not a match
        #score = 60 for name  - (30 * .1) for Clear = 57
        assert_equal 57, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clear'}).score
      end

      should "not deduct from score if no data for city or address is in the database" do
        assert_equal 60, OfacIndividual.new({:name => 'Luis Lopez', :city => 'no match', :address => 'no match'}).score
      end

      should "give a score of 60 if there is a name match on alternate identity name" do
        assert_equal 60, OfacIndividual.new({:name => 'Alternate Name'}).score
      end

      should "give a partial score if there is a partial name match" do
        assert_equal 40, OfacIndividual.new({:name => 'Oscar middlename Hernandez'}).score
        assert_equal 30, OfacIndividual.new({:name => 'Oscar WrongLastName'}).score
        assert_equal 70, OfacIndividual.new({:name => 'Oscar middlename Hernandez', :city => 'Clearwater'}).score
      end

      should "give a score of 90 if there is a name and city match" do
        assert_equal 90, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater'}).score
      end

      should "give a score of 100 if there is a name and city and address match" do
        assert_equal 100, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'}).score
      end

      should "give partial scores for sounds like matches" do

        #32456 summer lane sounds like 32456 Somewhere ln so is adds 75% of the address weight to the score, or 8.
        assert_equal 98, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '32456 summer lane'}).score

        #Louis Eduardo Lopez Mendez sounds like Luis Eduardo Lopez Mendez:
        #:name has a weight of 60, so a sounds like is worth 45
        assert_equal 45, OfacIndividual.new({:name => {:first_name => 'Louis Eduardo', :last_name => 'Lopez Mendez'}, :city => 'Las Vegas', :address => 'no match'}).score
      end
    end

    context '#possible_hits' do
      should 'not give partial scores if sounds like does not match the entire string' do
        #summer sounds like somewhere, and all numbers sound alike, so 2 of the 3 address elements match by sound
        #but the whole thing does not make a sounds like match so only city matches, subtract 1 for no address match
        assert_equal 89, OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '12358 summer blvd'}).score
      end

      should "return an array of possible hits" do
        #it should not matter which order you call score or possible hits.
        sdn = OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'})
        assert sdn.score > 0
        assert !sdn.possible_hits.empty?

        sdn = OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'})
        assert !sdn.possible_hits.empty?
        assert sdn.score > 0
      end
    end

    context '#db_hit?' do
      should "return true if name is an 'exact' match in the database" do

        sdn = OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => 'Hernandez'}, :city => 'Clearwater', :address => '123 somewhere ln'})
        assert sdn.db_hit?

        sdn = OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'})
        assert sdn.db_hit?

        #single initials are ignored
        sdn = OfacIndividual.new({:name => 'Oscar M Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'})
        assert sdn.db_hit?

        #city and address are ignored
        sdn = OfacIndividual.new({:name => 'Oscar Hernandez', :city => 'bad city', :address => 'bad address'})
        assert sdn.db_hit?
      end

      should "should be case insensitive for the name" do
        sdn = OfacIndividual.new({:name => {:first_name => 'OSCAR', :last_name => 'hernandez'}, :city => 'Clearwater', :address => '123 somewhere ln'})
        assert sdn.db_hit?
      end

      should "return false if name is not an exact match in the database" do

        sdn = OfacIndividual.new({:name => {:first_name => 'Oscar', :last_name => 'de la Hernandez'}, :city => 'Clearwater', :address => '123 somewhere ln'})
        assert !sdn.db_hit?

        sdn = OfacIndividual.new({:name => 'Oscar Maria Hernandez', :city => 'Clearwater', :address => '123 somewhere ln'})
        assert !sdn.db_hit?

        #city and address are ignored
        sdn = OfacIndividual.new({:name => 'Oscar de la Hernandez', :city => 'bad city', :address => 'bad address'})
        assert !sdn.db_hit?
      end
    end
  end
end