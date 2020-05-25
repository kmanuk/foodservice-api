# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ en: 'Star Wars' }, { en: 'Lord of the Rings' }])
#   Character.create(en: 'Luke', movie: movies.first)

unless Rails.env.production?
  admin = AdminUser.new(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
  admin.save unless AdminUser.exists?(email: 'admin@example.com')
end

#COOK'S MENU

data = [{en: 'Kitchen', ar: 'المطبخ', image: 'kitchen.png',
         categories: [{en: 'Main courses', ar: 'أطباق رئيسية', image: 'main-courses.png',
                       sub_categories: [{en: 'Authentic', ar: 'أكلات شعبية', image: 'authentic-main-courses.png'},
                                        {en: 'Seafood', ar: 'مأكولات بحرية', image: 'sea-food.png'},
                                        {en: 'Pasta and baked', ar: 'المعكرونة والمعجنات', image: 'pasta.png'},
                                        {en: 'Grilled', ar: 'مشوي اللحوم / الدجاج', image: 'grilled.png'},
                                        {en: 'Vegetarian', ar: 'نباتي', image: 'vegetarian-main-courses.png'},
                                        {en: 'Creative dishes', ar: 'أطباق الإبداعية', image: 'creative-main-courses.png'},]},
                      {en: 'Soups and Salads', ar: 'شوربة والسلطة', image: 'soups-and-salads.png',
                       sub_categories: [{en: 'Vegetables soups', ar: 'شوربةالخضروات', image: 'vegetables-soups.png'},
                                        {en: 'Meat and chicken soups', ar: 'شوربةاللحوم والدجاج', image: 'meat-chicken-soup.png'},
                                        {en: 'Vegetarian salads', ar: 'السلطات النباتية', image: 'vegetarian-salads.png'},
                                        {en: 'Meat and chicken salads', ar: 'سلطات اللحوم والدجاج', image: 'meat-chicken-salad.png'},
                                        {en: 'Creative soups', ar: 'شوربات الإبداعية', image: 'creative-soups.png'},
                                        {en: 'Creative salads', ar: 'السلطات الإبداعية', image: 'creative-salads.png'}]},
                      {en: 'Sides and snacks', ar: 'الوجبات الخفيفة والمقبلات', image: 'sides-and-snacks.png',
                       sub_categories: [{en: 'Authentic', ar: 'أكلات شعبية', image: 'authentic-snacks.png'},
                                        {en: 'Vegetarian', ar: 'نباتي', image: 'vegetarian-snacks.png'},
                                        {en: 'Meat and chicken', ar: 'اللحوم / الدجاج', image: 'meat-chicken-snacks.png'},
                                        {en: 'Baked', ar: 'معجنات', image: 'baked.png'},
                                        {en: 'Sandwiches', ar: 'سندويشات', image: 'sandwiches.png'},
                                        {en: 'Creative sides and snacks', ar: 'مقبلات الإبداعية', image: 'snacks-and-sides.png'}]},
                      {en: 'Sweets and deserts', ar: 'الحلويات', image: 'sweets-and-deserts.png',
                       sub_categories: [{en: 'Authentic', ar: 'حلويات شعبية', image: 'authentic-sweets.png'},
                                        {en: 'Cakes and chocolate', ar: 'الكعك و الشوكولاته', image: 'cake-chocolate.png'},
                                        {en: 'Ice creams', ar: 'مثلجات', image: 'ice-cream.png'},
                                        {en: 'Creative sweets and deserts', ar: 'الحلويات الإبداعية', image: 'creative-sweets-and-deserts.png'}]},
                      {en: 'Drinks', ar: 'المشروبات', image: 'drinks.png',
                       sub_categories: [{en: 'Cold drinks', ar: 'المشروبات الباردة', image: 'cold-drinks.png'},
                                        {en: 'Hot drinks', ar: 'المشروبات الساخنة', image: 'hot-drinks.png'},
                                        {en: 'Creative drinks', ar: 'المشروبات الإبداعية', image: 'creative-drinks.png'}]},
                      {en: 'Breakfast', ar: 'الفطور', image: 'breakfast.png',
                       sub_categories: [{en: 'Egg dishes', ar: 'أطباق البيض', image: 'egg-dishes.png'},
                                        {en: 'Fava beans and Falafel', ar: ' فول وفلافل', image: 'fava-beans.png'},
                                        {en: 'Pancakes and Sandwiches', ar: 'البانكيك والسندويشات', image: 'pancakes-and-sandwiches.png'},
                                        {en: 'Meat and liver dishes', ar: 'أطباق المقلقل والكبدة', image: 'meat-liver-dishes.png'},
                                        {en: 'Creative and other Breakfast dishes', ar: 'أطباق فطور إبداعية وأطباق أخرى', image: 'creative-breakfast.png'}]}]},
        {en: 'Farms', ar: 'منتجات المزارع', image: 'farm.png',
         categories: [{en: 'Fresh meats (parts)', ar: 'لحم طازج مقطع', image: 'fresh-meats-parts.png',
                       sub_categories: [{en: 'Sheep', ar: 'غنم', image: 'sheep-parts.png'},
                                        {en: 'Camel', ar: 'جمل', image: 'camel-parts.png'},
                                        {en: 'Birds and chicken', ar: 'طيور ودجاج', image: 'birds-chicken-parts.png'},
                                        {en: 'Fish', ar: 'سمك', image: 'fish-parts.png'},
                                        {en: 'Rabbits', ar: 'أرانب', image: 'rabbits-parts.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Whole Animal', ar: 'ذبيحة كاملة', image: 'sheep-whole.png',
                       sub_categories: [{en: 'Sheep', ar: 'غنم', image: 'sheep-whole.png'},
                                        {en: 'Camel', ar: 'جمل', image: 'camel-whole.png'},
                                        {en: 'Birds', ar: 'طيور ودجاج', image: 'birds-whole.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Eggs and fresh milk', ar: 'البيض و الحليب الطازج', image: 'eggs-and-fresh-milk.png',
                       sub_categories: [{en: 'Camel Milk', ar: 'حليب الناقة', image: 'camel-milk.png'},
                                        {en: 'Sheep Milk', ar: 'حليب الغن', image: 'sheep-milk.png'},
                                        {en: 'Local Eggs', ar: 'البيض البلدي', image: 'local-eggs.png'},
                                        {en: 'Organic Eggs', ar: 'البيض العضوي', image: 'organic-eggs.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Fresh Vegetables', ar: 'الخضروات الطازجة', image: 'fresh-vegetables.png',
                       sub_categories: [{en: 'Tomatoes and onions', ar: 'الطماطم والبصل', image: 'tomatoes-onions.png'},
                                        {en: 'Potatoes and Eggplants', ar: 'البطاطا و الباذنجان', image: 'potatoes-eggplants.png'},
                                        {en: 'Greens', ar: 'الورقيات', image: 'greens.png'},
                                        {en: 'Carrots and cucumbers', ar: 'الجزر والخيار', image: 'carrots-cucumbers.png'},
                                        {en: 'Local and Organic', ar: 'عضوي', image: 'local-and-organic.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Fresh Fruits', ar: 'الفواكه الطازجة', image: 'fresh-fruits.png',
                       sub_categories: [{en: 'Dates', ar: 'التمور', image: 'dates.png'},
                                        {en: 'Orange, apples and bananas', ar: 'البرتقال والتفاح و الموز', image: 'orange-apples-bananas.png'},
                                        {en: 'Watermelon', ar: 'بطيخ', image: 'watermelon.png'},
                                        {en: 'Local and Organic', ar: 'عضوي و بلدي', image: 'local-and-organic.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]}]},
        {en: 'Alternative Medicine', ar: 'الطب البديل', image: 'medicine.png',
         categories: [{en: 'Plants based', ar: 'علاج نباتي', image: 'plants-based.png',
                       sub_categories: [{en: 'Herbal remedies', ar: 'علاج بالأعشاب', image: 'herbal-remedies.png'},
                                        {en: 'Dried plant, leafs and fruits', ar: ' أوراق وفواكة مجففة', image: 'dried-plant.png'},
                                        {en: 'Olive and other plant oils', ar: 'زيت زيتون وزيوت نباتية أخرى', image: 'olive-and-oils.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Animal based', ar: 'علاج من منتجات حيوانية', image: 'animal-based.png',
                       sub_categories: [{en: 'Fresh Organic honey', ar: 'عسل عضوي طازج', image: 'fresh-organic-honey.png'},
                                        {en: 'Animal parts/ related', ar: 'أجزاء من الحيوانات أو شيء مرتبط بها', image: 'animal-parts-related.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]},
                      {en: 'Religious based', ar: 'علاج ديني', image: 'religious-based.png',
                       sub_categories: [{en: 'Zamzam holy water', ar: 'ماء زمزم المبارك', image: 'zamzam-holy-water.png'},
                                        {en: 'Others', ar: 'اخرى', image: 'others.png'}]}]}
]


def image_path(img)
  Rails.root.join('app', 'assets', 'images', 'Icons', img)
end

def create_product_set(data)
  data.each do |pt|
    product_type = ProductType.find_or_create_by(en: pt[:en], ar: pt[:ar])
    Image.create({data: File.new(image_path(pt[:image])), imageable: product_type}) if product_type.image.nil? && pt[:image].present?


    pt[:categories].each do |c|

      category = Category.find_or_create_by(en: c[:en],
                                            ar: c[:ar],
                                            product_type: product_type)
      Image.create({data: File.new(image_path(c[:image])), imageable: category}) if category.image.nil? && c[:image].present?

      c[:sub_categories].each do |sc|
        sub_category = SubCategory.find_or_create_by(en: sc[:en],
                                                     ar: sc[:ar],
                                                     category: category)
        Image.create({data: File.new(image_path(sc[:image])), imageable: sub_category}) if sub_category.image.nil? && sc[:image].present?
      end
    end
  end
end

create_product_set(data)
