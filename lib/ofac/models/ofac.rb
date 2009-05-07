class Ofac

  attr_reader :ssn,:area,:group,:serial_number,:as_of
  attr_reader :errors


  #Instantiate the object passing in a social security number.
  #The ssn can be a string or integer, with or without the '-'s.
  def initialize(ssn)
    @errors = []
    ssn = ssn.to_s
    if ssn =~ /-/ && ssn !~ /\d\d\d-\d\d-\d\d\d\d/
      @errors << 'Hyphen misplaced.'
    end

    ssn.gsub!('-','')
    if ssn.to_s.size != 9
      @errors <<  'SSN not 9 digits long.'
    end

    if ssn =~ /\D/
      @errors << 'Non-digit found.'
    end

    #known dummy numbers
    if ["078051120","111111111","123456789","219099999","999999999"].include? ssn || (ssn >= "987654320" and ssn <= "987654329")
      @errors << "Known dummy SSN."
    end
    #known invalid area, group and serial numbers
    if ssn =~ /\d{3}00\d{4}|0000\Z/
      @errors << "Invalid group or serial number."
    end

    @ssn = ssn
    @area = ssn.first(3)
    @group = ssn[3,2]
    @serial_number = ssn.last(4)

    if @errors.empty?
      @ssn_high_group_code = SsnHighGroupCode.find_by_area(@area, :order => 'as_of desc')
      if @ssn_high_group_code.nil?
        @errors << "Area '#{@area}' has not been assigned."
      else
        @as_of = @ssn_high_group_code.as_of

        define_group_ranks
          
        if @group_ranks[@group] > @group_ranks[@ssn_high_group_code.group]
          @errors << "Group '#{@group}' has not been assigned yet for area '#{@area}'"
        end
      end
    end


  end

  #Determines whether or not the passed in
  #ssn passed all validations.
  def valid?
    @errors.empty?
  end

  #returns the death master record if there is one.
  def death_master_file_record
    DeathMasterFile.find_by_social_security_number(@ssn)
  end

  #Determines if the passed in ssn belongs to the deceased.
  def death_master_file_hit?
    !death_master_file_record.nil?
  end


  private

  def define_group_ranks
    @group_ranks = {}
    rank = 0
    (1..9).step(2) do |group|
      @group_ranks.merge!("0#{group.to_s}" => rank += 1)
    end
    (10..98).step(2) do |group|
      @group_ranks.merge!(group.to_s => rank += 1)
    end
    (2..8).step(2) do |group|
      @group_ranks.merge!("0#{group.to_s}" => rank += 1)
    end
    (11..99).step(2) do |group|
      @group_ranks.merge!(group.to_s => rank += 1)
    end
  end
end
