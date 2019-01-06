require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
    before { host! 'api.taskmaneger.test' }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:auth_data) { user.create_new_auth_token }
    let(:headers) do
        {
            'Accept': 'application/vnd.taskmanager.v2',
            'Content-Type': Mime[:json].to_s,
            'access-token': auth_data['access-token'],
            'uid': auth_data['uid'],
            'client': auth_data['client']
        }
    end

    describe 'POST /auth/sign_in' do
        before do
            post '/auth/sign_in', params: credentials.to_json, headers: headers
        end

        context 'when credentials are correct' do
            let(:credentials) { { email: user.email, password: '123456' } } 

            it 'should return status code 200' do
                expect(response).to have_http_status(200)
            end

            it 'should return headers with user authentication data' do
                expect(response.headers).to have_key('access-token')
                expect(response.headers).to have_key('uid')
                expect(response.headers).to have_key('client')
            end
        end

        context 'when credentials are incorrect' do
            let(:credentials) { { email: user.email, password: 'invalid_password' } } 

            it 'should return status code 401' do
                expect(response).to have_http_status(401)
            end

            it 'should return json data with the errors' do
                expect(json_body).to have_key(:errors) # json_body vem do arquivo /spec/support/request_spec_helper
            end
        end
    end

    describe 'DELETE /auth/sign_out' do
        let(:auth_token) { user.auth_token }

        before do
        delete '/auth/sign_out', headers: headers
        end

        it 'should return status code 200' do
            expect(response).to have_http_status(200)
        end

        it 'changes the user auth token' do
            user.reload
            # expect(user.valid_token?(auth_data['access-token'], auth_data['client'])).to be false
            expect(user).not_to be_valid_token(auth_data['access-token'], auth_data['client'])
        end
    end
end