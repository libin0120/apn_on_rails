require 'socket'
require 'openssl'
require 'configatron'
#require 'railties'

rails_root = File.join(FileUtils.pwd)
if defined?(Rails.root) && Rails.root
  rails_root = Rails.root
end

rails_env = 'development'
if defined?(Rails.env)
  rails_env = Rails.env
end

configatron.apn.set_default(:passphrase, '')
configatron.apn.set_default(:port, 2195)

configatron.apn.feedback.set_default(:passphrase, configatron.apn.passphrase)
configatron.apn.feedback.set_default(:port, 2196)

if rails_env == 'production'
  configatron.apn.set_default(:host, 'gateway.push.apple.com')
  configatron.apn.set_default(:cert, File.join(rails_root, 'config', 'apple_push_notification_production.pem'))
  
  configatron.apn.feedback.set_default(:host, 'feedback.push.apple.com')
  configatron.apn.feedback.set_default(:cert, configatron.apn.cert)
else
  configatron.apn.set_default(:host, 'gateway.sandbox.push.apple.com')
  configatron.apn.set_default(:cert, File.join(rails_root, 'config', 'apple_push_notification_development.pem'))
  
  configatron.apn.feedback.set_default(:host, 'feedback.sandbox.push.apple.com')
  configatron.apn.feedback.set_default(:cert, configatron.apn.cert)
end

module APN # :nodoc:
  
  module Errors # :nodoc:
    
    # Raised when a notification message to Apple is longer than 256 bytes.
    class ExceededMessageSizeError < StandardError
      
      def initialize(message) # :nodoc:
        super("The maximum size allowed for a notification payload is 256 bytes: '#{message}'")
      end
      
    end
    
  end # Errors
  
end # APN

Dir.glob(File.join(File.dirname(__FILE__), 'app', 'models', 'apn', '*.rb')).sort.each do |f|
  require f
end

%w{ models controllers helpers }.each do |dir| 
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path 
  # puts "Adding #{path}"
  begin 
  ActiveSupport::Dependencies.autoload_paths << path 
  ActiveSupport::Dependencies.autoload_once_paths.delete(path) 
  rescue NameError
    Dependencies.load_paths << path 
    Dependencies.load_once_paths.delete(path) 
  end
end
