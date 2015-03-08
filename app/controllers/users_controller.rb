class UsersController < ApplicationController
  def new
    client = OAuth2::Client.new(ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], :site => 'https://slack.com')
    redirect_to client.auth_code.authorize_url(:redirect_url => callback_users_url)

  end

  def callback
    response = RestClient.post 'https://slack.com/api/oauth.access', {
      :client_id     => ENV['SLACK_CLIENT_ID'],
      :client_secret => ENV['SLACK_CLIENT_SECRET'],
      :code          => params[:code],
      :redirect_uri  => callback_users_url
    }

    user = RestClient.post 'https://slack.com/api/auth.test', :token => 'xoxp-3886052245-3888026510-3965432491-410245'
  end

end
