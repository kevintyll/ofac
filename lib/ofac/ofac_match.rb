class OfacMatch

  attr_reader :possible_hits

  #Intialize a Match object with a record hash of fields you want to match on.
  #Each key in the hash, also has a data hash value for the weight, token, and type.
  #
  #    match = Ofac::Match.new({:name => {:weight => 10, :token => 'Kevin Tyll'},
  #        :city   => {:weight => 40, :token => 'Clearwater',     },
  #        :address => {:weight => 40, :token => '1234 Park St.',    },
  #        :zip    => {:weight => 10, :token => '33759', :type => :number}})
  #
  # data hash keys:
  #   * <tt>data[:weight]</tt> - value to apply to the score if there is a match (Default is 100/number of key in the record hash)
  #   * <tt>data[:token]</tt> - string to match
  #   * <tt>data[:match]</tt> - set from records hash
  #   * <tt>data[:score]</tt> - output field
  #   * <tt>data[:type]</tt> - the type of match that should be performed (valid values are +:sound+ | +:number+) (Default is +:sound+)
  def initialize(stats={})
    @possible_hits = []
    @stats = stats.dup
    weight = 100
    weight = 100 / @stats.length if @stats.length > 0
    @stats.each_value do |data|
      data[:weight] ||= weight
      data[:match]  ||= ''
      data[:type]   ||= :sound
      data[:score]  ||= 0
      data[:token]  = data[:token].to_s.upcase
    end
  end

  # match_records is an array of hashes.
  #
  # The hash keys must match the record hash keys set when initialized.
  #
  # score will return the highest score of all the records that
  # are sent in match_records.
  def score(match_records)
    score_results = Array.new
    unless match_records.empty?
      #place the match_records information
      #into our @stats hash
      match_records.each do |match|
        match.each do |key, value|
          @stats[key.to_sym][:match] = value.to_s.upcase
        end
        record_score = calculate_record
        score_results.push(record_score)
        @possible_hits << match.merge(:score => record_score) if record_score > 0
      end
      score = score_results.max #take max score
    end
    @possible_hits.uniq!
    score ||= 0
  end

  private


  # calculate the score for this record
  # comparing the token to the match fields in the @stats hash
  # and storing the score into the record
  def calculate_record
    score = 0
    unless @stats.nil?
      #need to make sure we check the name first, since city and address don't
      #get added to the score unless there is a name match
      [:name,:city,:address].each do |field|
        data = @stats[field]
        if (data[:token].blank?)
          value = 0 #token is blank can't be sure of a match if nothing to match against
        else
          if (data[:match].blank?)
            value = 0 #token has value match is blank
          else
            #token and match both have values
            if (data[:type] == :number)
              value = data[:token] == data[:match] ? 1 : 0
            else
              #first see if there is an exact match
              value = data[:token] == data[:match] ? 1 : 0

              unless value > 0
                #do a sounds like with the data as given to see if we get a match
                #if match on sounds_like, only give .75 of the weight.
                value = data[:token].ofac_sounds_like(data[:match],false) ? 0.75 : 0
              end
                
              #if no match, then break the data down and see if we can find matches on the
              #individual words
              unless value > 0
                token_data = data[:token].gsub(/\W/,'|')
                token_array = token_data.split('|')
                token_array.delete('')

                match_data = data[:match].gsub(/\W/,'|')
                match_array = match_data.split('|')
                match_array.delete('')

                value = 0
                partial_weight = 1/token_array.length.to_f
                
                token_array.each do |partial_token|
                  #first see if we get an exact match of the partial
                  if success = match_array.include?(partial_token)
                    value += partial_weight
                  else
                    #otherwise, see if the partial sounds like any part of the OFAC record
                    match_array.each do |partial_match|
                      if partial_match.ofac_sounds_like(partial_token,false)
                        #give partial value for every part of token that is matched.
                        value += partial_weight * 0.75
                        success = true
                        break
                      end
                    end
                  end
                  unless success
                    #if this for :address or :city
                    #and there is no match at all, subtract 10% of the weight from :name score
                    unless field == :name
                      value -= partial_weight * 0.1
                    end
                  end
                end
              end
            end
          end
        end
        data[:score] = data[:weight] * value
        score += data[:score]
        break if field == :name && data[:score] == 0
      end

    end
    score.round
  end

end

