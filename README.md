# FoodinHoods API
master | staging
--- | ---
[![build status](https://gitlab.customertimes.com/web-department/FoodInHoods-api/badges/master/build.svg)](https://gitlab.customertimes.com/web-department/FoodInHoods-api/commits/master) | [![build status](https://gitlab.customertimes.com/web-department/FoodInHoods-api/badges/staging/build.svg)](https://gitlab.customertimes.com/web-department/FoodInHoods-api/commits/staging)
[![coverage report](https://gitlab.customertimes.com/web-department/FoodInHoods-api/badges/master/coverage.svg)](https://gitlab.customertimes.com/web-department/FoodInHoods-api/commits/master) | [![coverage report](https://gitlab.customertimes.com/web-department/FoodInHoods-api/badges/staging/coverage.svg)](https://gitlab.customertimes.com/web-department/FoodInHoods-api/commits/staging)

REST API for FoodinHoods project

##### Admin
https://api.foodinhoods.com/admin - production

`****** / ******`

https://api.staging.foodinhoods.com/admin - staging

`admin@example.com / password`

##### API
https://api.foodinhoods.com - production

https://api.staging.foodinhoods.com - staging


##### API documentation
https://api.foodinhoods.com/documentation - production

`doc / ******`

https://api.staging.foodinhoods.com/documentation - staging

`doc / customertimes`

##### Sidekiq
https://api.foodinhoods.com/sidekiq - production

`sidekiq / ******`

https://api.staging.foodinhoods.com/sidekiq - staging

`sidekiq / customertimes`

### Requirements

* Ruby 2.4.0
* PostgreSQL 9.6
* file
* imagemagick
* curl
* redis

### Installation

1. `cp .env.sample .env`
2. `change .env file`
3. `bundle install`
4. `bundle exec rails db:create`
5. `bundle exec rails db:migrate`
6. `bundle exec rails db:seed`
7. `bundle exec sidekiq`
8. `bundle exec rails s`

### Commands

* for generating examples in documentation run
`env APIPIE_RECORD=examples rspec`
