FactoryBot.define do
  factory :iteration do
    engagement
    week { Date.today }
  end
end
