require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user) { FactoryGirl.build(:user) }

  it { should have_many(:tasks).dependent(:destroy) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_confirmation_of(:password) }
  it { is_expected.to allow_value('jp.bahia.zica@gmail.com').for(:email)}
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'should return email, created_at and Token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')

      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

  describe '#generate_authentication_token!' do
    it 'generates a unique auth token' do
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')
      user.generate_authentication_token!
      
      expect(user.auth_token).to eq('abc123xyzTOKEN')
    end

    it 'generates another auth token when the current auth token has already been taken' do
      # Cada chamada do devise irá retornar as strings na ordem indicada
      allow(Devise).to receive(:friendly_token).and_return('abc123tokenxyz', 'abc123tokenxyz', 'abcXYZ123456789') 
      existing_user = FactoryGirl.create(:user)
      user.generate_authentication_token!

      expect(user.auth_token).not_to eq(existing_user.auth_token)
    end
  end

end
