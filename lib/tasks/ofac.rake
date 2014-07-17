
namespace :ofac do
  desc "Loads the current file from http://www.treas.gov/offices/enforcement/ofac/sdn/delimit/index.shtml."
  task :update_data => :environment do
    OfacSdnIndividualLoader.load_current_sdn_file
  end

end