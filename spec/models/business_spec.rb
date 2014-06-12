require 'spec_helper'

describe Business do
  describe :initial_creation do
    let(:business) { FactoryGirl.build(:business) }
    it 'should be valid originally' do
      expect(business).to be_valid
    end
    %i(name address city zip state website phone waiting_period).each do |sym|
      it "should require a #{sym}" do
        business.send("#{sym}=", nil)
        expect(business).to be_invalid
        expect(business).to have(1).error_on(sym)
      end
    end
    it 'should have an integer for a waiting period' do
      business.waiting_period = 2.5
      expect(business).to be_invalid
    end
    it 'should not allow a negative or zero number for a waiting period' do
      business.waiting_period = 0
      expect(business).to be_invalid
      business.waiting_period = -1
      expect(business).to be_invalid
    end

  end
end
