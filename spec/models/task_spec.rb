require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:task) { FactoryGirl.build(:task) }

  context 'When it is a new instance' do
    it { expect(task).not_to be_done }
  end

  it { should belong_to(:user) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :user_id }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:deadline) }
  it { should respond_to(:done) }
  it { should respond_to(:user_id) }
end
