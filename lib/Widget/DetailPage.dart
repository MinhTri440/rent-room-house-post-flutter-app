import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

List<Map<String, dynamic>> amenities = [
  {'name': 'Wifi', 'icon': Icons.wifi},
  {'name': 'WC riêng', 'icon': Icons.bathtub},
  {'name': 'Giữ xe', 'icon': Icons.local_parking},
  {'name': 'Tự do', 'icon': Icons.accessibility},
  {'name': 'Bếp', 'icon': Icons.kitchen},
  {'name': 'Điều hòa', 'icon': Icons.ac_unit},
  {'name': 'Tủ lạnh', 'icon': Icons.kitchen_outlined},
  {'name': 'Máy giặt', 'icon': Icons.local_laundry_service},
  {'name': 'Nội thất', 'icon': Icons.weekend},
];

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  DetailPage({required this.post});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  PageController _pageController = PageController();
  VideoPlayerController? _videoPlayerController;
  int _currentPage = 0;
  late List<Map<String, dynamic>> selectedAmenities;
  // Danh sách tiện ích

  // Lọc tiện ích đã chọn

  @override
  void initState() {
    super.initState();
    if (widget.post['videoURL'] != null) {
      _videoPlayerController =
          VideoPlayerController.network(widget.post['videoURL'])
            ..initialize().then((_) {
              setState(() {});
            });
    }
    selectedAmenities = amenities.where((amenity) {
      return widget.post['selectedAmenitiesNames'].contains(amenity['name']);
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });

    if (_videoPlayerController != null) {
      if (index == widget.post['imageUrls'].length) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController?.pause();
      }
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < widget.post['imageUrls'].length) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime postCreatedAt = DateTime.parse(widget.post['createdAt']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(postCreatedAt);
    var price = widget.post['price'] / 100000;
    String gia = '';
    if (price < 10) {
      price = price * 100;
      gia = price.toString() + ' K';
    } else {
      price = price / 10;
      gia = price.toString() + ' Triệu';
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Chi Tiết Bài Viết'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post['imageUrls'] != null &&
                        widget.post['imageUrls'].isNotEmpty)
                      SizedBox(
                        height: 300.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemCount: widget.post['imageUrls'].length +
                                  (widget.post['videoURL'] != null ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < widget.post['imageUrls'].length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        widget.post['imageUrls'][index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  );
                                } else {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: _videoPlayerController!
                                            .value.isInitialized
                                        ? AspectRatio(
                                            aspectRatio: _videoPlayerController!
                                                .value.aspectRatio,
                                            child: VideoPlayer(
                                                _videoPlayerController!),
                                          )
                                        : Center(
                                            child: CircularProgressIndicator()),
                                  );
                                }
                              },
                            ),
                            if (_currentPage > 0)
                              Positioned(
                                left: 10,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      color: Colors.black.withOpacity(0.5)),
                                  onPressed: _goToPreviousPage,
                                ),
                              ),
                            if (_currentPage < widget.post['imageUrls'].length)
                              Positioned(
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.black.withOpacity(0.5)),
                                  onPressed: _goToNextPage,
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    Text(
                      "${widget.post['topic']}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Địa chỉ: ${widget.post['address']}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Điện thoại: ${widget.post['phone']}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Diện tích: ${widget.post['area']} m²",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Giá: $gia",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Ngày đăng: $formattedDate",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    if (widget.post['description'] != null)
                      Text(
                        "Mô tả:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    if (widget.post['description'] != null)
                      SizedBox(height: 10),
                    if (widget.post['description'] != null)
                      Text(
                        widget.post['description'],
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 20),
                    if (selectedAmenities.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tiện ích:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 10.0,
                            children: selectedAmenities.map((amenity) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(amenity['icon'], size: 30),
                                  SizedBox(height: 4),
                                  Text(amenity['name'],
                                      style: TextStyle(fontSize: 14)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Loại tin:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Navigator.pop(
                                    //     context); // Đóng bottom sheet sau khi áp dụng_makePhoneCall(
                                    final Uri url = Uri(
                                        scheme: 'tel',
                                        path: "${widget.post['phone']}");
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      print('cannot lauch this url');
                                    }
                                  },
                                  child: Text('Gọi'),
                                ),
                                if (widget.post['zalophone'] != "")
                                  ElevatedButton(
                                    onPressed: () async {
                                      final url =
                                          "https://zalo.me/${widget.post['zalophone']}";
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Text('Liên hệ zalo'),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: Icon(Icons.filter_list),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ));
  }
}
