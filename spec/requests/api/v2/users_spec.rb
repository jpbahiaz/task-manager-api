require 'rails_helper'

RSpec.describe 'Users API', type: :request do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:auth_data) { user.create_new_auth_token }
    let(:user_response) { json_body } # or replace all 'user_response' for json_body
    let(:headers) do
        {
            'Accept': 'application/vnd.taskmanager.v2',
            'Content-Type': Mime[:json].to_s,
            'client': auth_data['client'],
            'access-token': auth_data['access-token'],
            'uid': auth_data['uid']
        }
    end

    # before { host! 'api.anydomain.test' }
    before { host! 'api.taskmanager.test' }

    describe 'GET /auth/validate_token' do

        context 'when request params are valid' do

            before do
                get '/auth/validate_token', params: {}, headers: headers
            end

            it 'should return the user id' do
                expect(user_response[:data][:id].to_i).to eq(user.id)
            end

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end

        end

        context 'when request params are invalid' do

            before do
                headers['access-token'] = 'invalid_token'
                get '/auth/validate_token', params: {}, headers: headers
            end

            it 'should return status code 401' do
                expect(response).to have_http_status(401)
            end

        end
    end

    describe 'POST /auth' do
        before do
            post '/auth', params: user_params.to_json, headers: headers
        end

        context 'when request params are valid' do
            let(:user_params) { FactoryGirl.attributes_for(:user) }

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'should return json data for the created user' do
                expect(user_response[:data][:email]).to eq(user_params[:email])
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

    describe 'PUT /auth' do
        before do
            put '/auth', params: user_params.to_json, headers: headers
        end

        context 'when request params are valid' do
            let(:user_params) { { email: 'new@email.com' } }

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'should return json data for the updated user' do
                expect(user_response[:data][:email]).to eq(user_params[:email])
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

    describe 'DELETE /auth' do
        before do
            delete '/auth', headers: headers
        end

        it 'should return status code 200' do
            expect(response).to have_http_status(200)
        end

        it 'should remove user from database' do
            expect(User.find_by(id: user.id)).to be_nil
        end
    end
end