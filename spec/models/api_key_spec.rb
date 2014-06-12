require 'spec_helper'
describe 'ApiKey' do
  context 'initial validations' do
    let(:user) { FactoryGirl.create(:user) }
    let(:api_key) { FactoryGirl.create(:api_key, user: user) }
    it 'should be valid initially' do
      expect(api_key).to be_valid
    end
  end
  context 'Manipulating Time' do
    it 'should expire in the future' do
      Timecop.freeze(Time.now) do
        user = FactoryGirl.create(:user)
        api_key = FactoryGirl.create(:api_key, user: user)
        expect(api_key.expires_at).to_not be_nil
        expect(api_key.expires_at).to eq(DateTime.now + 30.days)
        expect(api_key.expired?).to eq(false)
      end
    end
  end
end
