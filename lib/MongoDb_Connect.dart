import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:post_house_rent_app/model/Post.dart';
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

  static Future<String?> get_IdfromUser(String? email) async {
    if (email == null) {
      return null;
    }

    var db = await Db.create(MONGO_URL);
    await db.open();
    var users = db.collection('User');

    var search = await users.findOne({'email': email});

    await db.close(); // Ensure to close the database connection

    return search?['_id'].toString();
  }

  static Future<bool> createUser(UserMongo user) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Kiểm tra xem email đã tồn tại chưa
      var existingUser = await users.findOne({
        'email': user.email,
      });
      if (existingUser != null) {
        await db.close();
        return false; // Email đã tồn tại
      }

      // Email chưa tồn tại, tạo người dùng mới
      await users.insert({
        "username": user.username,
        "email": user.email,
        "password": user.password,
        "type": user.type,
        "phone": user.phone,
        "image": user.image,
        "createdAt": DateTime.now(),
        "updateAt": DateTime.now()
      });
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating user: $e');
      return false;
    }
  }

  static Future<bool> checkGmailtoCreate(
      String? email, String? username, String? phone, String? image) async {
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
                .set('updatedAt', DateTime.now()));
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

  static Future<bool> createPost(Post post) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var posts = db.collection('Post');

      // Kiểm tra xem post đã tồn tại chưa
      var existingPost = await posts.findOne({
        'selectedType': post.selectedType,
        'selectedRoomType': post.selectedRoomType,
        'area': post.area,
        'address': post.address,
      });
      if (existingPost != null) {
        await db.close();
        return false; // Email đã tồn tại
      }

      // Email chưa tồn tại, tạo người dùng mới
      await posts.insert(post.toJson());
      await db.close();
      return true;
    } catch (e) {
      print('Error occurred while creating post: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> list_post() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        user.find({'selectedType': 'Cho thuê'}).toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_ShareRoomPost() async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        user.find({'selectedType': 'Tìm người ở ghép'}).toList();
    return search;
  }

  static Future<List<Map<String, dynamic>>> list_search_post(
      String province, String district, String commune) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    var post = db.collection('Post');

    List<Map<String, dynamic>> search;

    // When all parameters are empty, return all documents
    if (province.isEmpty && district.isEmpty && commune.isEmpty) {
      search = await post.find().toList();
      await db.close();
      return search;
    }

    // Construct the query
    var query = where;
    if (province.isNotEmpty && district.isEmpty && commune.isEmpty) {
      String searchStr = '$province';
      query = query.eq('address', RegExp(searchStr));
    }

    if (province.isNotEmpty && district.isNotEmpty && commune.isEmpty) {
      String searchStr = '$district, $province';
      query = query.eq('address', RegExp(searchStr));
    } else if (province.isNotEmpty &&
        district.isNotEmpty &&
        commune.isNotEmpty) {
      String searchStr = '$commune, $district, $province';
      query = query.eq('address', RegExp(searchStr));
    }

    // Execute the query
    search = await post.find(query).toList();

    await db.close();
    return search;
  }

  static Future<List<Map<String, dynamic>>> fillter_Post(
      String selectedType) async {
    var db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var user = db.collection('Post');
    Future<List<Map<String, dynamic>>> search =
        user.find({'selectedType': selectedType}).toList();
    return search;
  }

  static Future<bool> UpdateUser(
      String? email, String? name, String? phone) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Tìm user theo email và cập nhật các trường name và phone
      var result = await users.updateOne(
        where.eq('email', email),
        modify
            .set('username', name)
            .set('phone', phone)
            .set('updateAt', DateTime.now()),
      );

      await db.close();

      // Kiểm tra xem update có thành công hay không
      return result.isSuccess;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> UpdateUserImage(String? email, String? ImageUrl) async {
    try {
      var db = await Db.create(MONGO_URL);
      await db.open();
      var users = db.collection('User');

      // Tìm user theo email và cập nhật các trường name và phone
      var result = await users.updateOne(
        where.eq('email', email),
        modify.set('image', ImageUrl).set('updateAt', DateTime.now()),
      );

      await db.close();

      // Kiểm tra xem update có thành công hay không
      return result.isSuccess;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
}
