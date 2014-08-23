require 'opal'
require "opal-jquery"

desc "Build othe game"
task :build do
  Opal::Processor.source_map_enabled = false
  env = Opal::Environment.new
  env.append_path "lib"

  File.open("html/js/ld30.js", "w+") do |out|
    out << env["ld30"].to_s
  end
end