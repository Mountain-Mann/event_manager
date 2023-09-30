# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  # Convert to string if not already a string
  phone_str = phone_number.to_s
  # Remove non-digits from string
  phone_digits = phone_str.gsub(/[^\d]/, '')
  # Check length and format of cleaned phone number
  if phone_digits.length == 10
    phone_digits
  elsif phone_digits.length == 11 && phone_digits[0] == '1'
    phone_digits[1..10]
  else
    'Wrong Number!!'
  end
end

def clean_date(reg_date)
  raw_date = DateTime.strptime(reg_date, '%m/%d/%Y %k:%M')
  raw_date.strftime('%Y/%m/%d %k:%M')
end

# def get_peak_hour(registration_dates)
#   # Convert registration times from string to DateTime objects
# registration_dates = registration_dates.map { |time_str| DateTime.strptime(time_str, '%Y-%m-%d %H:%M:%S') }

# # Group registrations by hour and count number of registrations for each hour
# hourly_registrations = registration_dates.group_by {&:hour}.map { |hour, registrations| [hour, registrations.length] }.to_h

# # Find the hour with the highest number of registrations
# peak_hour = hourly_registrations.max_by { |hour, count| count }[0]

# end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
day_hour_array = []
weekday_array = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  reg_date = row[:regdate]
  fin_date = clean_date(reg_date)
  time_format = '%Y/%m/%d %k:%M'
  days = Date::DAYNAMES

  puts "Fetching info for #{name}, ID ##{id}."
  puts reg_date
  puts fin_date

  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_number(row[:homephone])

  date = DateTime.strptime(reg_date, '%m/%d/%Y %k:%M')
  puts date
  weekday = days[date.wday]
  weekday_array << weekday
  day_hour_array << date.hour

  puts "Phone number: #{phone}"
  puts date
  puts "Day of the week: #{weekday}"

  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)

  puts "There's the info you wanted..."
  puts ''
end

# Print results
puts "Hour that most people registered: #{day_hour_array.max_by { |a| day_hour_array.count(a) }}h"
puts "Day that most people registered: #{weekday_array.max_by { |a| weekday_array.count(a) }}"
