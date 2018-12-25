require 'rails_helper'

RSpec.describe 'Users API', type: :request do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_id) { user.id }

    # before { host! 'api.anydomain.test' }
    before { host! 'api.taskmanager.test' }

    describe 'GET /users/:id' do
        before do
            headers = { 'Accept': 'application/vnd.taskmanager.v1' }
            get "/users/#{user_id}", params: {}, headers: headers
        end

        context 'when user exists' do
            it 'should return the user' do
                user_response = JSON.parse(response.body)
                expect(user_response['id']).to eq(user_id)
            end

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end
        end

        context 'when user does not exist' do
            let(:user_id) { 1000 }

            it 'should return status code 404' do
                expect(response).to have_http_status(404)
            end
        end
    end

    describe 'POST /users' do
        before do
            headers = { 'Accept': 'application/vnd.taskmanager.v1' }
            post '/users', params: { user: user_params }, headers: headers
        end

        context 'when request params are valid' do
            let(:user_params) { FactoryGirl.attributes_for(:user) }

            it 'should return status code 201' do
                expect(response).to have_http_status(201)
            end

            it 'should return json data for the created user' do
                user_response = JSON.parse(response.body)
                expect(user_response['email']).to eq(user_params[:email])
            end
        end

        context 'when request params are invalid' do
            let(:user_params) { FactoryGirl.attributes_for(:user, email: 'invalid_email@') }

            it 'should return status code 422' do
                expect(response).to have_http_status(422)
            end

            it 'should return json data for the errors' do
                user_response = JSON.parse(response.body)
                expect(user_response).to have_key('errors')
            end
        end
    end
end