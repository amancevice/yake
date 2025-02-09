# frozen_string_literal: true

require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new :spec

namespace :gem do
  require 'bundler/gem_tasks'

  @gem = "pkg/yake-#{Yake::VERSION}.gem"

  desc "Push #{@gem} to rubygems.org"
  task :push => %i[spec build git:check] do
    sh %{gem push #{@gem}}
  end
end

namespace :git do
  desc 'Check git workspace'
  task :check do
    sh %{git diff HEAD --quiet} do |ok|
      abort "\e[31mRefusing to continue - git workspace is dirty\e[0m" unless ok
    end
  end
end
