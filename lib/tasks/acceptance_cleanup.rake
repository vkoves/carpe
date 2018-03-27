desc "Cleans up after CodeceptJS runs (deletes seed data related to CodeceptJS)   "

# Add environment dependancy to allow for DB access and modules
task :acceptance_cleanup => :environment do
    puts "--- Cleaning Up CodeceptJS Data ---"
    User.where(name: "CodeceptJS Tester").first.destroy
    puts "--- CodeceptJS Data Removed ---"
end
