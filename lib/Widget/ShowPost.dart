import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MongoDb_Connect.dart';
import 'CreatePost.dart';
import 'package:intl/intl.dart';

class ShowPost extends StatefulWidget {
  @override
  _ShowPostState createState() => _ShowPostState();
}

class _ShowPostState extends State<ShowPost> {
  late String username = 'nologin';
  late String imageUrl = 'nologin';
  late Future<List<Map<String, dynamic>>> _postList;
  late Future<List<Map<String, dynamic>>> _postShareRoomList;

  @override
  void initState() {
    super.initState();
    check_if_already_login();
    _postList = MongoDatabase.list_post();
    _postShareRoomList = MongoDatabase.list_ShareRoomPost();
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
      body: ListView(
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
                      'Tin phòng, căn hộ mới đăng',
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
                future: _postList,
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
                      itemCount:
                          snapshot.data!.length < 7 ? snapshot.data?.length : 6,

                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        DateTime now = DateTime.now();
                        DateTime postCreatedAt =
                            DateTime.parse(post['createdAt']);
                        Duration difference = now.difference(postCreatedAt);
                        String formattedTime;
                        if (difference.inMinutes < 60) {
                          formattedTime = "${difference.inMinutes} phút trước";
                        } else if (difference.inHours < 24) {
                          formattedTime = "${difference.inHours} giờ trước";
                        } else if (difference.inDays < 7) {
                          formattedTime = "${difference.inDays} ngày trước";
                        } else {
                          formattedTime =
                              DateFormat('dd/MM/yyyy').format(postCreatedAt);
                        }
                        var price = post['price'] / 100000;
                        String gia = '';
                        if (price < 10) {
                          price = price * 100;
                          gia = price.toString() + ' Ngàn';
                        } else {
                          price = price / 10;
                          gia = price.toString() + ' Triệu';
                        }

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
                                    post['imageUrls'][0],
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 104,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " " + post['address'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
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
                                              post['area'].toString() +
                                              " m2",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.access_time_filled,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: ' ' + formattedTime,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 25),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: "Giá: " + gia,
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
                    return Center(child: Text("No post found"));
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
                      'Tin ở ghép mới đăng',
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
                future: _postShareRoomList,
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
                      itemCount:
                          snapshot.data!.length < 7 ? snapshot.data?.length : 6,
                      padding: EdgeInsets.all(8.0),
                      // Khoảng cách giữa các mục
                      itemBuilder: (context, index) {
                        var post = snapshot.data![index];
                        DateTime now = DateTime.now();
                        DateTime postCreatedAt =
                            DateTime.parse(post['createdAt']);
                        Duration difference = now.difference(postCreatedAt);
                        String formattedTime;
                        if (difference.inMinutes < 60) {
                          formattedTime = "${difference.inMinutes} phút trước";
                        } else if (difference.inHours < 24) {
                          formattedTime = "${difference.inHours} giờ trước";
                        } else if (difference.inDays < 7) {
                          formattedTime = "${difference.inDays} ngày trước";
                        } else {
                          formattedTime =
                              DateFormat('dd/MM/yyyy').format(postCreatedAt);
                        }
                        var price = post['price'] / 100000;
                        String gia = '';
                        if (price < 10) {
                          price = price * 100;
                          gia = price.toString() + ' Ngàn';
                        } else {
                          price = price / 10;
                          gia = price.toString() + ' Triệu';
                        }

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
                                    post['imageUrls'][0],
                                    fit: BoxFit.cover,
                                    // Đảm bảo hình ảnh vừa với kích thước của card
                                    height: 104,
                                    // Điều chỉnh chiều cao của hình ảnh
                                    width: double
                                        .infinity, // Đảm bảo hình ảnh rộng bằng card
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.location_on,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: " " + post['address'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
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
                                              post['area'].toString() +
                                              " m2",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.access_time_filled,
                                              size: 16,
                                              color: Colors.tealAccent),
                                        ),
                                        TextSpan(
                                          text: ' ' + formattedTime,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 25),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(Icons.attach_money,
                                              size: 20, color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: "Giá: " + gia,
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
                    return Center(child: Text("No post found"));
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
