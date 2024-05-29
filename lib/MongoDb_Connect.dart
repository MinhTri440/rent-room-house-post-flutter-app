import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'env.dart';
import 'model/User.dart';
class MongoDatabase {

  static Future<List<Map<String, dynamic>>> list_test() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('test');
    Future<List<Map<String, dynamic>>> search = user.find().toList();
    return search;
  }
  static Future<List<Map<String, dynamic>>> list_user() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('User');
    Future<List<Map<String, dynamic>>> search = user.find().toList();
    return search;
  }

  static Future<Map<String, dynamic>?> getUser(String? email) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');
    Map<String, dynamic>? search = await users.findOne({
      'email': email,
    });
    return search;
  }

  static Future<bool> createUser(UserMongo user) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Kiểm tra xem email đã tồn tại chưa
      var existingUser = await users.findOne({'email': user.email,});
      if (existingUser != null) {
        await db.close();
        return false; // Email đã tồn tại
      }

      // Email chưa tồn tại, tạo người dùng mới
      await users.insert({
        "username": user.username,
        "email":user.email,
        "password":user.password,
        "type":user.type,
        "phone":user.phone,
        "image": user.image,
        "createdAt": DateTime.now(),
        "updateAt":DateTime.now()
      });
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating user: $e');
      return false;
    }
  }

  static Future<bool> checkGmailtoCreate(String? email, String? username, String? phone, String? image) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Kiểm tra xem email đã tồn tại chưa
      var existingUser = await users.findOne({'email': email});
      if (existingUser != null) {
        // Email đã tồn tại, cập nhật username và image
        await users.update(
            where.eq('email', email),
            modify
                .set('username', username)
                .set('image', image)
                .set('updatedAt', DateTime.now())
        );
        await db.close();
        return true; // Đã cập nhật người dùng hiện có
      }

      // Email chưa tồn tại, tạo người dùng mới
      await users.insert({
        "username": username,
        "email": email,
        "type": "gmail",
        "image": image,
        "createdAt": DateTime.now(),
        "updatedAt": DateTime.now(),
      });
      await db.close();
      return true; // Đã tạo người dùng mới
    } catch (e) {
      print('Error occurred while creating or updating user: $e');
      return false;
    }
  }


}