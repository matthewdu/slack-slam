module SlackMessenger extend ActiveSupport::Concern
  def handle_message(request)
    words = tokenize_message(request[:text].downcase)

    # Don't do anything if "slam! is not in message"
    return if words.nil?

    process_command(request, words)

  end

  def tokenize_message(lower_case_message)
     if /^slam\!/ =~ lower_case_message
      return lower_case_message.split
     else
      return nil
     end
  end

  def process_command(request, words)
    case words[1]
    when "add"
      # angel code
    when "list"
      # angel code
    else
      post_message(request, "Sorry, try using \"slam! add [key] [value]\" or \"slam! list\"")
    end
  end

  def post_message(request, message)
    user = User.find_by(:slack_user_id => request[:user_id])
    RestClient.post(
      'https://slack.com/api/chat.postMessage',
      :token   => user.access_token,
      :channel => request[:channel_id],
      :text    => message,
      :as_user => true
    )
  end

  def update_message(request, message)
    user = User.find_by(:slack_user_id => request[:user_id])
    RestClient.post(
      'https://slack.com/api/chat.update',
      :token   => user.access_token,
      :channel => request[:channel_id],
      :ts      => request[:time_stamp],
      :text    => message
    )
  end
end
