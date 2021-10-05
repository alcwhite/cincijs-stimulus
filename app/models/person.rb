# frozen_string_literal: true

require 'digest/md5'

class Person < ApplicationRecord
  has_many :assignments, dependent: :destroy, inverse_of: :person
  has_many :assignment_weeks, through: :assignments
  has_many :time_sheets, dependent: :destroy
  has_many :time_entries, through: :time_sheets

  validates :name, presence: true

  def self.preload_tree
    preload(assignment_weeks: :time_entries)
  end

  def self.by_name
    order(:name)
  end

  def assigned_for_week?(date)
    person_week(date).assigned?
  end

  def billable?(date)
    person_week(date).billable?
  end

  def on_bench?(date)
    person_week(date).on_bench?
  end

  def total_pto_hours(week)
    time_off_week(week, week+4).pto_hours
  end

  def pto_hours(start_date, end_date = nil)
    end_date ||= start_date + 4.days
    time_off_week(start_date, end_date).pto_hours_array
  end

  def employee
    ENV.fetch('PTO_SOURCE', 'rippling') == 'bamboo' ? bamboo_employee : rippling_employee
  end

  private

  def time_off_week(start_date, end_date)
    @time_off_week ||= {}
    employee = start_date.to_s > "2019-01-01" ? rippling_employee : bamboo_employee
    @time_off_week["#{start_date} #{end_date}"] ||= TimeOffWeek.new(employee: employee, start_date: start_date, end_date: end_date)
  end
end
