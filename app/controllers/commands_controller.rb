class CommandsController < ApplicationController
  include SlackMessenger
  def message
    request = {
      :slack_team_id => message_params[:team_id],
      :slack_channel_id => message_params[:channel_id],
      :slack_user_id => message_params[:user_id],
      :slack_text => message_params[:text].downcase,
      :timestamp => message_params[:timestamp]
    }
   handle_message(request)
   render :nothing => true
  end

  private
  def message_params
    params.permit(:token, :team_id, :team_domain, :channel_id, :channel_name, :timestamp, :user_id, :user_name, :text, :trigger_word)
  end

  def post_to_slack(opts = {})
    RestClient.post("https://slack.com/api/chat.postMessage")
  end

end
