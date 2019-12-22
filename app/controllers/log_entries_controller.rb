class LogEntriesController < ApplicationController

  before_action :require_logged_in

  def new
    parse_date
    @entry = LogEntry.new(user: current_user, day: @date)
  end

  def create
    parse_date
    do_create
    redirect_to month_path(year: @date.year, month: @date.strftime('%B'))
  end

  def edit
    parse_date
    @entry = LogEntry.where(user: current_user, day: @date).first
    render action: :new
  end

  def update
    parse_date
    @entry = LogEntry.where(user: current_user, day: @date).first
    if @entry
      @entry.update!(details: params.require(:details))
    else
      do_create
    end
    redirect_to month_path(year: @date.year, month: @date.strftime('%B'))
  end

  def destroy
    parse_date
    @entry = LogEntry.where(user: current_user, day: @date).first
    @entry.destroy! if @entry
    redirect_to month_path(year: @date.year, month: @date.strftime('%B'))
  end

  def month
    @year = params.require(:year)
    @month = params.require(:month)

    now = Date.today
    date = Date.strptime("#{@month} 1, #{@year}", '%B %d, %Y')
    month_num = date.month

    date_to_entry = {}
    entries = LogEntry.
      where(user: current_user).
      where('day >= ?', date).
      where('day < ?', date + 1.month)
    entries.each { |entry| date_to_entry[entry.day] = entry.details }

    @table_data = [Array.new(7)]

    while date.month == month_num
      @table_data << Array.new(7) if date.wday == 0 && date.day > 1

      entry = date_to_entry[date]

      if entry.nil?
        td_class = nil
      elsif date > now
        td_class = 'future'
      elsif date < now
        td_class = 'past'
      else
        td_class = 'present'
      end
      @table_data.last[date.wday] = [
        date,
        entry,
        td_class,
      ]
      date = date.next
    end
  end

  private

  def parse_date
    @date = Date.new(
      params.require(:year).to_i,
      params.require(:month).to_i,
      params.require(:day).to_i,
    )
  end

  def do_create
    LogEntry.create!(user: current_user, day: @date, details: params.require(:details))
  end
end
