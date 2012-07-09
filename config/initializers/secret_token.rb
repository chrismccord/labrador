# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

unless File.exists?("config/secret_token.yml")
  File.open("config/secret_token.yml", "w"){|f| f.puts SecureRandom.hex(rand(50) + 50).to_yaml }
end
Labrador::Application.config.secret_token = YAML.load(File.read("config/secret_token.yml"))
