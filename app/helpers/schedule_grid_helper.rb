module ScheduleGridHelper
  attr_accessor :total_weeks

  def start_block(starts_on)
    return 1 if starts_on <= start_date
    return total_weeks if starts_on >= end_date
    ((starts_on - start_date) / 7).ceil + 1
  end

  def end_block(ends_on)
    ends_on ||= end_date
    return total_weeks if ends_on >= end_date
    ((ends_on - start_date) / 7.0).ceil + 1
  end

  def this_week
    @this_week ||= Date.today.beginning_of_week
  end

  def this_week_class(week)
    "timeline__grid-this-week" if week == this_week
  end

  def start_date
    @start_date ||= this_week - (7 * 4)
  end

  def end_date
    @end_date ||= start_date + (total_weeks * 7)
  end

  def total_weeks
    @total_weeks ||= 52
  end

  def grid_dates
    return @grid_dates if defined? @grid_dates
    @grid_dates = []
    1.upto(total_weeks) do |week|
      @grid_dates << (start_date + (week - 1).week)
    end
    @grid_dates
  end
end
