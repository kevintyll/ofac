
namespace :ofac do
  desc "Loads the current file from http://www.treas.gov/offices/enforcement/ofac/sdn/delimit/index.shtml."
  task :update_data => :environment do
    OfacSdnLoader.load_current_sdn_file
  end

end