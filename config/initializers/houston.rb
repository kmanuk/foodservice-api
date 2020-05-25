if Rails.env.production?
  APN = Houston::Client.production
  APN.certificate = File.read(Rails.root.join('config', 'apple_push_notification.pem'))
else
  APN = Houston::Client.production
  APN.certificate = File.read(Rails.root.join('config', 'apple_push_notification.dev.pem'))
end
