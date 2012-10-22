require 'tempfile'
require 'json'
require 'escape'

module Helpers
  BINARY = File.expand_path('../../../bin/t', __FILE__)

  def setup_config
    @data_file_path = Tempfile.new('times').path
    @config = {
      data_file: @data_file_path
    }
    @config_path = Tempfile.new('config').path
    File.open(@config_path, 'w') do |f|
      f.write JSON.dump(@config)
    end
  end

  def reset_timesheet!
    File.delete @data_file_path if File.exist? @data_file_path
  end

  def t(*args)
    args.unshift(@config_path).unshift('--config')
    @output = Kernel.send(:'`', Escape.shell_command([BINARY, *args])).chomp
  end

  def time_entries
    return unless File.exist?(@data_file_path)
    JSON.parse(File.read(@data_file_path))
  end

  # Dummy method to be able to call: time_tracking.should be_started
  def time_tracking
    'TimeTracker'
  end
end

RSpec.configure{|config| config.include(Helpers)}