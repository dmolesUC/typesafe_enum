require 'ci/reporter/rake/rspec'

# Configure CI::Reporter report generation
ENV['GENERATE_REPORTS'] ||= 'true'
ENV['CI_REPORTS'] = 'artifacts/rspec'

desc 'Run all specs in spec directory, with coverage'
task coverage: ['ci:setup:rspec'] do
  ENV['COVERAGE'] ||= 'true'
  Rake::Task[:spec].invoke
end
