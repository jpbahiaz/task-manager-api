class Api::V1::UsersController < ApplicationController
    respond_to :json

    def show
        begin
            @user = User.find(params[:id])
            respond_with @user    
        rescue => exception
            head 404
        end
    end

    def create
        @user = User.new(user_params)
        if @user.save
            render json: @user, status: :created # 201
        else
            render json: { errors: @user.errors }, status: :unprocessable_entity # 422
        end
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
