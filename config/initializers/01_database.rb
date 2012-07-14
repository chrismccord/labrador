# Copy distributed database configuration on first boot
unless File.exists?("config/database.yml")
  FileUtils.copy("config/database.distrib.yml", "config/database.yml")
end
