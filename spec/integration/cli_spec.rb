require 'spec_helper'

START_SUCCESSFUL = "Checked in"
DOUBLE_START     = "Time tracking already running!"
STOP_SUCCESSFUL  = "Checked out"
NOT_RUNNING      = "Time tracking not running!"
EDIT_SUCCESSFULL = "Entry changed"
EDIT_FAILED      = "Entry %d not found!"

MINUTE = 60
HOUR = MINUTE * 60
DAY = HOUR * 24

describe 'TimeTracker' do
  before :all do
    setup_config
  end

  before do
    reset_timesheet!
    time_tracking.should have_no_entries
  end

  describe "starting the timer" do
    it "works" do
      t('in').should include(START_SUCCESSFUL)
      time_tracking.should be_running
      time_tracking.should have_checked_in_at(Time.now)
    end

    it "is aliased to s" do
      t('i').should include START_SUCCESSFUL
      time_tracking.should be_running
    end

    it "warns when already started" do
      t('i')
      t('i').should include DOUBLE_START
    end

    it "sets the message when present" do
      t('i', 'a cool message')
      time_tracking.should be_running_with_message('a cool message')
    end

    it "sets the time correctly" do
      t('i', '2d3h25m')
      delta = 2 * DAY + 3 * HOUR + 25 * MINUTE
      time_tracking.should have_checked_in_at(Time.now - (delta))
    end

    it "sets the time correctly with a message" do
      t('i', '+1d3h10m', 'what an entry')
      delta = 1 * DAY + 3 * HOUR + 10 * MINUTE
      time_tracking.should have_checked_in_at(Time.now + (delta))
      time_tracking.should be_running_with_message('what an entry')
    end
  end

  describe "stopping the timer" do
    before do
      @start_time = Time.now - 20 * MINUTE
      t('i', '20m')
    end

    it "works" do
      t('out').should include(STOP_SUCCESSFUL)
      time_tracking.should_not be_running
    end

    it "is aliased to o" do
      t('o').should include(STOP_SUCCESSFUL)
      time_tracking.should have_checked_in_at(@start_time)
      time_tracking.should_not be_running
    end

    it "warns when not running" do
      t('o')
      t('o').should include(NOT_RUNNING)
    end

    it "sets the time correctly" do
      t('i')
      t('o', '+1h40m')
      delta = 1 * HOUR + 40 * MINUTE
      time_tracking.should have_checked_out_at(Time.now + delta)
    end

    it "sets the time correctly with a message and overwrites check in" do
      t('i', 'not the message')
      t('o', 'that is the message!')
      time_tracking.should have_ran_with_message('that is the message!')
    end
  end

  describe 'editing an entry' do
    before do
      @start_time_one = Time.now - 1 * HOUR
      t('i', '1h', 'entry one')
      t('o', '30m')
      @stop_time_one = Time.now - 30 * MINUTE
      @start_time_two = Time.now - 20 * MINUTE
      t('i', '20m', 'entry two')
    end
    it "edits the last entry by default" do
      t('e', 'edited running entry two').should include(EDIT_SUCCESSFULL)
      time_tracking.should be_running_with_message('edited running entry two')
      time_tracking.should have_checked_in_at(@start_time_two)
      @stop_time_two = Time.now
      t('o')
      t('e', 'edited stopped entry two').should include(EDIT_SUCCESSFULL)
      time_tracking.should have_ran_with_message('edited stopped entry two')
      time_tracking.should have_checked_in_at(@start_time_two)
      time_tracking.should have_checked_out_at(@stop_time_two)
    end

    it "edits the correct entry when id is given" do
      @stop_time_two = Time.now
      t('o')
      t('e', '0', 'edited stopped entry one').should include(EDIT_SUCCESSFULL)
      time_tracking.should have_ran_with_message('entry two')
      time_tracking.should have_a_given_entry_with_message(0, 'edited stopped entry one')
    end

    it "fails when editing a not existing entry" do
      output = t('e', '37', 'OH NOES').should include(EDIT_FAILED % 37)
    end
  end

  describe 'removing an entry' do
    before do
      t('i', '1h', 'entry one')
      t('o', '30m')
      @start_time_two = Time.now - 20 * MINUTE
      t('i', '20m', 'entry two')
      @stop_time_two = Time.now
      t('o')
    end

    it "works" do
      t('d', '0')
      time_tracking.should have_a_given_number_of_entries(1)
      time_tracking.should have_ran_with_message 'entry two'
      time_tracking.should have_checked_in_at(@start_time_two)
      time_tracking.should have_checked_out_at(@stop_time_two)
    end
  end
end