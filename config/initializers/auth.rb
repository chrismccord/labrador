# =============================================================================
# config/initializers/auth.rb
# =============================================================================
#
# Labrador requires HTTP Basic Authentication.
# Uncomment the following lines and set sensible credentials.
#
# NOTE: HTTP Basic Auth sends credentials in the clear without encryption -
# If you are accessing your Labrador process remotely, 
# be sure it is on a network you trust.


ENV['LABRADOR_USER'] = 'your_username'
ENV['LABRADOR_PASS'] = 'your_password'