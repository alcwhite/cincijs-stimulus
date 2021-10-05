# frozen_string_literal: true

class TimeEntry < ApplicationRecord
  belongs_to :time_sheet
  belongs_to :assignment_week, optional: true, inverse_of: :time_entries

  validates :date, :time_sheet_id, :assignment_week_id, presence: true
  validates :date, uniqueness: { scope: %i[time_sheet_id assignment_week_id] }
end
