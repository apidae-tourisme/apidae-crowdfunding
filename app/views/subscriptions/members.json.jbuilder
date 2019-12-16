json.members do
  json.array!(@members) do |m|
    json.text m.name
    json.id m.apidae_id
  end
end
