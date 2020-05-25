json.extract! review,
              :id,
              :rate,
              :message,
              :order_id,
              :created_at

json.user do
  json.partial! 'api/v1/users/basic', user: review.ratable
end

json.reviewer do
  json.partial! 'api/v1/users/basic', user: review.reviewer
end
