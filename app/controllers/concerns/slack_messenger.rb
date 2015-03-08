module SlackMessenger extend ActiveSupport::Concern
  def handle_message(request)
    words = tokenize_message(request[:slack_text].downcase)

    # Don't do anything if "slam! is not in message"
    return if words.nil?

    process_command(request, words)

  end

  def tokenize_message(lower_case_message)
     if /^slam/ =~ lower_case_message
      return lower_case_message.split
     else
      return nil
     end
  end

  def process_command(request, words)
    team = Team.find_by(:slack_team_id => request[:slack_team_id])
    user = team.users.find_by(:slack_user_id => request[:slack_user_id])

    case words.fetch(1, nil)
    when "add"
      key = words.fetch(2, nil)
      value = words[3..-1].join(" ")
      if key && value
        if command = user.commands.find_by(:key => key)
          command.update(:value => value)
          update_message(request, "`#{key}` has been updated to `#{value}`") #change to update
        else
          if user.commands.create(:key => key, :value => value)
            update_message(request, "`#{key}` has been mapped to `#{value}`") #change to update
          else
            #ERROR
          end
        end
      end
    when "list"
      list_commands = user.commands
      message = ""
      list_commands.each do |command|
        message += "#{command[:key]}: #{command[:value]}\n"
      end
      update_message(request, message)
    when "save"
      key = words.fetch(2, nil)
      if key
        user = User.find_by(:slack_user_id => request[:slack_user_id])
        channel_api_uri = 'https://slack.com/api/channels.history'
        channel_api_uri = 'https://slack.com/api/groups.history' if request[:slack_channel_id][0].downcase == 'g'
        response = JSON.parse(RestClient.post(
          channel_api_uri,
          :token   => user.access_token,
          :channel => request[:slack_channel_id]
        ), :symbolize_names => true)

        response[:messages].each do |message|
          if message[:attachments].present? && message[:attachments][0][:image_url].present?
            value = message[:attachments][0][:image_url]
            if command = user.commands.find_by(:key => key)
              command.update(:value => value)
              update_message(request, "`#{key}` has been mapped to `#{value}`")
            else
              user.commands.create(:key => key, :value => value)
              update_message(request, "`#{key}` has been mapped to `#{value}`")
            end
            return
          elsif message[:user] != user.slack_user_id && message[:type] == 'message'
            if command = user.commands.find_by(:key => key)
              command.update(:value => message[:text])
              update_message(request, "`#{key}` has been mapped to `#{message[:text]}`")
            else
              user.commands.create(:key => key, :value => message[:text])
              update_message(request, "`#{key}` has been mapped to `#{message[:text]}`")
            end
            return
          end
        end
      end
    when "weather"
      response = JSON.parse(RestClient.get("https://george-vustrey-weather.p.mashape.com/api.php?location=#{words[2..-1].join("+")}",
          "X-Mashape-Key" => ENV['MASHAPE_API_KEY'],
          "Accept" => "application/json"),
          :symbolize_names => true)
      if response[0].has_key?(:code)
        update_message(request, "Could not find weather for `#{words[2..-1].join(" ")}`")
      else
        update_message(request, "In #{words[2..-1].join(" ")}, today is #{response[0][:condition]} with a high of #{response[0][:high_celsius]} degrees and a low of #{response[0][:low_celsius]} degrees.")
      end
    when "yoda"
      response = RestClient.get("https://yoda.p.mashape.com/yoda?sentence=#{words[2..-1].join("+")}",
        "X-Mashape-Key" => ENV['MASHAPE_API_KEY'],
        "Accept" => "application/json")
      update_message(request, response)
    when "trivia"
      question = get_trivia_question(request)
      update_message(request, question)
    when "trivia-ans"
      trivia_answer = TriviaAnswer.where(:channel_id => request[:slack_channel_id])
      if !trivia_answer.last.nil?
        update_message(request, "Answer: #{trivia_answer.last.answer}")
      end
    when "joke"
      response = JSON.parse(RestClient.get("http://api.icndb.com/jokes/random?escape=javascript"),
        :symbolize_names => true)
      update_message(request, response[:value][:joke])
    when "quote"
      response = JSON.parse(RestClient.get("https://andruxnet-random-famous-quotes.p.mashape.com/cat=movies",
        "X-Mashape-Key" => ENV['MASHAPE_API_KEY'],
        "Accept" => "application/json"),
        :symbolize_names => true)
      update_message(request, "#{response[:quote]} --#{response[:author]}")
    else
      if words.fetch(1, nil)
        key = words.fetch(1, nil)
        value = user.commands.find_by(:key => key).value
        if value
          update_message(request, value)
        else
          update_message(request, "No mapping found for `#{key}`")
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
      :as_user => true,
      :unfurl_media => true,
      :unfurl_links => true
    )
  end

  def update_message(request, message)
    user = User.find_by(:slack_user_id => request[:slack_user_id])
    RestClient.post(
      'https://slack.com/api/chat.update',
      :token   => user.access_token,
      :channel => request[:slack_channel_id],
      :ts      => request[:timestamp],
      :text    => message,
      :unfurl_media => true,
      :unfurl_links => true
    )
  end

  def get_trivia_question(request)
    response = JSON.parse(RestClient.get('http://jservice.io/api/random'),
      :symbolize_names => true)
    TriviaAnswer.create(:channel_id => request[:slack_channel_id], :answer => response.first[:answer])
    question = response.first[:question]
    category = response.first[:category][:title]
    message = "```Category: #{category}\nQuestion: #{question}```"
  end
end
