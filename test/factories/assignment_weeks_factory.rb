FactoryBot.define do
  factory :assignment_week do
    assignment
    iteration
    week { Date.today.beginning_of_week }
    max_billable_hours { 40 }
  end
end
