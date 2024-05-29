import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AccountManager.dart';
import 'HomeScreen.dart';

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
  bool isExpanded = true; // Biến để kiểm soát việc mở rộng và thu gọn
  bool showList = false;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    final response = await http
        .get(Uri.parse('https://toinh-api-tinh-thanh.onrender.com/province'));
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
        selectedDistrict =
            null; // Reset selected district when province changes
      });
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<void> fetchCommunes(String idDistrict) async {
    final response = await http.get(Uri.parse(
        'https://toinh-api-tinh-thanh.onrender.com/commune?idDistrict=$idDistrict'));
    if (response.statusCode == 200) {
      setState(() {
        communes = json.decode(response.body);
        selectedCommune = null; // Reset selected commune when district changes
      });
    } else {
      throw Exception('Failed to load communes');
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
            // Nút để mở rộng hoặc thu gọn
            ElevatedButton(
              onPressed: () {
                // Khi nút được nhấn, đảo ngược giá trị của biến isExpanded
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
            // AnimatedContainer và DropdownButton cho tỉnh/thành phố
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              // Kích thước tùy thuộc vào biến isExpanded
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
            // AnimatedContainer và DropdownButton cho quận/huyện
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              // Kích thước tùy thuộc vào biến isExpanded
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
            // AnimatedContainer và DropdownButton cho phường/xã
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: isExpanded ? 50.0 : 0.0,
              // Kích thước tùy thuộc vào biến isExpanded
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
              visible: isExpanded, // Ẩn nút khi isExpanded là false
              child:
              ElevatedButton(
                onPressed: () {
                  String selectedProvinceName = selectedProvince != null
                      ? provinces.firstWhere((element) =>
                  element['idProvince'].toString() ==
                      selectedProvince)['name']
                      : 'Chưa chọn';
                  String selectedDistrictName = selectedDistrict != null
                      ? districts.firstWhere((element) =>
                  element['idDistrict'].toString() ==
                      selectedDistrict)['name']
                      : 'Chưa chọn';
                  String selectedCommuneName = selectedCommune != null
                      ? communes.firstWhere((element) =>
                  element['idCommune'].toString() ==
                      selectedCommune)['name']
                      : 'Chưa chọn';
                  setState(() {
                    showList=true;
                  });
                  print('Tỉnh/Thành: $selectedProvinceName');
                  print('Quận/Huyện: $selectedDistrictName');
                  print('Phường/Xã: $selectedCommuneName');
                  // Xử lý khi nút được nhấn
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.teal,
                ),
              ),
            ),


            SizedBox(height: 20),
            // ListView hiển thị khi các DropdownButton được mở rộng
            if (showList)
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // Số lượng item trong ListView
                  itemBuilder: (context, index) {
                    // Tạo các phần tử của ListView
                    return ListTile(
                      title: Text('Item $index'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );

  }
}
