json.array!(@foodies) do |foody|
  #json.extract! foody,:id, :title, :address, :description, :photos, :category
  if foody.category == 1
    json.cafe foody,:id,:title,:address, :description, :photos, :category
  elsif foody.category == 2
     json.bar foody,:id,:title, :address, :description, :photos, :category
  elsif foody.category == 3
     json.restaurant foody,:id,:title, :address, :description, :photos, :category
  end
  json.url foody_url(foody, format: :json)
end
