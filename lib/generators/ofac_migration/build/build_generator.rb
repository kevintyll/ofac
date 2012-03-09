require 'rails'

module OfacMigration
	module Generators
		class BuildGenerator < ::Rails::Generators::Base
			include Rails::Generators::Migration
			source_root File.expand_path('../templates', __FILE__)
			desc "Adds the migration for the ofac_sdns table."
			
			# Get the next migration number
			#
			def self.next_migration_number(path)
				unless @prev_migration_nr
					@prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
				else
					@prev_migration_nr += 1
				end
				@prev_migration_nr.to_s
			end
			
			# copy the migration file over
			#
			def copy_migrations
				migration_template "create_ofac_sdns.rb", "db/migrate/create_ofac_sdns.rb"
			end
			
		end
	end
end