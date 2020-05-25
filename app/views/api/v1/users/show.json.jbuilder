case @user.role
  when 'seller' then json.partial! 'api/v1/users/seller', user: @user
  when 'buyer' then json.partial! 'api/v1/users/basic', user: @user
  when 'driver' then json.partial! 'api/v1/users/driver', user: @user
  else  json.null!
end