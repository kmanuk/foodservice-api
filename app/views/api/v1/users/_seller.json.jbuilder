json.partial! 'api/v1/users/basic', user: user

json.recommended_seller user.recommended_seller
json.av_rate user.av_rate
json.reviews user.reviews.count
json.business_name user.business_name


json.address do
  if user.address
    json.partial! 'api/v1/addresses/address', address: user.address
  else
    json.null!
  end
end
