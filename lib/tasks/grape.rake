namespace :grape do
  desc "routes"
  task :routes do
    Api::Base.routes.map {|route| puts "#{route} \n" }
  end
end
