json.array!(@todos) do |todo|
  json.extract! todo, :task, :due
  json.url todo_url(todo, format: :json)
end