# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

unless File.exists?(Rails.root.join("config/secret_token.yml"))
  File.open(Rails.root.join("config/secret_token.yml"), "w") do |f| 
    f.puts SecureRandom.hex(rand(50) + 50).to_yaml
  end
end

Labrador::Application.config.secret_token = YAML.load(
  File.read(Rails.root.join("config/secret_token.yml"))
)
