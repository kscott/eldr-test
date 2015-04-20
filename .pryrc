load "config/application.rb"

puts "Connecting to local apiplayground"
org = Company::OrganizationApplication.find_by_subdomain("apiplayground")
DatabaseManagement::connect_to_church_database(org)
Company::OrganizationApplication.current = org
Church::Individual.current = Church::Individual.find(1)
