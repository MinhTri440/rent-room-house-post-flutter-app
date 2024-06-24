import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:post_house_rent_app/MongoDb_Connect.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> communes = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCommune;
  bool isExpanded = true;
  bool showList = false;
  late Future<List<Map<String, dynamic>>> _SearchList;
  late Future<List<Map<String, dynamic>>> _ListForFillter;
  String _selectedType = 'Cho thuê';
  String _selectedTypeRoom = 'Phòng';
  String _selectedSort = "Mới nhất"; // Khai báo _selectedType ở đây
  //double _currentSliderValue = 0;
  RangeValues _currentRangeValues = RangeValues(500, 20000);
  RangeValues _currentAreaRangeValues = RangeValues(10, 100);

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(Uri.parse(
        'https://api-tinh-thanh-git-main-toiyours-projects.vercel.app/province'));
    if (response.statusCode == 200) {
      setState(() {
        provinces = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<void> fetchDistricts(String idProvince) async {
    final response = await http.get(Uri.parse(
        'https://toinh-api-tinh-thanh.onrender.com/district?idProvince=$idProvince'));
    if (response.statusCode == 200) {
      setState(() {
        districts = json.decode(response.body);
        selectedDistrict = null;
      });
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<void> fetchCommunes(String idDistrict) async {
    final response = await http.get(Uri.parse(
        'https://api-tinh-thanh-git-main-toiyours-projects.vercel.app/commune?idDistrict=$idDistrict'));
    if (response.statusCode == 200) {
      setState(() {
        communes = json.decode(response.body);
        selectedCommune = null;
      });
    } else {
      throw Exception('Failed to load communes');
    }
  }

  void filter_treatment(
      String selectedType,
      String _selectedTypeRoom,
      String _selectedSort,
      RangeValues _currentRangeValues,
      RangeValues _currentAreaRangeValues) {
    setState(() {
      _SearchList = _ListForFillter;
      _SearchList = _SearchList.then((list) => list.where((item) {
            final bool matchesType = item['selectedType'] == selectedType;
            final bool matchesRoomType =
                item['selectedRoomType'] == _selectedTypeRoom;
            final bool matchesPrice =
                item['price'] >= _currentRangeValues.start * 1000 &&
                    item['price'] <= _currentRangeValues.end * 1000;
            final bool matchesArea =
                item['area'] >= _currentAreaRangeValues.start &&
                    item['area'] <= _currentAreaRangeValues.end;
            return matchesType &&
                matchesRoomType &&
                matchesPrice &&
                matchesArea;
          }).toList());

      // Sắp xếp danh sách dựa trên _selectedSort
      _SearchList = _SearchList.then((list) {
        if (_selectedSort == 'Mới nhất') {
          list.sort((a, b) => DateTime.parse(b['createdAt'])
              .compareTo(DateTime.parse(a['createdAt'])));
        } else if (_selectedSort == 'Giá tăng dần') {
          list.sort((a, b) => a['price'].compareTo(b['price']));
        } else if (_selectedSort == 'Giá giảm dần') {
          list.sort((a, b) => b['price'].compareTo(a['price']));
        }
        return list;
      });
    });
  }

  String _formatPrice(double value) {
    if (value < 1000) {
      return '${(value / 100).round()} trăm';
    } else {
      double millionValue = value / 1000;
      return millionValue % 1 == 0
          ? '${millionValue.toInt()} triệu'
          : '${millionValue.toStringAsFixed(1)} triệu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.tealAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(isExpanded ? 'Thu gọn' : 'Tìm kiếm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Chọn tỉnh thành',
                    style: TextStyle(color: Colors.teal)),
                value: selectedProvince,
                items: provinces.map((province) {
                  return DropdownMenuItem<String>(
                    value: province['idProvince'].toString(),
                    child: Text(province['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvince = value;
                    districts = [];
                    selectedDistrict = null;
                    communes = [];
                    selectedCommune = null;
                  });
                  fetchDistricts(value!);
                },
              ),
            ),
            SizedBox(height: 1),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Chọn quận/huyện',
                    style: TextStyle(color: Colors.teal)),
                value: selectedDistrict,
                items: selectedProvince == null
                    ? []
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Chọn quận/huyện'),
                        ),
                        ...districts.map((district) {
                          return DropdownMenuItem<String>(
                            value: district['idDistrict'].toString(),
                            child: Text(district['name']),
                          );
                        }).toList(),
                      ],
                onChanged: selectedProvince == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedDistrict = value;
                          communes = [];
                          selectedCommune = null;
                        });
                        fetchCommunes(value!);
                      },
              ),
            ),
            SizedBox(height: 1),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Chọn phường/xã',
                    style: TextStyle(color: Colors.teal)),
                value: selectedCommune,
                items: selectedDistrict == null
                    ? []
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Chọn phường/xã'),
                        ),
                        ...communes.map((commune) {
                          return DropdownMenuItem<String>(
                            value: commune['idCommune'].toString(),
                            child: Text(commune['name']),
                          );
                        }).toList(),
                      ],
                onChanged: selectedDistrict == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedCommune = value;
                        });
                      },
              ),
            ),
            SizedBox(height: 1),
            Visibility(
              visible: isExpanded,
              child: ElevatedButton(
                onPressed: () async {
                  String selectedProvinceName = selectedProvince != null
                      ? provinces.firstWhere((element) =>
                          element['idProvince'].toString() ==
                          selectedProvince)['name']
                      : '';
                  String selectedDistrictName = selectedDistrict != null
                      ? districts.firstWhere((element) =>
                          element['idDistrict'].toString() ==
                          selectedDistrict)['name']
                      : '';
                  String selectedCommuneName = selectedCommune != null
                      ? communes.firstWhere((element) =>
                          element['idCommune'].toString() ==
                          selectedCommune)['name']
                      : '';
                  print(selectedProvinceName);
                  print(selectedDistrictName);
                  print(selectedCommuneName);

                  _SearchList = MongoDatabase.list_search_post(
                      selectedProvinceName,
                      selectedDistrictName,
                      selectedCommuneName);
                  setState(() {
                    showList = true;
                    _ListForFillter = _SearchList;
                    _selectedType = "Cho thuê";
                    _selectedTypeRoom = "Phòng";
                    _selectedSort = "Mới nhất";
                    _currentRangeValues = RangeValues(500, 20000);
                    _currentAreaRangeValues = RangeValues(10, 100);
                  });
                },
                child: Text('Tìm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.teal,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (showList)
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        Column(children: [
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _SearchList,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.9 / 4,
                                  ),
                                  itemCount: snapshot.data!.length < 7
                                      ? snapshot.data!.length
                                      : 6,
                                  padding: EdgeInsets.all(8.0),
                                  itemBuilder: (context, index) {
                                    var post = snapshot.data![index];
                                    DateTime now = DateTime.now();
                                    DateTime postCreatedAt =
                                        DateTime.parse(post['createdAt']);
                                    Duration difference =
                                        now.difference(postCreatedAt);
                                    String formattedTime;
                                    if (difference.inMinutes < 60) {
                                      formattedTime =
                                          "${difference.inMinutes} phút trước";
                                    } else if (difference.inHours < 24) {
                                      formattedTime =
                                          "${difference.inHours} giờ trước";
                                    } else if (difference.inDays < 7) {
                                      formattedTime =
                                          "${difference.inDays} ngày trước";
                                    } else {
                                      formattedTime = DateFormat('dd/MM/yyyy')
                                          .format(postCreatedAt);
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
                                      },
                                      child: Card(
                                        color: Colors.teal,
                                        margin: EdgeInsets.all(8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Image.network(
                                                post['imageUrls'][0],
                                                fit: BoxFit.cover,
                                                height: 104,
                                                width: double.infinity,
                                              ),
                                              SizedBox(height: 10),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    WidgetSpan(
                                                      child: Icon(
                                                          Icons.location_on,
                                                          size: 16,
                                                          color: Colors
                                                              .tealAccent),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          " " + post['address'],
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .tealAccent),
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
                                                      child: Icon(
                                                          Icons.square_foot,
                                                          size: 16,
                                                          color: Colors
                                                              .tealAccent),
                                                    ),
                                                    TextSpan(
                                                      text: "Diện tích: " +
                                                          post['area']
                                                              .toString() +
                                                          " m2",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .tealAccent),
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
                                                      child: Icon(
                                                          Icons
                                                              .access_time_filled,
                                                          size: 16,
                                                          color: Colors
                                                              .tealAccent),
                                                    ),
                                                    TextSpan(
                                                      text: ' ' + formattedTime,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .tealAccent),
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
                                                      child: Icon(
                                                          Icons.attach_money,
                                                          size: 20,
                                                          color: Colors.white),
                                                    ),
                                                    TextSpan(
                                                      text: "Giá: " + gia,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                return Center(child: Text("Không tìm thấy"));
                              }
                            },
                          ),
                        ]),
                      ],
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
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Loại tin:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedType = 'Cho thuê';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedType ==
                                                                'Cho thuê'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Cho thuê',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedType =
                                                        'Tìm người ở ghép';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedType ==
                                                                'Tìm người ở ghép'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Tìm người ở ghép',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Loại cho thuê',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom = 'Phòng';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Phòng'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Phòng',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom =
                                                        'Căn hộ';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Căn hộ'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Căn hộ',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedTypeRoom = 'Nhà';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            _selectedTypeRoom ==
                                                                    'Nhà'
                                                                ? Colors.blue
                                                                : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Nhà',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Sắp xếp theo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort = 'Mới nhất';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Mới nhất'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Mới nhất',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort =
                                                        'Giá tăng dần';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Giá tăng dần'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Giá tăng dần',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedSort =
                                                        'Giá giảm dần';
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: _selectedSort ==
                                                                'Giá giảm dần'
                                                            ? Colors.blue
                                                            : Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Text(
                                                    'Giá giảm dần',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Giá',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        RangeSlider(
                                          values: _currentRangeValues,
                                          min: 500,
                                          max: 20000,
                                          divisions: 39,
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _currentRangeValues = RangeValues(
                                                  values.start.roundToDouble(),
                                                  values.end.roundToDouble());
                                            });
                                          },
                                        ),
                                        // Hiển thị giá trị hiện tại
                                        if (_currentRangeValues.end < 20000)
                                          Text(
                                            'Giá từ ${_formatPrice(_currentRangeValues.start)} đến ${_formatPrice(_currentRangeValues.end)}',
                                            style: TextStyle(fontSize: 14),
                                          )
                                        else
                                          Text(
                                            'Giá từ ${_formatPrice(_currentRangeValues.start)} đến ${_formatPrice(_currentRangeValues.end)}+',
                                            style: TextStyle(fontSize: 14),
                                          ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text(
                                            'Diện tích',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        RangeSlider(
                                          values: _currentAreaRangeValues,
                                          min: 10,
                                          max: 100,
                                          divisions: 9,
                                          onChanged: (RangeValues values) {
                                            setState(() {
                                              _currentAreaRangeValues =
                                                  RangeValues(
                                                      values.start
                                                          .roundToDouble(),
                                                      values.end
                                                          .roundToDouble());
                                            });
                                          },
                                        ),

                                        if (_currentAreaRangeValues.end < 100)
                                          Text(
                                            'Giá từ ${_currentAreaRangeValues.start} m2 đến ${_currentAreaRangeValues.end} m2',
                                            style: TextStyle(fontSize: 14),
                                          )
                                        else
                                          Text(
                                            'Giá từ ${_currentAreaRangeValues.start} m2 đến ${_currentAreaRangeValues.end} m2+',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            filter_treatment(
                                                _selectedType,
                                                _selectedTypeRoom,
                                                _selectedSort,
                                                _currentRangeValues,
                                                _currentAreaRangeValues);
                                            Navigator.pop(
                                                context); // Đóng bottom sheet sau khi áp dụng
                                          },
                                          child: Text('Áp dụng'),
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
