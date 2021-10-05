def build_iterations_and_assignment_weeks(eng, week, role)
  iteration = eng.iteration_on(week)
  FactoryBot.create(:assignment_week, iteration: iteration, week: iteration.week)
end

def build_iterations(eng, week)
  FactoryBot.create(:iteration, engagement: eng, week: week)
end

FactoryBot.define do
  factory :engagement do
    starts_on { 4.months.ago.to_date.beginning_of_week.to_formatted_s(:db) }
    ends_on { 5.month.from_now.to_date.beginning_of_week.to_formatted_s(:db) }
    sequence(:name) { |i| "Engagement #{i}" }
    # needs have moved into the assignment_weeks table

    trait :with_iterations do 
      after(:create) do |eng, _evaluator|
        week = eng.starts_on

        while week + 4.days <= eng.ends_on
          build_iterations(eng, week)
          week += 1.week
        end
      end
    end
  end


  factory :engagement_with_iterations, class: Engagement do
    after(:create) do |eng, _evaluator|
      week = eng.starts_on

      while week + 4.days <= eng.ends_on
        build_iterations_and_assignment_weeks(eng, week, role)
        week += 1.week
      end
    end
    starts_on { '2013-02-06' }
    ends_on { '2013-02-13' }
    sequence(:name) { |i| "Engagement #{i}" }
  end

  factory :current_engagement, parent: :engagement do
    starts_on { 4.months.ago.to_date.beginning_of_week.to_formatted_s(:db) }
    ends_on { 1.month.from_now.to_date.beginning_of_week.to_formatted_s(:db) }
  end

  factory :last_week_engagement, parent: :engagement do
    beginning_of_last_week = 1.week.ago.to_date.beginning_of_week
    end_of_next_week = 1.week.from_now.to_date
    
    starts_on { beginning_of_last_week.to_formatted_s(:db) }
    ends_on { end_of_next_week.to_formatted_s(:db) }
  end

  factory :old_engagement, parent: :engagement do
    starts_on { 4.months.ago.to_date.beginning_of_week.to_formatted_s(:db) }
    ends_on { 1.month.ago.to_date.to_formatted_s(:db) }
  end

  factory :future_engagement, parent: :engagement do
    starts_on { 1.year.from_now.to_date.beginning_of_week.to_formatted_s(:db) }
    ends_on { 15.months.from_now.to_date.to_formatted_s(:db) }
  end

  factory :engagement_with_no_rate, class: Engagement do
    starts_on { '2013-02-06' }
    ends_on { '2013-02-13' }
  end

  factory :prior_engagement, parent: :engagement do
    starts_on { 1.year.ago.to_date }
    ends_on { 1.month.ago.to_date }
  end

  factory :upcoming_engagement, parent: :engagement do
    starts_on { 1.month.from_now.to_date }
    ends_on { 1.year.from_now.to_date }
  end
end
