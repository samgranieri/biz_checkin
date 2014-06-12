require 'spec_helper'

describe Checkin do
  describe 'initial creation' do
    let(:checkin) { FactoryGirl.create(:checkin) }
    it 'should be valid at the start' do
      expect(checkin).to be_valid
    end
  end
  describe 'validations' do
    let(:business) { FactoryGirl.create(:business) }
    let(:user) { FactoryGirl.create(:user) }
    it 'should have a business' do
      checkin = FactoryGirl.build(:checkin, business: nil, user: user)
      expect(checkin).to be_invalid
      expect(checkin).to have(1).error_on(:business)
    end
    it 'should have a user' do
      checkin = FactoryGirl.build(:checkin, business: business, user: nil)
      expect(checkin).to be_invalid
      expect(checkin).to have(1).error_on(:user)
    end
  end
  describe 'given a business with a 30 minute waiting period' do
    let(:business) { FactoryGirl.create(:business) }
    let(:user) { FactoryGirl.create(:user) }
    it 'should not allow a user to check in at 15 minutes' do
      FactoryGirl.create(:checkin, business: business, user: user)
      Timecop.freeze(15.minutes.from_now) do
        later_checkin = FactoryGirl.build(:checkin, business: business, user: user)
        expect(later_checkin).to be_invalid
      end
    end
    it 'show allow a user to check into a business after 30 minutes' do
      FactoryGirl.create(:checkin, business: business, user: user)
      Timecop.freeze(Time.now + 35.minutes) do
        later_checkin = FactoryGirl.build(:checkin, business: business, user: user)
        expect(later_checkin).to be_valid
      end
    end
  end

end
