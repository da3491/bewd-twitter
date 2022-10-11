class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render 'tweet/index'
  end

  def index_by_user
    user = User.find_by(username: params[:username])

    if user
      @tweets = user.tweets.order(created_at: :desc)
      render 'tweet/index'
    else
      render json: { tweets: [] }
    end
  end

  def create
    token = cookies.permanent.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session
      user = session.user
      @tweet = user.tweets.new(tweet_params)

      if @tweet.save!
        render 'tweet/create'
      else
        render json: { failure: 'not saved' }
      end
    else
      render json: { failure: 'no session' }
    end
  end

  def destroy
    token = cookies.permanent.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    if session
      @tweet = Tweet.find_by(id: params[:id])

      if @tweet&.destroy
        render json: { success: true }
      else
        render json: { success: false }
      end
    else
      render json: {
        success: false
      }
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:user_id, :message)
  end
end
