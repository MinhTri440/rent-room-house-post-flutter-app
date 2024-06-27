import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../MongoDb_Connect.dart';
import 'DetailPage.dart';

class AllSharePosts extends StatefulWidget {
  const AllSharePosts({super.key});

  @override
  State<AllSharePosts> createState() => _AllSharePostsState();
}

class _AllSharePostsState extends State<AllSharePosts> {
  late Future<List<Map<String, dynamic>>> _postShareRoomList;
  @override
  void initState() {
    super.initState();

    _postShareRoomList = MongoDatabase.list_ShareRoomPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tất cả bài đăng cho thuê'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.tealAccent,
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      itemCount: snapshot.data!.length,

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
                          gia = price.toString() + ' K';
                        } else {
                          price = price / 10;
                          gia = price.toString() + ' Triệu';
                        }

                        return InkWell(
                          onTap: () {
                            // Action when a user card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(post: post)),
                            );
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
                                  //SizedBox(height: 10),
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
                                  //SizedBox(height: 10),
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
                                  //SizedBox(height: 10),
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
                                              fontSize: 18,
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
