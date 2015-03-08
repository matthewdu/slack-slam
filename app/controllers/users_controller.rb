class UsersController < ApplicationController
  def home
  end

  def new
    client = OAuth2::Client.new(ENV['SLACK_CLIENT_ID'], ENV['SLACK_CLIENT_SECRET'], :site => 'https://slack.com')
    redirect_to client.auth_code.authorize_url(:redirect_url => callback_users_url, :scope => 'identify,read,post,client')
  end

  def callback
    response = JSON.parse(RestClient.post('https://slack.com/api/oauth.access', {
      :client_id     => ENV['SLACK_CLIENT_ID'],
      :client_secret => ENV['SLACK_CLIENT_SECRET'],
      :code          => params[:code],
      :redirect_uri  => callback_users_url
    }), :symbolize_names => true)

    slack_user = JSON.parse(RestClient.post('https://slack.com/api/auth.test', :token => response[:access_token]),
      :symbolize_names => true)

    slack_team_id = slack_user[:team_id]

    if team = Team.find_by(:slack_team_id => slack_team_id)
      if @user = team.users.find_by(:slack_user_id => slack_user[:user_id])
        @user.update(:access_token => response[:access_token])
      else
        team.users.create(
          :slack_name    => slack_user[:user],
          :slack_user_id => slack_user[:user_id],
          :access_token  => response[:access_token]
        )
      end
    else
      new_team = Team.new(
        :slack_team_id   => slack_user[:team_id],
        :slack_team_name => slack_user[:team]
      )
      if new_team.save
        @user = new_team.users.create(
          :slack_name    => slack_user[:user],
          :slack_user_id => slack_user[:user_id],
          :access_token  => response[:access_token]
        )
      else
        # ERRRORR
      end
    end
    redirect_to(@user)
  end

  def show
    @user = User.find params[:id]
    @commands = [] || @user.commands
  end
end
