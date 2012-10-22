time_tracker_last_entry_matcher = lambda {|name, &blck|
  RSpec::Matchers.define name do |*attrs|
    match do
      entries = time_entries
      last_entry = entries ? entries.last : nil
      blck.call(*[last_entry, *attrs]) if blck
    end
  end
}

time_tracker_all_entries_matcher = lambda {|name, &blck|
  RSpec::Matchers.define name do |*attrs|
    match do
      entries = time_entries
      blck.call(*[entries, *attrs]) if blck
    end
  end
}

time_tracker_last_entry_matcher.call(:be_running) do |last_entry|
  last_entry && last_entry['start'] && last_entry['start'].to_i > 0 && !last_entry['end']
end

time_tracker_last_entry_matcher.call(:be_running_with_message) do |last_entry, msg|
  last_entry && last_entry['start'] && last_entry['start'].to_i > 0 && !last_entry['end'] && last_entry['message'] == msg
end

time_tracker_last_entry_matcher.call(:have_checked_in_at) do |last_entry, time|
  last_entry && last_entry['start'] && last_entry['start'].to_i >= time.to_i - 2 && last_entry['start'].to_i <= time.to_i + 2
end

time_tracker_last_entry_matcher.call(:have_checked_out_at) do |last_entry, time|
  last_entry && last_entry['end'] && last_entry['end'].to_i >= time.to_i - 2 && last_entry['end'].to_i <= time.to_i + 2
end

time_tracker_last_entry_matcher.call(:have_ran_with_message) do |last_entry, msg|
  last_entry && last_entry['end'] && last_entry['end'].to_i > 0 && last_entry['message'] == msg
end

time_tracker_all_entries_matcher.call(:have_a_given_number_of_entries) do |entries, size|
  entries.size == size
end

time_tracker_all_entries_matcher.call(:have_a_given_entry_with_message) do |entries, id, msg|
  entries[id]['message'] == msg
end

time_tracker_all_entries_matcher.call(:have_no_entries) do |entries|
  !entries || entries.empty?
end