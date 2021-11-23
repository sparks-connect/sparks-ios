desc "Send Slack notification about Beta release"
private_lane :slackify do
  @download_links ||= { "Not Working": "https://giphy.com/gifs/michael-jackson-popcornjackson-KupdfnqWwV7J6/fullscreen" }
  sh "curl -X POST -H 'Content-type: application/json' --data '#{slack_payload.to_json}' #{@secret.slack.url}"

  UI.success "---------------------------------------------------------------------------"
  UI.success "----------------- Slack Notification was sent successfully ----------------"
  UI.success "---------------------------------------------------------------------------"
rescue StandardError
  UI.error("Couldn't send slack message")
end

def slack_payload
  {
    "text": "New release",
    "channel": "sparks-release",
    "blocks": [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":tada: *App successfully released to #{@secret.env.distribution_channel}!* :eyes:",
        },
      },
      {
        "type": "divider",
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":shamrock:  *Envorinment:* #{@download_links.map { |k, v| "`#{k}`" }&.join(" ")}",
        },
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":link:  *Version:* `#{@tag}`",
        },
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":arrow_down:  *Download:*",
        },
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": @download_links.map { |k, v| "#{k}: #{v}" }.join("\n") || "failure",
        },
      },
      {
        "type": "divider",
      },
    ],
  }
end
