require 'httparty'

class Notifier
  PUSHOVER_URL = "https://api.pushover.net/1/messages.json"

  def send(title:, message:, url:)
    creds = Rails.application.credentials.pushover
    return unless creds.present?

    creds => { api_key: token, user_key: user }

    HTTParty.post(PUSHOVER_URL, body: {
      token:,
      user:,
      title:,
      message:,
      url:
    })
  end
end
