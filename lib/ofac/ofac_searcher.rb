class OfacSearcher
  def search(params)
    ofac = OfacIndividual.new(params)

    hits = []
    hits << ofac.possible_hits
    hits << search_email_hits(params[:email]).collect(&:ofac_sdn_individual).collect {|sdn|{:name => "#{sdn.name}|#{sdn.alternate_identity_name}", :city => sdn.city, :address => sdn.address}}

  end

  def search_email_hits(email)
    Email.where(email: email)
  end

  def search_company_hits(company)

  end

  def search_website_hits(website)

  end

  def search_phone_hits(phone)

  end
end