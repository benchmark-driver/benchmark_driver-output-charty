source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Specify your gem's dependencies in benchmark_driver-output-charty.gemspec
gemspec

# To experiment unicode_plot which is not released yet + fix #52
gem 'charty', github: 'k0kubun/charty', ref: 'bar-labels'

# https://github.com/red-data-tools/charty/issues/51
gem 'numo-narray'
