FactoryBot.define do
  sequence(:person_name) { |n| "Person ##{n}" }

  factory :person do
    name { generate :person_name }
  end
end
