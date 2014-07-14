module Ofac
  # making this an engine gives us the rake task to copy the migrations to your application: rake ofac_engine:install:migrations
  # as well as the rake tasks defined in this gem in your application
  class Engine < ::Rails::Engine
  end
end
