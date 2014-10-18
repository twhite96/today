require 'date'
require 'pathname'

module OutlineListHelpers
  # sooo... this isn't tested.
  # Apparently testing isn't a thing for static sites -.-
  def outlines_by_month(resources)
    beginning_of_month = lambda do |date|
      days_since_first_of_month = date.day - 1
      date - days_since_first_of_month
    end
    outlines_by_week(resources)
      .group_by { |week_start,  *| beginning_of_month.call week_start }
      .sort_by  { |month_start, *| month_start }
  end

  def outlines_by_week(resources)
    beginning_of_week = lambda do |date|
      days_since_monday = date.wday - 1
      date - days_since_monday
    end

    # an outline's path takes the form "outlines/yyyy-mm-dd.html"
    outline_date = lambda do |outline_path|
      Date.parse(
        Pathname.new(outline_path)
                .basename
                .sub_ext('')
                .to_s
      )
    end

    resources.select   { |resource| resource.data[:layout] == 'outline' }
             .map      { |outline|  [outline_date.call(outline.path), outline] }
             .group_by { |date, outline| beginning_of_week.call (date) }
             .each     { |date, dates_to_outlines| dates_to_outlines.sort_by! &:first }
             .sort_by  { |date, dates_to_outlines| date }
  end

  def yyyy_mm_dd_for(date)
    date.strftime '%Y-%m-%d'
  end

  def yyyy_mm_for(date)
    date.strftime '%Y-%m'
  end

  def weekday_for(date)
    date.strftime('%A') # e.g. "Wednesday"
  end

  def human_date(date)
    date.strftime('%d %B')  # e.g. "15 October"
  end

  def monthname_for(date)
    date.strftime('%B')
  end
end