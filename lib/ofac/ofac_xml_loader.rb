require 'nokogiri'

class OfacXmlLoader
  def load_sdn(file)

    Email.delete_all
    Company.delete_all
    Website.delete_all
    Phone.delete_all

    doc = Nokogiri::XML(file)
    doc.remove_namespaces!

    doc.xpath('/sdnList/sdnEntry').each do |entry|
      uid = entry.at_xpath('uid/text()').to_s.to_i
      entry.xpath('idList/id[idType = "Email Address"]/idNumber/text()').each do |idNumber|
        add_email(idNumber.to_s, uid)
      end
    end
  end

  def add_email(email, uid)
    sdn = OfacSdnIndividual.find(uid)
    attributes = {email: email, ofac_sdn_individual: sdn}
    Email.create(attributes)
  end
end