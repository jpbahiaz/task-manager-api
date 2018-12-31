require 'rails_helper'

RSpec.describe 'Task API', type: :request do
    before { host! 'api.taskmanager.test' }

    let!(:user) { FactoryGirl.create(:user) }
    let(:headers) do
        {
            'Accept': 'application/vnd.taskmanager.v1',
            'Content-Type': Mime[:json].to_s,
            'Authorization': user.auth_token
        }
    end

    describe 'GET /tasks' do
      before do
        FactoryGirl.create_list(:task, 5, user_id: user.id)
        get '/tasks', headers: headers
      end

      it 'should return status code 200' do
          expect(response).to have_http_status(200)
      end

      it 'should return 5 tasks from database' do
          expect(json_body[:tasks].count).to eq(5) # json_body -> /support/request_spec_helper
      end
    end

end