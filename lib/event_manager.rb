require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end
  
def first_num_test(phone_number)
  number = phone_number.to_s.split(//)
  phone_num_length = phone_number.to_s.length
  number.delete_at(0) if phone_num_length == 11 && phone_number.to_s.split(//)[0] == '1' 
  number = number.join.to_i if number.length == 10
  if phone_number.to_s.split('')[0] != '1' && phone_num_length == 11
    return 
  else
    return number 
  end
end

def clean_phone_number(phone_number)
    phone_num_length = phone_number.to_s.length
    case phone_num_length
      when 0..9, 12.. then return
      when 10 then return phone_number
    end
    first_num_test(phone_number)
end

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
=begin
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
=end

def registration_hour(reg_date)
  date_time = Time.strptime(reg_date.to_s, '%m/%d/%y %k:%M').hour
end

def registration_day(reg_date)
  date_time = Date.strptime(reg_date.to_s, '%m/%d/%y').wday
end

def highest_day(totals_array)
  totals = totals_array.tally
  most_frequent = totals.max_by{|key, value| value }.to_a
  most_frequent = most_frequent[0]
  puts "#{Date::DAYNAMES[most_frequent]} was the day with the most registrations"
end

def highest_hour(totals_array)
    totals = totals_array.tally
    most_frequent = totals.max_by{|key, value| value }.to_a
    most_frequent = most_frequent[0]
    puts "#{most_frequent} was the hour with the most registrations"
end

def count_hours(file)
  totals = []
  file.each do |row|
    totals.push(registration_hour(row[:regdate]))
  end
  highest_hour(totals)
end

def count_days(file)
  totals = []
  file.each do |row|
    totals.push(registration_day(row[:regdate]))
  end
  highest_day(totals)
end








