json.array! @subscriptions  do |s|
  json.timestamp s.creation_date.to_i
  json.date s.creation_date
  json.label s.label
  json.category s.category
  json.amount s.total
end