FactoryGirl.define do
  factory :business do
    name "7/11"
    address "2264 N Clark St"
    city "Chicago"
    state "IL"
    zip "60614"
    website "http://www.711.com"
    phone "(773) 528-0190"
    waiting_period 30
  end
end
