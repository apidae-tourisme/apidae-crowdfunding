json.array! @subscriptions do |s|
  json.id s.sub_id
  json.label s.label
  json.value Math.log(s.total, 10)
  json.category s.category
  json.amount s.total
end