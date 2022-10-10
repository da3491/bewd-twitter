class TweetsController < ApplicationController
    def index
        @tweets = Tweet.all
        render 'tweet/index'
    end

    def index_by_user
        token = cookies.signed[:twitter_session_token]
        session = Session.find_by(token: token)

        if session
            @tweet = session.user.tweets
            render 'tweet/index'
        else
            render json: {tweets: []}
        end
    end
    
    def create
        token = cookies.signed[:twitter_session_token]
        session = Session.find_by(token: token)

        if session
            user = session.user
            @tweet = Tweet.new(tweet_params)

            if @tweet.save
                render 'tweet/create'
            else
                render json: {failure: 'not saved'}
            end
        else
            render json: {failure: 'no session'}
        end 
    end

    def destroy
        token = cookies.signed[:twitter_session_token]
        session = Session.find_by(token: token)

        if session

            @tweet = Tweet.find_by(id: params[:id])

            if @tweet and @tweet.destroy
                # true
                render json: {success: true}
            else
                # false
                render json: {success: false}
            end
        else
            render json: {
                failure: 'no session'
            }
        end
    end

    private

    def tweet_params
        params.require(:tweet).permit(:user_id, :message)
    end
end
