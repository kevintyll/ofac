require 'net/http'
require 'active_record'
require 'tempfile'
begin
  require 'active_record/connection_adapters/mysql2_adapter'
rescue Gem::LoadError, LoadError
  begin
    require 'active_record/connection_adapters/mysql_adapter'
  rescue Gem::LoadError, LoadError
    puts 'Not using mysql, will use active record to load data'
  end
end

class OfacSdnIndividualLoader
  def self.load_current_sdn_file
    puts "Reloading OFAC sdn data"
    puts "Downloading OFAC data from http://www.treasury.gov/resource-center/sanctions/SDN-List/Pages/default.aspx"
    yield "Downloading OFAC data from http://www.treasury.gov/resource-center/sanctions/SDN-List/Pages/default.aspx" if block_given?
    #get the 3 data files
    sdn = Tempfile.new('sdn')
    uri = URI.parse('http://www.treasury.gov/ofac/downloads/sdn.pip')
    proxy_addr, proxy_port = ENV['http_proxy'].gsub("http://", "").split(/:/) if ENV['http_proxy']

    bytes = sdn.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(uri))
    sdn.rewind
    if bytes == 0 || convert_line_to_array(sdn.readline).size != 12
      puts "Trouble downloading file.  The url may have changed."
      yield "Trouble downloading file.  The url may have changed." if block_given?
      return
    else
      puts "downloaded #{uri}"
      sdn.rewind
    end
    address = Tempfile.new('sdn')
    uri = URI.parse('http://www.treasury.gov/ofac/downloads/add.pip')
    address.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(uri))
    puts "downloaded #{uri}"
    address.rewind
    alt = Tempfile.new('sdn')
    uri = URI.parse('http://www.treasury.gov/ofac/downloads/alt.pip')
    alt.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(uri))
    puts "downloaded #{uri}"
    alt.rewind

    if (defined?(ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter) && OfacSdnIndividual.connection.kind_of?(ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter)) || (defined?(ActiveRecord::ConnectionAdapters::JdbcAdapter) && OfacSdnIndividual.connection.kind_of?(ActiveRecord::ConnectionAdapters::JdbcAdapter))
      puts "Converting file to csv format for Mysql import.  This could take several minutes."
      yield "Converting file to csv format for Mysql import.  This could take several minutes." if block_given?

      csv_file = convert_to_flattened_csv(sdn, address, alt) do |status|
        yield status if block_given?
      end

      bulk_mysql_update(csv_file) do |status|
        yield status if block_given?
      end
    else
      active_record_file_load(sdn, address, alt) do |status|
        yield status if block_given?
      end
    end

    sdn.close
    @address.close
    @alt.close
  end

  def self.active_record_file_load(sdn_file, address_file, alt_file)
    @address = address_file
    @alt = alt_file

    #OFAC data is a complete list, so we have to dump and load
    OfacSdnIndividual.delete_all

    #get the first line from the address and alt files
    @current_address_hash = address_text_to_hash(@address.gets)
    @current_alt_hash = alt_text_to_hash(@alt.gets)
    attributes = {}
    sdn_file.each_with_index do |line, i|

      if (i % 1000 == 0) && (i > 0)
        puts "#{i} records processed."
        yield "#{i} records processed." if block_given?
      end

      #initialize the address and alt atributes to empty strings
      address_attributes = address_text_to_hash("|||||")
      alt_attributes = alt_text_to_hash("||||")

      sdn_attributes = sdn_text_to_hash(line)

      if sdn_attributes.present?
        #get the foreign key records for this sdn
        address_records, alt_records = foreign_key_records(sdn_attributes[:id])

        if address_records.empty?
          #no matching address records, so initialized blank values will be used.
          if alt_records.empty?
            #no matching address records, so initialized blank values will be used.
            attributes = sdn_attributes.merge(address_attributes).merge(alt_attributes)
            attributes.delete(:id)
            OfacSdnIndividual.create(attributes)
          else
            alt_records.each do |alt|
              attributes = sdn_attributes.merge(address_attributes).merge(alt)
              attributes.delete(:id)
              OfacSdnIndividual.create(attributes)
            end
          end
        else
          address_records.each do |address|
            if alt_records.empty?
              #no matching address records, so initialized blank values will be used.
              attributes = sdn_attributes.merge(address).merge(alt_attributes)
              attributes.delete(:id)
              OfacSdnIndividual.create(attributes)
            else
              alt_records.each do |alt|
                attributes = sdn_attributes.merge(address).merge(alt)
                attributes.delete(:id)
                OfacSdnIndividual.create(attributes)
              end
            end
          end
        end
      end
    end
  end

  private

  #convert the file's null value to an empty string
  #and removes " chars.
  def self.clean_file_string(line)
    line.gsub!(/-0-(\s)?/, '')
    line.gsub!(/[\n\r"]/, '')
    line
  end

  #split the line into an array
  def self.convert_line_to_array(line)
    clean_file_string(line).split('|', -1) unless line.nil?
  end

  #return an 2 arrays of the records matching the sdn primary key
  #1 array of address records and one array of alt records
  def self.foreign_key_records(sdn_id)
    address_records = []
    alt_records = []

    #the first element in each array is the primary and foreign keys
    #we are denormalizing the data
    loop do
      break if @current_address_hash.blank? || @current_address_hash[:id].to_i > sdn_id.to_i
      if @current_address_hash && @current_address_hash[:id] == sdn_id
        address_records << @current_address_hash
      end
      @current_address_hash = address_text_to_hash(@address.gets)
    end

    loop do
      break if @current_alt_hash.blank? || @current_alt_hash[:id].to_i > sdn_id.to_i
      if @current_alt_hash && @current_alt_hash[:id] == sdn_id
        alt_records << @current_alt_hash
      end
      @current_alt_hash = alt_text_to_hash(@alt.gets)
    end
    return address_records.uniq, alt_records.uniq
  end

  def self.sdn_text_to_hash(line)
    if line.present?
      value_array = convert_line_to_array(line)
      if value_array[2] == 'individual' # sdn_type
        last_name, first_name = value_array[1].to_s.split(',')
        last_name.try(:gsub!, /[[:punct:]]/, '')
        first_name1, first_name2, first_name3, first_name4, first_name5, first_name6, first_name7, first_name8 = first_name.try(:gsub, /[[:punct:]]/, '').try(:split, ' ')
        {id: value_array[0],
         last_name: last_name.try(:upcase),
         first_name_1: first_name1.try(:upcase),
         first_name_2: first_name2.try(:upcase),
         first_name_3: first_name3.try(:upcase),
         first_name_4: first_name4.try(:upcase),
         first_name_5: first_name5.try(:upcase),
         first_name_6: first_name6.try(:upcase),
         first_name_7: first_name7.try(:upcase),
         first_name_8: Array(first_name8).first.try(:upcase) # in case the first name has more than 8 parts, only take up to 8.
        }
      end
    end
  end

  def self.address_text_to_hash(line)
    unless line.nil?
      value_array = convert_line_to_array(line)
      {:id => value_array[0],
       :address => value_array[2].try(:upcase),
       :city => value_array[3].try(:upcase)
      }
    end
  end

  def self.alt_text_to_hash(line)
    unless line.nil?
      value_array = convert_line_to_array(line)
      alternate_last_name, alternate_first_name = value_array[3].to_s.split(',')
      alternate_last_name.try(:gsub!, /[[:punct:]]/, '')
      alternate_first_name1, alternate_first_name2, alternate_first_name3, alternate_first_name4, alternate_first_name5, alternate_first_name6, alternate_first_name7, alternate_first_name8 = alternate_first_name.try(:gsub, /[[:punct:]]/, '').try(:split, ' ')
      {:id => value_array[0],
       alternate_last_name: alternate_last_name.try(:upcase),
       alternate_first_name_1: alternate_first_name1.try(:upcase),
       alternate_first_name_2: alternate_first_name2.try(:upcase),
       alternate_first_name_3: alternate_first_name3.try(:upcase),
       alternate_first_name_4: alternate_first_name4.try(:upcase),
       alternate_first_name_5: alternate_first_name5.try(:upcase),
       alternate_first_name_6: alternate_first_name6.try(:upcase),
       alternate_first_name_7: alternate_first_name7.try(:upcase),
       alternate_first_name_8: Array(alternate_first_name8).first.try(:upcase) # in case the alternate_first name has more than 8 parts, only take up to 8.
      }
    end
  end

  def self.convert_hash_to_mysql_import_string(record_hash)
    new_line =
        "`#{record_hash[:last_name]}`|" +
            "`#{record_hash[:first_name_1]}`|" +
            "`#{record_hash[:first_name_2]}`|" +
            "`#{record_hash[:first_name_3]}`|" +
            "`#{record_hash[:first_name_4]}`|" +
            "`#{record_hash[:first_name_5]}`|" +
            "`#{record_hash[:first_name_6]}`|" +
            "`#{record_hash[:first_name_7]}`|" +
            "`#{record_hash[:first_name_8]}`|" +
            "`#{record_hash[:alternate_last_name]}`|" +
            "`#{record_hash[:alternate_first_name_1]}`|" +
            "`#{record_hash[:alternate_first_name_2]}`|" +
            "`#{record_hash[:alternate_first_name_3]}`|" +
            "`#{record_hash[:alternate_first_name_4]}`|" +
            "`#{record_hash[:alternate_first_name_5]}`|" +
            "`#{record_hash[:alternate_first_name_6]}`|" +
            "`#{record_hash[:alternate_first_name_7]}`|" +
            "`#{record_hash[:alternate_first_name_8]}`|" +
            "`#{record_hash[:address]}`|" +
            "`#{record_hash[:city]}`|" +
            #:created_at
            "`#{@db_time}`|" +
            # updated_at
            "`#{@db_time}`" + "\n"
    new_line
  end

  def self.convert_to_flattened_csv(sdn_file, address_file, alt_file)
    @address = address_file
    @alt = alt_file

    @db_time = Time.now.to_s(:db)

    csv_file = Tempfile.new("ofac") # create temp file for converted csv format.
    #get the first line from the address and alt files
    @current_address_hash = address_text_to_hash(@address.gets)
    @current_alt_hash = alt_text_to_hash(@alt.gets)

    start = Time.now
    sdn_file.each_with_index do |line, i|

      #initialize the address and alt atributes to empty strings
      address_attributes = address_text_to_hash("|||||")
      alt_attributes = alt_text_to_hash("||||")

      sdn_attributes = sdn_text_to_hash(line)

      if sdn_attributes.present?
        #get the foreign key records for this sdn
        address_records, alt_records = foreign_key_records(sdn_attributes[:id])

        if address_records.empty?
          #no matching address records, so initialized blank values will be used.
          if alt_records.empty?
            #no matching address records, so initialized blank values will be used.
            record = convert_hash_to_mysql_import_string(sdn_attributes.merge(address_attributes).merge(alt_attributes))
            csv_file.syswrite(record) if record
          else
            alt_records.each do |alt|
              record = convert_hash_to_mysql_import_string(sdn_attributes.merge(address_attributes).merge(alt))
              csv_file.syswrite(record) if record
            end
          end
        else
          address_records.each do |address|
            if alt_records.empty?
              #no matching address records, so initialized blank values will be used.
              record = convert_hash_to_mysql_import_string(sdn_attributes.merge(address).merge(alt_attributes))
              csv_file.syswrite(record) if record
            else
              alt_records.each do |alt|
                record = convert_hash_to_mysql_import_string(sdn_attributes.merge(address).merge(alt))
                csv_file.syswrite(record) if record
              end
            end
          end
        end
      end
      if (i % 1000 == 0) && (i > 0)
        puts "#{i} records processed."
        yield "#{i} records processed." if block_given?
      end
    end
    puts "File conversion ran for #{(Time.now - start) / 60} minutes."
    yield "File conversion ran for #{(Time.now - start) / 60} minutes." if block_given?
    return csv_file
  end

  # For mysql, use:
  # LOAD DATA LOCAL INFILE 'ssdm1.csv' INTO TABLE death_master_files FIELDS TERMINATED BY '|' ENCLOSED BY "`" LINES TERMINATED BY '\n';
  # This is a much faster way of loading large amounts of data into mysql.  For information on the LOAD DATA command
  # see http://dev.mysql.com/doc/refman/5.1/en/load-data.html
  def self.bulk_mysql_update(csv_file)
    puts "Deleting all records in ofac_sdn_individuals..."
    yield "Deleting all records in ofac_sdn_individuals..." if block_given?

    #OFAC data is a complete list, so we have to dump and load
    OfacSdnIndividual.connection.execute("TRUNCATE ofac_sdn_individuals;")

    puts "Importing into Mysql..."
    yield "Importing into Mysql..." if block_given?

    mysql_command = <<-TEXT
    LOAD DATA LOCAL INFILE '#{csv_file.path}' REPLACE INTO TABLE ofac_sdn_individuals FIELDS TERMINATED BY '|' ENCLOSED BY "`" LINES TERMINATED BY '\n' (last_name, first_name_1, first_name_2, first_name_3, first_name_4, first_name_5, first_name_6, first_name_7, first_name_8, alternate_last_name, alternate_first_name_1, alternate_first_name_2, alternate_first_name_3, alternate_first_name_4, alternate_first_name_5, alternate_first_name_6, alternate_first_name_7, alternate_first_name_8, address, city, created_at, updated_at);
    TEXT

    OfacSdnIndividual.connection.execute(mysql_command)
    puts "Mysql import complete."
    yield "Mysql import complete." if block_given?

  end

end
