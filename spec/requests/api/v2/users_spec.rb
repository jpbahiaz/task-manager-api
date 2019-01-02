require 'rails_helper'

RSpec.describe 'Users API', type: :request do
    let!(:user) { FactoryGirl.create(:user) }
    let(:user_id) { user.id }
    let(:user_response) { json_body } # or replace all 'user_response' for json_body
    let(:headers) do
        {
            'Accept': 'application/vnd.taskmanager.v2',
            'Content-Type': Mime[:json].to_s,
            'Authorization': user.auth_token
        }
    end

    # before { host! 'api.anydomain.test' }
    before { host! 'api.taskmanager.test' }

    describe 'GET /users/:id' do
        before do
            get "/users/#{user_id}", params: {}, headers: headers
        end

        context 'when user exists' do
            it 'should return the user' do
                expect(user_response[:data][:id].to_i).to eq(user_id)
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
            post '/users', params: { user: user_params }.to_json, headers: headers
        end

        context 'when request params are valid' do
            let(:user_params) { FactoryGirl.attributes_for(:user) }

            it 'should return status code 201' do
                expect(response).to have_http_status(201)
            end

            it 'should return json data for the created user' do
                expect(user_response[:data][:attributes][:email]).to eq(user_params[:email])
            end
        end

        context 'when request params are invalid' do
            let(:user_params) { FactoryGirl.attributes_for(:user, email: 'invalid_email@') }

            it 'should return status code 422' do
                expect(response).to have_http_status(422)
            end

            it 'should return json data for the errors' do
                expect(user_response).to have_key(:errors)
            end
        end
    end

    describe 'PUT /users/:id' do
        before do
            put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
        end

        context 'when request params are valid' do
            let(:user_params) { { email: 'new@email.com' } }

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'should return json data for the updated user' do
                expect(user_response[:data][:attributes][:email]).to eq(user_params[:email])
            end
        end

        context 'when request params are invalid' do
            let(:user_params) { { email: 'invalid_email@' } }

            it 'should return status code 422' do
                expect(response).to have_http_status(422)
            end

            it 'should return json data for the errors' do
                expect(user_response).to have_key(:errors)
            end
        end
    end

    describe 'DELETE /users/:id' do
        before do
            delete "/users/#{user_id}", headers: headers
        end

        it 'should return status code 204' do
            expect(response).to have_http_status(204)
        end

        it 'should remove user from database' do
            expect(User.find_by(id: user_id)).to be_nil
        end
    end
end