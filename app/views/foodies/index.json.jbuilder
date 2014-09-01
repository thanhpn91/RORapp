json.array!(@foodies) do |foody|
  json.extract! foody, :id, :title, :address, :description, :photos, :category
  json.url foody_url(foody, format: :json)
end
