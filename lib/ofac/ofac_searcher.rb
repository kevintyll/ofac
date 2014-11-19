class OfacSearcher
  def search(params)
    ofac = OfacIndividual.new(params)

    hits = ofac.possible_hits

    other_hits = []
    other_hits << collect_sdn_hashes(search_email_hits(params[:email]))
    other_hits << collect_sdn_hashes(search_company_hits(params[:company]))
    other_hits << collect_sdn_hashes(search_website_hits(params[:website]))
    # other_hits << collect_sdn_hashes(search_phone_hits(params[:phone]))



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

  # def search_phone_hits(phone)
  #   Phone.where(phone: phone) # todo: needs better matching
  # end

  def collect_sdn_hashes(list)
    list.collect(&:ofac_sdn_individual).collect { |sdn|

      if sdn
        {
            :name => "#{sdn.name}|#{sdn.alternate_identity_name}",
            :city => sdn.city,
            :address => sdn.address
        }
      else
        {}
      end
    }
  end
end