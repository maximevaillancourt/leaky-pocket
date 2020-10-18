#######################################################
# Initial configuration
#######################################################
ARCHIVE_ITEMS_OLDER_THAN = 7.days
CONSUMER_KEY = '' # your Pocket app's consumer key here
ACCESS_TOKEN = '' # your Pocket app's access token here

#######################################################
# You don't need to change anything below this line.
#######################################################
require 'httparty'
require 'date'

now = Date.today
threshold = now - ARCHIVE_ITEMS_OLDER_THAN

# Get all saved items
response = HTTParty.post(
  'https://getpocket.com/v3/get',
  headers: {
    'Content-Type' => 'application/json',
    'X-Accept' => 'application/json',
  },
  body: {
    "consumer_key" => CONSUMER_KEY,
    "access_token" => ACCESS_TOKEN,
    "state" => "all",
  }.to_json,
)
items = JSON.parse(response.body)['list'].values

# Get all saved items
old_items = items.filter do |item|
  time_added = Time.at(item['time_added'].to_i).to_date
  time_added <= threshold
end
return if old_items.size == 0

# Archive old items
archive_actions = old_items.map do |item|
  {
    "action" => "archive",
    "item_id" => item['item_id'],
  }
end

response = HTTParty.post(
  'https://getpocket.com/v3/send',
  headers: {
    'Content-Type' => 'application/json',
    'X-Accept' => 'application/json',
  },
  body: {
    "actions" => archive_actions,
    "consumer_key" => CONSUMER_KEY,
    "access_token" => ACCESS_TOKEN,
  }.to_json,
)

puts response.code
puts response.body
