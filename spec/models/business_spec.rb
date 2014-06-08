require 'spec_helper'

describe Business do
  describe :initial_creation do
    let(:business) {FactoryGirl.build(:business)}
    it "should be valid originally" do
      expect(business).to be_valid
    end
    %i[ name address city zip state website phone].each do |sym|
      it "should require a #{sym}" do
        business.send("#{sym}=", nil) 
        expect(business).to be_invalid
        expect(business).to have(1).error_on(sym)
      end
    end
  end
end
