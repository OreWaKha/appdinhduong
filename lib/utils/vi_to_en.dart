// utils/vi_to_en.dart
final Map<String, String> viToEn = {
  "thịt gà": "Chicken, broilers or fryers, breast, meat only, raw",
  "đùi gà": "Chicken, drumstick, meat only, raw",
  "thịt bò băm": "Beef, ground, 85% lean meat / 15% fat, raw",
  "thịt bò" : "Beef",
  "thịt lợn": "Pork, fresh, loin, tenderloin, raw",
  "thịt cừu": "Lamb, loin, raw",
  "thịt gà tây": "Turkey, ground, raw",
  "trứng gà": "Egg, whole, raw, fresh",
  "lòng trắng trứng": "Egg white, raw",
  "lòng đỏ trứng": "Egg yolk, raw",
  "bacon": "Bacon, raw",
  "xúc xích": "Sausage, pork",
  "giăm bông": "Ham, sliced, cured",
  "thịt bò steak": "Beef steak, top loin, raw",
  "cánh gà": "Chicken wing, raw",
  "thịt vịt": "Duck, meat only, raw",
  "thịt bê": "Veal, cutlet, raw",
  "thịt viên": "Meatballs, beef cooked",
  "sườn lợn": "Pork chop, raw",
  "gà tây băm nấu chín": "Ground turkey cooked",
  "meatloaf": "Meatloaf cooked",

  // Cá & hải sản
  "cá hồi": "Salmon, raw",
  "cá ngừ": "Tuna, light, canned in water",
  "tôm": "Shrimp, raw",
  "cua": "Crab, raw",
  "cá hồi nheo": "Trout, raw",
  "cá mòi": "Sardines, canned in oil",
  "ngao": "Clams, raw",
  "sò điệp": "Scallops, raw",
  "tôm hùm": "Lobster, raw",
  "hàu": "Oysters, raw",

  // Rau
  "bông cải xanh": "Broccoli, raw",
  "rau chân vịt": "Spinach, raw",
  "xà lách": "Lettuce, raw",
  "cà rốt": "Carrots, raw",
  "khoai tây": "Potatoes, raw",
  "cà chua": "Tomatoes, raw",
  "dưa chuột": "Cucumber, raw",
  "bắp ngọt": "Sweet corn, raw",
  "đậu hà lan": "Green peas, raw",
  "ớt chuông": "Bell peppers, raw",

  // Trái cây
  "táo": "Apple, raw",
  "chuối": "Banana, raw",
  "cam": "Orange, raw",
  "nho": "Grapes, raw",
  "dâu tây": "Strawberry, raw",
  "việt quất": "Blueberries, raw",
  "xoài": "Mango, raw",
  "dứa": "Pineapple, raw",
  "dưa hấu": "Watermelon, raw",
  "đào": "Peach, raw",

  // Ngũ cốc & tinh bột
  "cơm trắng": "Rice, white, long-grain, regular, raw",
  "bánh mì nguyên cám": "Bread, whole wheat",
  "bánh mì trắng": "Bread, white",
  "mì ống nấu chín": "Pasta, cooked",
  "yến mạch": "Oats, raw",
  "ngũ cốc": "Cereal, bran flakes",
  "tortilla ngô": "Tortilla, corn",
  "bánh vòng": "Bagel, plain",
  "bánh quy": "Crackers",

  // Sữa & sản phẩm từ sữa
  "sữa nguyên kem": "Milk, whole",
  "sữa 2%": "Milk, 2% fat",
  "sữa tách béo": "Milk, skim",
  "sữa chua tự nhiên": "Yogurt, plain",
  "sữa chua trái cây": "Yogurt, fruit flavored",
  "phô mai cheddar": "Cheese, cheddar",
  "phô mai mozzarella": "Cheese, mozzarella",
  "bơ": "Butter, salted",
  "kem": "Ice cream, vanilla",
  "phô mai cottage": "Cottage cheese",

  // Dầu & chất béo
  "dầu ô liu": "Olive oil",
  "dầu bơ": "Butter oil",
  "dầu dừa": "Coconut oil",
  "dầu cải": "Canola oil",
  "margarine": "Margarine",

  // Đậu & hạt
  "hạnh nhân": "Almonds, dry roasted",
  "đậu phộng": "Peanuts, dry roasted",
  "óc chó": "Walnuts, raw",
  "hạt điều": "Cashews, raw",
  "hạt hướng dương": "Sunflower seeds",
  "đậu lăng": "Lentils, raw",
  "đậu chickpeas": "Chickpeas, raw",
  "đậu đỏ": "Kidney beans, raw",
  "đậu đen": "Black beans, raw",
  "đậu nành": "Soybeans, raw",

  // Đồ uống
  "cà phê": "Coffee, brewed",
  "trà đen": "Tea, black, brewed",
  "nước ngọt cola": "Cola soft drink",
  "nước cam": "Orange juice",
  "nước táo": "Apple juice",
  "nước lọc": "Water",

  // Đồ ăn nhanh & chế biến
  "pizza phô mai": "Pizza, cheese",
  "khoai tây chiên": "French fries",
  "hamburger": "Hamburger, with bun",
  "gà rán": "Fried chicken",
  "hot dog": "Hot dog, plain",
  "burrito": "Burrito, bean & cheese",
  "taco": "Taco, beef",
  "nachos": "Nachos",
  "bánh donut": "Donut, glazed"
};

String translateToEnglish(String input) {
  return viToEn[input.toLowerCase().trim()] ?? "";
}
