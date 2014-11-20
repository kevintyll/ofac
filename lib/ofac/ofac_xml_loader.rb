require 'nokogiri'

class OfacXmlLoader

  def load_current_sdn_file
    proxy_addr, proxy_port = ENV['http_proxy'].gsub("http://", "").split(/:/) if ENV['http_proxy']

    xml_file = Tempfile.new('sdn')
    uri = URI.parse('http://www.treasury.gov/ofac/downloads/sdn.xml')
    xml_file.write(Net::HTTP::Proxy(proxy_addr, proxy_port).get(uri))
    xml_file.rewind

    puts "downloaded #{uri}"

    load_sdn(xml_file)

    xml_file.close

    puts "done processing xml input file"
  end

  def load_sdn(file)

    Email.delete_all
    Company.delete_all
    Website.delete_all

    doc = Nokogiri::XML(file)
    doc.remove_namespaces!

    doc.xpath('/sdnList/sdnEntry').each do |entry|
      uid = entry.at_xpath('uid/text()').to_s.to_i

      entry.xpath('idList/id[idType = "Email Address"]/idNumber/text()').each do |idNumber|
        add_email(idNumber.to_s, uid)
      end
    end

    doc.xpath('/sdnList/sdnEntry[sdnType = "Entity"]').each do |entry|
      add_company(entry.at_xpath('lastName/text()').to_s)
      entry.xpath('akaList/aka/lastName/text()').each do |name|
        add_company(name.to_s)
      end

      entry.xpath('idList/id[idType = "Website"]/idNumber/text()').each do |website|
        add_website(website.to_s)
      end
    end
  end

  def add_email(email, uid)
    sdn = OfacSdnIndividual.find_by_id(uid)
    Email.create({email: email, ofac_sdn_individual: sdn})
  end

  def add_company(name)
    Company.create({name: name, ofac_sdn_individual: nil})
  end

  def add_website(website)
    website.gsub!(/http:\/\//, '')
    website.delete!(':/')
    Website.create({website: website, ofac_sdn_individual: nil})
  end
end