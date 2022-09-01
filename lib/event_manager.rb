require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end
  
def first_num_test(phone_number)
  number = phone_number.to_s.split(//)
  phone_num_length = phone_number.to_s.length
  number.delete_at(0) if phone_num_length == 11 && phone_number.to_s.split(//)[0] == '1' 
  number = number.join.to_i if number.length == 10
  if phone_number.to_s.split('')[0] != '1' && phone_num_length == 11
    puts 'bad' 
  else
    return number 
  end
end

def clean_phone_number(phone_number)
    phone_num_length = phone_number.to_s.length
    case phone_num_length
      when 0..9, 12.. then puts 'bad phone number'
      when 10 then puts 'good'
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

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end