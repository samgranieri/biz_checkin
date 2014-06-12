require 'spec_helper'
describe User do
  describe :initial_validations do
    let(:user) { FactoryGirl.build(:user) }
    it 'is valid with all attributes' do
      expect(user).to be_valid
    end
    it 'needs a name' do
      user.name = nil
      expect(user).to be_invalid
      expect(user).to have(1).error_on(:name)
    end
    it 'needs an email' do
      user.email = nil
      expect(user).to be_invalid
      expect(user).to have(1).error_on(:email)
    end
    it 'needs a matching password' do
      user.password_confirmation = nil
      expect(user).to be_invalid
      expect(user).to have(1).error_on(:password_confirmation)
    end
  end
end
