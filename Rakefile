# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :gem do
  require "bundler/gem_tasks"

  @gem = "pkg/yake-#{Yake::VERSION}.gem"

  desc "Push #{ @gem } to rubygems.org"
  task :push => %i[spec build] do
    sh %{gem push  #{ @gem }}
  end
end
