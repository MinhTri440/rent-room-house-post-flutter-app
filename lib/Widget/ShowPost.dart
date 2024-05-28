import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import 'CreatePost.dart';

class ShowPost extends StatefulWidget {
  @override
  _ShowPostState createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  late String username = 'nologin';
  late String imageUrl = 'nologin';
  late Future<List<Map<String, dynamic>>> _userList;


  @override
  void initState() {
    super.initState();
    check_if_already_login();
    _userList = MongoDatabase.list_test();
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    var checklogin = (prefs.getBool('login') ?? true);
    print(checklogin);
    if (checklogin == false) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      imageUrl = prefs.getString('image')!;
    });
    print(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            username == "nologin" || imageUrl == "noimage"
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                // Hành động khi nhấn vào nút đăng nhập
              },
              child: Text('Đăng nhập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.teal,
                // Màu nền của nút
                //color: Colors.teal, // Màu chữ của nút
              ),
            )
                : Row(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 20.0,
              ),
              SizedBox(width: 10),
              Text(
                'Xin chào, ' + username!,
                style:
                TextStyle(fontSize: 18.0, color: Colors.tealAccent),
              ),
            ]),
          ],
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(
              Icons.post_add,
              color: Colors.tealAccent,
            ),
            onPressed: () {
              // Action when the add post button is pressed
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => UpPost()),
               );
            },
          ),
        ],
      ),
      body:
      ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tin mới đăng',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action when the view more button is pressed
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(fontSize: 16.0, color: Colors.teal),
                      ),
                    )
                  ],
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _userList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.9 /
                            4, // Chỉnh tỷ lệ chiều rộng và chiều cao của mỗi mục
                      ),
                      itemCount: 6,
                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var user = snapshot.data![index];
                        return InkWell(
                          onTap: () {
                            // Action when a user card is tapped
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => DetailPage(user: user)),
                            // );
                          },
                          child: Card(
                            color: Colors.teal,
                            margin: EdgeInsets.all(8.0),
                            // Khoảng cách giữa các phần tử trong mỗi mục
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    "https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2FProduct.jfif?alt=media&token=4d9630b0-e6c4-4337-a82b-09788b779927",
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 104,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " " + user['name'],
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.square_foot,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: "Diện tích: " +
                                              user['area'].toString() +
                                              " m2",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ), // Khoảng cách giữa hình ảnh và văn bản
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.access_time_filled,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " 3 phút trước",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Người Đăng: ",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                        WidgetSpan(
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2Fuser.jpg?alt=media&token=0238633c-16cc-431e-9a18-987b26e95697'),
                                            radius: 10.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " Minh Trí",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: "Giá: " +
                                              user['age'].toString() +
                                              " triệu",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No users found"));
                  }
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phòng ở ghép',
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    TextButton(
                      onPressed: () {
                        // Action when the view more button is pressed
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(fontSize: 16.0, color: Colors.teal),
                      ),
                    )
                  ],
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _userList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.9 /
                            4, // Chỉnh tỷ lệ chiều rộng và chiều cao của mỗi mục
                      ),
                      itemCount: 6,
                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var user = snapshot.data![index];
                        return InkWell(
                          onTap: () {
                            // Action when a user card is tapped
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => DetailPage(user: user)),
                            // );
                          },
                          child: Card(
                            color: Colors.teal,
                            margin: EdgeInsets.all(8.0),
                            // Khoảng cách giữa các phần tử trong mỗi mục
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.network(
                                    "https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2FProduct.jfif?alt=media&token=4d9630b0-e6c4-4337-a82b-09788b779927",
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 104,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " " + user['name'],
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.square_foot,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: "Diện tích: " +
                                              user['area'].toString() +
                                              " m2",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ), // Khoảng cách giữa hình ảnh và văn bản

                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.access_time_filled,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " 3 phút trước",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Người Đăng: ",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                        WidgetSpan(
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2Fuser.jpg?alt=media&token=0238633c-16cc-431e-9a18-987b26e95697'),
                                            radius: 10.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " Minh Trí",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: "Gía: " +
                                              user['age'].toString() +
                                              " triệu",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("No users found"));
                  }
                },
              ),
            ],
          ),

          // Add the second column here with similar structure as above
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
