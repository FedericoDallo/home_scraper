require 'httparty'

class Notifier
  PUSHOVER_URL = "https://api.pushover.net/1/messages.json"

  def send(title:, message:, url:, user_key: nil)
    send_notification(title:, message:, url:, user_key:)
  end

  def send_error(error)
    send_notification(title: "Error while scraping", message: error.message, url: nil)
  end

  private

  def send_notification(title:, message:, url:, user_key: nil)
    creds = Rails.application.credentials.pushover
    return unless creds.present?

    creds => { api_key: token, user_key: default_user }
    user = user_key.presence || default_user

    HTTParty.post(PUSHOVER_URL, body: {
      token:,
      user:,
      title:,
      message:,
      url:
    })
  end
end
