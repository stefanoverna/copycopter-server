task :setup => ['db:drop:all', 'db:create:all', 'db:migrate', :environment] do
  require 'factory_girl_rails'

  project = FactoryGirl.create(:project)
  blurb = FactoryGirl.create(:blurb, :project => project)
  FactoryGirl.create(:localization, :blurb => blurb)
end

