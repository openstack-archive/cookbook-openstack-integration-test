task default: ["test"]

task :test => [:lint, :style, :knife, :unit]

task :berks_prep do
  sh %{chef exec berks vendor}
end

task :lint do
  sh %{chef exec foodcritic --epic-fail any --tags ~FC003 --tags ~FC023 .}
end

task :knife => :berks_prep do
  sh %{chef exec knife cookbook test openstack-integration-test -o berks-cookbooks}
end

task :style do
  sh %{chef exec rubocop}
end

task :unit => :berks_prep do
  sh %{chef exec rspec --format documentation}
end

task :clean do
  rm_rf [
    'berks-cookbooks',
    'Berksfile.lock'
  ]
end
