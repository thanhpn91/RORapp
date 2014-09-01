require 'rufus-scheduler'

scheduler = Rufus::Scheduler.start_new

scheduler.every '5m' do
  Foody.call_parse
end
scheduler.join