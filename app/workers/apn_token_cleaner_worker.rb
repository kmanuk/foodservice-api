class ApnTokenCleanerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'apn-token-cleaner', retry: false

  def perform
    devices = APN.devices

    if devices.present?
      logger.info '-------- UNREGISTERED TOKENS HAVE BEEN FOUND --------'
      logger.info '-------- CLEARING --------'

      count = User.where(token: devices).update_all(token: nil)

      logger.info "-------- '#{devices.join(' | ')}' --------"
      logger.info "-------- #{count} USERS HAVE BEEN UPDATED --------"
      logger.info '-------- SUCCESS --------'
    end
  end
end

Sidekiq::Cron::Job.create(name: 'APN token cleaner', cron: '0 0 * * *', class: 'ApnTokenCleanerWorker') unless Rails.env.test?
