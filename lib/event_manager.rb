# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

registration_dates = []

def get_peak_hour(registration_dates)
  # Convert registration times from string to DateTime objects
registration_dates = registration_dates.map { |time_str| DateTime.strptime(time_str, '%Y-%m-%d %H:%M:%S') }

# Group registrations by hour and count number of registrations for each hour
hourly_registrations = registration_dates.group_by {&:hour}.map { |hour, registrations| [hour, registrations.length] }.to_h

# Find the hour with the highest number of registrations
peak_hour = hourly_registrations.max_by { |hour, count| count }[0]

# Print results
puts "Hourly registrations: #{hourly_registrations}"
puts "Peak registration hour: #{peak_hour}"
end

peak_reg = get_peak_hour(registration_dates)

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

def save_thank_you_letter(id,form_letter)
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

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone = clean_phone_number(row[:HomePhone])
  # Get the "registration_date" column from the current row
  registration_date_str = row[:RegDate]
  # Convert the string to a DateTime object and add it to the registration_dates array
  registration_dates << DateTime.strptime(registration_date_str, '%Y-%m-%d %H:%M:%S')

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
