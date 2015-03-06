class OfacSearcher
  def search(params)
    ofac = OfacIndividual.new(params)

    hits = ofac.possible_hits
    hits.concat collect_sdn_hashes search_email_hits params[:email]
    hits.concat collect_sdn_hashes search_company_hits params[:company]
    hits.concat collect_sdn_hashes search_website_hits params[:website]

    hits.sort_by { |h| -h[:score] }

  end

  def search_email_hits(email)
    Email.where(email: email)
  end

  def search_company_hits(company)
    Company.where(name: company)
  end

  def search_website_hits(website)
    Website.where(website: website)
  end

  def collect_sdn_hashes(list)
    list.collect(&:ofac_sdn_individual).collect { |sdn|

      hash = {}
      if sdn
        hash = {
            :name => "#{sdn.name}|#{sdn.alternate_identity_name}",
            :city => sdn.city,
            :address => sdn.address
        }
      end

      hash[:score] = 90

      hash
    }
  end
end