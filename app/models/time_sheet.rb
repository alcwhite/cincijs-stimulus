# frozen_string_literal: true

class TimeSheet < ApplicationRecord
  belongs_to :person
  has_many :time_entries, dependent: :delete_all

  validates :start_date, :person_id, presence: true
  validates :start_date, uniqueness: { scope: :person_id }

  # returns a hash mapping assignment_week ids to an array of time worked
  def self.weekly_time_sheet(person, week_start)
    week_end = week_start + 4.days
    time_sheet = {}
    time_sheet.merge!(assignment_weeks(person.assignment_weeks.where(week: week_start)))
  end

  private

  # returns hash mapping an assignment_week id for a person to their time worked
  def self.assignment_weeks(weekly_assignment_weeks)
    engagements = {}
    weekly_assignment_weeks.each_with_index do |assignment_week, index|
      days = index == 0 ? [8.0, 8.0, 8.0, 8.0, 8.0] : [0.0, 0.0, 0.0, 0.0, 0.0]
      engagements.merge!(assignment_week.id => days)
    end
    engagements
  end

  # deducts from the first assigned engagement the total amount of pto and holiday time
  def self.adjust_for_time_off(time_sheet)
    return time_sheet if time_sheet.length <= 2 # only shows pto and holidays

    eng, eng_times = time_sheet.first
    off_time = [time_sheet['PTO'], time_sheet['Holidays']].transpose.map { |elem| elem.reduce(:+) }
    time_sheet[eng] = [eng_times, off_time].transpose.map { |elem| elem.reduce(:-) }
    time_sheet
  end
end
