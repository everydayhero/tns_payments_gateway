require "bundler/gem_tasks"

begin
  require "rspec/core"
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = "-t ~skip -f progress"
  end

  task default: :spec
rescue LoadError
end
