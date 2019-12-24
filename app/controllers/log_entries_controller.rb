class LogEntriesController < ApplicationController

  before_action :require_logged_in
  before_action :set_teams, only: :team_week
  before_action :check_team_membership, only: :team_week
  before_action :check_is_teammate_or_self, only: :month
  before_action :parse_entry_date, only: [:new, :create, :edit, :update, :destroy]

  def new
    @entry = LogEntry.new(user: current_user, day: @date)
  end

  def create
    do_create_or_update
    redirect_to_month_or_week
  end

  def edit
    @entry = LogEntry.where(user: current_user, day: @date).first
    render action: :new
  end

  def update
    entry = LogEntry.where(user: current_user, day: @date).first
    do_create_or_update(entry)
    redirect_to_month_or_week
  end

  def destroy
    @entry = LogEntry.where(user: current_user, day: @date).first
    @entry.destroy! if @entry
    redirect_to_month_or_week
  end

  def jump_to_month
    year = params.require(:date).require(:year).to_i
    month_num = params.require(:date).require(:month).to_i
    user_id = params.require(:user_id)
    redirect_to month_path(user_id: user_id, year: year, month: Date::MONTHNAMES[month_num])
  end

  def month
    @user = User.find(params.require(:user_id))
    @year = params.require(:year)
    @month = params.require(:month)
    date = Date.strptime("#{@month} 1, #{@year}", '%B %d, %Y')

    @return_params = {} # only needed for team_week view
    @now = Date.today
    @previous_month = date - 1.month
    @next_month = date + 1.month

    @first_year = (first_year_for_user(current_user) || @now.year) - 1
    @last_year = (last_year_for_user(current_user) || @now.year) + 1

    month_num = date.month

    date_to_entry = {}
    entries = LogEntry.
      where(user: @user).
      where('day >= ?', date).
      where('day < ?', date + 1.month)
    entries.each { |entry| date_to_entry[entry.day] = entry.details }

    @table_data = [Array.new(7)]

    while date.month == month_num
      @table_data << Array.new(7) if date.wday == 0 && date.day > 1

      entry = date_to_entry[date]

      @table_data.last[date.wday] = [
        date,
        entry,
        get_td_class(entry, date),
      ]
      date = date.next
    end
  end

  def team_week
    @start_date = parse_week_date
    @now = Date.today

    @return_params = { from_team_id: params[:team_id], from_date: params[:date] }

    # Not sure how to do this in ActiveRecord without the subquery. :(
    @users = User.
      joins(:teams_users).
      merge(TeamsUser.where(team: @teams)).
      includes(:teams).
      order(:name).
      uniq

    entries = LogEntry.
      where(user_id: @users.map(&:id)).
      where('day >= ?', @start_date).
      where('day < ?', @start_date + 7.days).
      includes(:user)
    entries_map = Hash.new { |h, k| h[k] = {} }
    entries.each { |entry| entries_map[entry.user_id][entry.day.to_s] = entry.details }

    @table_data = @users.each_with_object({}) do |user, memo|
      row = Array.new(7)
      user_map = entries_map[user.id]
      (0..6).each do |i|
        date = @start_date + i.days
        entry = user_map && user_map[date.to_s]
        row[i] = [
          date,
          entry,
          get_td_class(entry, date),
        ]
      end
      memo[user.id] = row
    end
  end

  private

  def redirect_to_month_or_week
    if params[:from_team_id] && params[:from_date]
      redirect_to team_week_path(team_id: params[:from_team_id], date: params[:from_date])
    else
      redirect_to month_path(user_id: current_user.id, year: @date.year, month: @date.strftime('%B'))
    end
  end

  def get_td_class(entry, date)
    if entry.nil?
      nil
    elsif date > @now
      'future'
    elsif date < @now
      'past'
    else
      'present'
    end
  end

  def parse_week_date
    params.require(:date) == 'now' ? Date.today - 3.days : Date.parse(params.require(:date))
  end

  def parse_entry_date
    @date = Date.new(
      params.require(:year).to_i,
      params.require(:month).to_i,
      params.require(:day).to_i,
    )
  end

  def do_create_or_update(entry = nil)
    if entry
      entry.update(details: params.require(:details))
    else
      entry = LogEntry.create(user: current_user, day: @date, details: params.require(:details))
    end
    if !entry.valid?
      flash[:alert] = "Entry not saved. #{entry.errors.full_messages.first}"
    end
  end

  def first_year_for_user(user)
    LogEntry.where(user: user).minimum(:day).try(:year)
  end

  def last_year_for_user(user)
    LogEntry.where(user: user).maximum(:day).try(:year)
  end

  def set_teams
    if params.require(:team_id) == 'all'
      @teams = current_user.teams
    else
      @teams = Team.where(id: params.require(:team_id))
    end
  end

  def check_team_membership
    if params.require(:team_id) != 'all' && !current_user.teams.include?(@teams.first)
      redirect_to root_path, alert: 'You\'re not a member of this team.'
    end
  end

  def check_is_teammate_or_self
    if (
      params.require(:user_id) != current_user.id &&
      (current_user.teams & User.find(params[:user_id]).teams).empty?
    )
      redirect_to root_path, alert: 'You don\'t have permission to view this user.'
    end
  end
end
