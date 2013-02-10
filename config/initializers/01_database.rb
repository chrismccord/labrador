# Copy distributed database configuration on first boot
unless File.exists?(Rails.root.join("config/database.yml"))
  FileUtils.copy Rails.root.join("config/database.distrib.yml"), 
                 Rails.root.join("config/database.yml")
end
