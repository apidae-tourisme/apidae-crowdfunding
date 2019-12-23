json.array! @subscriptions  do |s|
  json.date s.creation_date
  json.label s.label
  json.category s.category
  json.amount s.total
end