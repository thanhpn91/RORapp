require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '5m' do
  runner "Foody_call_parse"
end