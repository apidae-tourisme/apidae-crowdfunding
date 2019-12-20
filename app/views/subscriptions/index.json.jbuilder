json.array! @subscriptions  do |s|
  json.label s.label
  json.category s.category
  json.amount s.total
end