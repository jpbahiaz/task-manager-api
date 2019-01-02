require 'rails_helper'

RSpec.describe 'Task API', type: :request do
    before { host! 'api.taskmanager.test' }

    let!(:user) { FactoryGirl.create(:user) }
    let(:headers) do
        {
            'Accept': 'application/vnd.taskmanager.v2',
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
          expect(json_body[:data].count).to eq(5) # json_body -> /support/request_spec_helper
      end
    end

    describe 'GET /tasks/:id' do
      let(:task) { FactoryGirl.create(:task, user_id: user.id) }

      before { get "/tasks/#{task.id}", headers: headers }

      it 'should return status code 200' do
          expect(response).to have_http_status(200)
      end

      it 'should return json data for task' do
          expect(json_body[:data][:attributes][:title]).to eq(task.title)
      end
    end


    describe 'POST /tasks' do
      before do
        post '/tasks', params: { task: task_params }.to_json, headers: headers
      end

      context 'when params are valid' do
        let(:task_params) { FactoryGirl.attributes_for(:task) }

        it 'should return status code 201' do
            expect(response).to have_http_status(201)
        end

        it 'should save the task in the database' do
            expect(Task.find_by(title: task_params[:title])).not_to be_nil
        end

        it 'should return json data for the created task' do
            expect(json_body[:data][:attributes][:title]).to eq(task_params[:title])
        end

        it 'should assign the created task to current user' do
            expect(json_body[:data][:attributes][:'user-id']).to eq(user.id)            
        end
      end

      context 'when params are invalid' do
        let(:task_params) { FactoryGirl.attributes_for(:task, title: ' ')}

        it 'should return status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'should not save the task in the database' do
            expect(Task.find_by(title: task_params[:title])).to be_nil
        end

        it 'should return json data for errors' do
            expect(json_body[:errors]).to have_key(:title)
        end
      end
    end

    describe 'PUT /tasks/:id' do
      let!(:task) { FactoryGirl.create(:task, user_id: user.id) }
      before do
        put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers
      end

      context 'when params are valid' do
        let(:task_params) { { title: 'New task title' } }

        it 'should return status code 200' do
            expect(response).to have_http_status(200)
        end

        it 'should return json data for the updated task' do
            expect(json_body[:data][:attributes][:title]).to eq(task_params[:title])
        end

        it 'should update the task in the database' do
            expect(Task.find_by(title: task_params[:title])).not_to be_nil
        end

      end

      context 'when params are invalid' do
        let(:task_params) { { title: ' ' } }

        it 'should return status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'should return json data for title errors' do
            expect(json_body[:errors]).to have_key(:title)
        end

        it 'should not update the task in the database' do
            expect(Task.find_by(title: task_params[:title])).to be_nil
        end
      end
    end

    describe 'DELETE /tasks/:id' do
      let(:task) { FactoryGirl.create(:task, user_id: user.id) }

      before do
        delete "/tasks/#{task.id}", headers: headers
      end

      it 'should return status code 204' do
          expect(response).to have_http_status(204)
      end
    
      it 'should remove the task from database' do
          expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
end