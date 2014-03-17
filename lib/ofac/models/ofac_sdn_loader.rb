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

class OfacSdnLoader
  #Loads the most recent file from http://www.treas.gov/offices/enforcement/ofac/sdn/delimit/index.shtml
  def self.load_current_sdn_file
    puts "Reloading OFAC sdn data"
    puts "Downloading OFAC data from http://www.treas.gov/offices/enforcement/ofac/sdn"
    yield "Downloading OFAC data from http://www.treas.gov/offices/enforcement/ofac/sdn" if block_given?
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
      sdn.rewind
    end
    address = Tempfile.new('sdn')
    address.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(URI.parse('http://www.treasury.gov/ofac/downloads/add.pip')))
    address.rewind
    alt = Tempfile.new('sdn')
    alt.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(URI.parse('http://www.treasury.gov/ofac/downloads/alt.pip')))
    alt.rewind

    if (defined?(ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter) && OfacSdn.connection.kind_of?(ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter)) || (defined?(ActiveRecord::ConnectionAdapters::JdbcAdapter) && OfacSdn.connection.kind_of?(ActiveRecord::ConnectionAdapters::JdbcAdapter))
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
    if @current_address_hash && @current_address_hash[:id] == sdn_id
      address_records << @current_address_hash
      loop do
        @current_address_hash = address_text_to_hash(@address.gets)
        if @current_address_hash && @current_address_hash[:id] == sdn_id
          address_records << @current_address_hash
        else
          break
        end
      end
    end

    if @current_alt_hash && @current_alt_hash[:id] == sdn_id
      alt_records << @current_alt_hash
      loop do
        @current_alt_hash = alt_text_to_hash(@alt.gets)
        if @current_alt_hash && @current_alt_hash[:id] == sdn_id
          alt_records << @current_alt_hash
        else
          break
        end
      end
    end
    return address_records, alt_records
  end

  def self.sdn_text_to_hash(line)
    unless line.nil?
      value_array = convert_line_to_array(line)
      {:id => value_array[0],
       :name => value_array[1],
       :sdn_type => value_array[2],
       :program => value_array[3],
       :title => value_array[4],
       :vessel_call_sign => value_array[5],
       :vessel_type => value_array[6],
       :vessel_tonnage => value_array[7],
       :gross_registered_tonnage => value_array[8],
       :vessel_flag => value_array[9],
       :vessel_owner => value_array[10],
       :remarks => value_array[11]
      }
    end
  end

  def self.address_text_to_hash(line)
    unless line.nil?
      value_array = convert_line_to_array(line)
      {:id => value_array[0],
       :address => value_array[2],
       :city => value_array[3],
       :country => value_array[4],
       :address_remarks => value_array[5]
      }
    end
  end

  def self.alt_text_to_hash(line)
    unless line.nil?
      value_array = convert_line_to_array(line)
      {:id => value_array[0],
       :alternate_identity_type => value_array[2],
       :alternate_identity_name => value_array[3],
       :alternate_identity_remarks => value_array[4]
      }
    end
  end

  def self.convert_hash_to_mysql_import_string(record_hash)
    new_line = "`#{record_hash[:name]}`|" +
        #    :sdn_type
        "`#{record_hash[:sdn_type]}`|" +
        #    :program
        "`#{record_hash[:program]}`|" +
        #    :title
        "`#{record_hash[:title]}`|" +
        #    :vessel_call_sign
        "`#{record_hash[:vessel_call_sign]}`|" +
        #    :vessel_type
        "`#{record_hash[:vessel_type]}`|" +
        #    :vessel_tonnage
        "`#{record_hash[:vessel_tonnage]}`|" +
        #    :gross_registered_tonnage
        "`#{record_hash[:gross_registered_tonnage]}`|" +
        #    :vessel_flag
        "`#{record_hash[:vessel_flag]}`|" +
        #    :vessel_owner
        "`#{record_hash[:vessel_owner]}`|" +
        #    :remarks
        "`#{record_hash[:remarks]}`|" +
        #    :address
        "`#{record_hash[:address]}`|" +
        #    :city
        "`#{record_hash[:city]}`|" +
        #    :country
        "`#{record_hash[:country]}`|" +
        #    :address_remarks
        "`#{record_hash[:address_remarks]}`|" +
        #    :alternate_identity_type
        "`#{record_hash[:alternate_identity_type]}`|" +
        #    :alternate_identity_name
        "`#{record_hash[:alternate_identity_name]}`|" +
        #    :alternate_identity_remarks
        "`#{record_hash[:alternate_identity_remarks]}`|" +
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

      #get the foreign key records for this sdn
      address_records, alt_records = foreign_key_records(sdn_attributes[:id])

      if address_records.empty?
        #no matching address records, so initialized blank values will be used.
        if alt_records.empty?
          #no matching address records, so initialized blank values will be used.
          csv_file.syswrite(convert_hash_to_mysql_import_string(sdn_attributes.merge(address_attributes).merge(alt_attributes)))
        else
          alt_records.each do |alt|
            csv_file.syswrite(convert_hash_to_mysql_import_string(sdn_attributes.merge(address_attributes).merge(alt)))
          end
        end
      else
        address_records.each do |address|
          if alt_records.empty?
            #no matching address records, so initialized blank values will be used.
            csv_file.syswrite(convert_hash_to_mysql_import_string(sdn_attributes.merge(address).merge(alt_attributes)))
          else
            alt_records.each do |alt|
              csv_file.syswrite(convert_hash_to_mysql_import_string(sdn_attributes.merge(address).merge(alt)))
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

  def self.active_record_file_load(sdn_file, address_file, alt_file)
    @address = address_file
    @alt = alt_file

    #OFAC data is a complete list, so we have to dump and load
    OfacSdn.delete_all

    #get the first line from the address and alt files
    @current_address_hash = address_text_to_hash(@address.gets)
    @current_alt_hash = alt_text_to_hash(@alt.gets)
    attributes = {}
    sdn_file.each_with_index do |line, i|

      #initialize the address and alt atributes to empty strings
      address_attributes = address_text_to_hash("|||||")
      alt_attributes = alt_text_to_hash("||||")

      sdn_attributes = sdn_text_to_hash(line)

      #get the foreign key records for this sdn
      address_records, alt_records = foreign_key_records(sdn_attributes[:id])

      if address_records.empty?
        #no matching address records, so initialized blank values will be used.
        if alt_records.empty?
          #no matching address records, so initialized blank values will be used.
          attributes = sdn_attributes.merge(address_attributes).merge(alt_attributes)
          attributes.delete(:id)
          OfacSdn.create(attributes)
        else
          alt_records.each do |alt|
            attributes = sdn_attributes.merge(address_attributes).merge(alt)
            attributes.delete(:id)
            OfacSdn.create(attributes)
          end
        end
      else
        address_records.each do |address|
          if alt_records.empty?
            #no matching address records, so initialized blank values will be used.
            attributes = sdn_attributes.merge(address).merge(alt_attributes)
            attributes.delete(:id)
            OfacSdn.create(attributes)
          else
            alt_records.each do |alt|
              attributes = sdn_attributes.merge(address).merge(alt)
              attributes.delete(:id)
              OfacSdn.create(attributes)
            end
          end
        end
      end
      if (i % 5000 == 0) && (i > 0)
        puts "#{i} records processed."
        yield "#{i} records processed." if block_given?
      end
    end
  end

  # For mysql, use:
  # LOAD DATA LOCAL INFILE 'ssdm1.csv' INTO TABLE death_master_files FIELDS TERMINATED BY '|' ENCLOSED BY "`" LINES TERMINATED BY '\n';
  # This is a much faster way of loading large amounts of data into mysql.  For information on the LOAD DATA command
  # see http://dev.mysql.com/doc/refman/5.1/en/load-data.html
  def self.bulk_mysql_update(csv_file)
    puts "Deleting all records in ofac_sdn..."
    yield "Deleting all records in ofac_sdn..." if block_given?

    #OFAC data is a complete list, so we have to dump and load
    OfacSdn.connection.execute("TRUNCATE ofac_sdns;")

    puts "Importing into Mysql..."
    yield "Importing into Mysql..." if block_given?

    mysql_command = <<-TEXT
    LOAD DATA LOCAL INFILE '#{csv_file.path}' REPLACE INTO TABLE ofac_sdns FIELDS TERMINATED BY '|' ENCLOSED BY "`" LINES TERMINATED BY '\n' (name, sdn_type, program, title, vessel_call_sign, vessel_type, vessel_tonnage, gross_registered_tonnage, vessel_flag, vessel_owner, remarks, address, city, country, address_remarks, alternate_identity_type, alternate_identity_name, alternate_identity_remarks, created_at, updated_at);
    TEXT

    OfacSdn.connection.execute(mysql_command)
    puts "Mysql import complete."
    yield "Mysql import complete." if block_given?

  end

end
