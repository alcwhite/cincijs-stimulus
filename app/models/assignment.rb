class Assignment < ApplicationRecord
  belongs_to :engagement
  belongs_to :person, optional: true, inverse_of: :assignments
  has_many :assignment_weeks, inverse_of: :assignment, dependent: :destroy
  has_many :time_entries, through: :assignment_weeks

  validate :person_cant_change_with_time_entries

  def <=>(b)
    [person_name] <=>
      [b.person_name]
  end

  def person_name
    person.try(:name) || "-"
  end

  private

  def person_cant_change_with_time_entries
    errors.add(:person_id, "Can't re-assign person once there are time entries") if changed_attributes["person_id"] && time_entries.any?
  end
end
