Rails.application.routes.draw do

  mount Ofac::Engine => '/ofac'

end