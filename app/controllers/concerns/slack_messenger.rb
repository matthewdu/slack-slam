module SlackMessenger extend ActiveSupport::Concern
  def handle_message(request)
    words = tokenize_message(request[:slack_text].downcase)

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
    team = Team.find_by(:slack_team_id => request[:slack_team_id])
    user = team.users.find_by(:slack_user_id => request[:slack_user_id])

    case words.index(1)
    when "add"
      key = words.index(2)
      value = words.index(3)
      if (key && value)
        if user.commands.create(:key => key, :value => value)
          byebug
          post_message(request, "#{key} has been mapped to #{value}") #change to update
        else
          #ERROR
        end
      end
    when "list"
      list_commands = user.commands
        message = ""
        list_commands.each do |command|
          message += "#{command[:key]}: #{command[:value]}\n"
        end
        post_message(request, message)
    else
      if words.index(1)
        key = words.index(1)
        value = user.commands.find_by(:key => key)
        if value
          post_message(request, value)
        else
          post_message(request, "No mapping found for #{key}")
        end
      else
        update_message(request, "No command entered.")
      end
    end
  end

  def post_message(request, message)
    user = User.find_by(:slack_user_id => request[:slack_user_id])
    RestClient.post(
      'https://slack.com/api/chat.postMessage',
      :token   => user.access_token,
      :channel => request[:slack_channel_id],
      :text    => message,
      :as_user => true
    )
  end

  def update_message(request, message)
    user = User.find_by(:slack_user_id => request[:slack_user_id])
    RestClient.post(
      'https://slack.com/api/chat.update',
      :token   => user.access_token,
      :channel => request[:slack_channel_id],
      :ts      => request[:timestamp],
      :text    => message
    )
  end
end
