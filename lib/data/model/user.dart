class User {
  int id;
  String name;
  String username;
  String city;
  String phone;

  User(this.id, this.name, this.username, this.city, this.phone);

  factory User.fromMapJason(Map<String, dynamic> jsonObject) {
    return User(jsonObject['id'], jsonObject['name'], jsonObject['username'],
        jsonObject['address']['city'], jsonObject['phone']);
  }
}
