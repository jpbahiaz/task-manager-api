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

    def update
        @user = User.find(params[:id])

        if @user.update(user_params)
            render json: @user, status: :ok
        else
            render json: { errors: @user.errors }, status: :unprocessable_entity
        end
    end

    def destroy
        user = User.find(params[:id])
        user.destroy
        head :no_content # 204
    end

    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
