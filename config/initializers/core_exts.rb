# automatically require all monkey patches (extension methods) in lib/core_ext/
Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each { |l| require l }
