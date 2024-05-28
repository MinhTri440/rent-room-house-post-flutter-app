import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class UpPost extends StatefulWidget {
  @override
  _UpPostState createState() => _UpPostState();
}

class _UpPostState extends State<UpPost> {
  void initState() {
    super.initState();
    fetchProvinces();
  }

  //THông tin
  int _currentStep = 0;
  String _selectedType = 'Cho thuê';
  String _selectedRoomType = 'Phòng';
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Map<String, dynamic>> amenities = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'WC riêng', 'icon': Icons.bathtub},
    {'name': 'Giữ xe', 'icon': Icons.local_parking},
    {'name': 'Tự do', 'icon': Icons.accessibility},
    {'name': 'Bếp', 'icon': Icons.kitchen},
    {'name': 'Điều hòa', 'icon': Icons.ac_unit},
    {'name': 'Tủ lạnh', 'icon': Icons.kitchen_outlined},
    {'name': 'Máy giặc', 'icon': Icons.local_laundry_service},
    {'name': 'Nội thất', 'icon': Icons.weekend},
  ];
  List<bool> selectedAmenities = List.generate(9, (index) => false);
  List<String> selectedAmenitiesNames = [];

  //Dia chi
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedCommune;
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> communes = [];
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  String? selectedProvinceName;
  String? selectedDistrictName;
  String? selectedCommuneName;

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

// Hinh anh
  List<File?> _selectedImages = []; // Danh sách chứa các hình ảnh đã được chọn
  final picker = ImagePicker();
  bool _isImagePickerActive = false;
  Future<void> pickImage({int? replaceIndex}) async {
    if (!_isImagePickerActive &&
        (replaceIndex != null || _selectedImages.length < 6)) {
      _isImagePickerActive =
          true; // Đặt trạng thái trình chọn hình ảnh thành đang hoạt động
      try {
        final pickerFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
        );
        if (pickerFile != null) {
          setState(() {
            if (replaceIndex != null) {
              _selectedImages[replaceIndex] =
                  File(pickerFile.path); // Thay thế hình ảnh
            } else {
              _selectedImages
                  .add(File(pickerFile.path)); // Thêm hình ảnh vào danh sách
            }
          });
        } else {
          print("No image picked");
        }
      } catch (e) {
        print("Error picking image: $e");
      } finally {
        _isImagePickerActive =
            false; // Đặt trạng thái trình chọn hình ảnh thành không hoạt động
      }
    } else {
      if (_selectedImages.length >= 6) {
        print("Maximum number of images reached");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Stepper Demo'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            print(_selectedType);
            print(_selectedRoomType);
            print(_priceController.text);
            print(_areaController.text);
            print(selectedAmenitiesNames);
            // Kiểm tra xem giá phòng và diện tích đã được nhập chưa
            if (_areaController.text.isEmpty || _priceController.text.isEmpty) {
              // Thông báo yêu cầu người dùng nhập giá phòng và diện tích
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Vui lòng nhập giá phòng và diện tích.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
          }
          if (_currentStep == 1) {
            print(selectedProvinceName);
            print(selectedDistrictName);
            print(selectedCommuneName);
            print(_streetController.text);
            print(_houseController.text);
            if (selectedProvinceName == null ||
                selectedDistrictName == null ||
                selectedCommuneName == null ||
                _streetController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text(
                        'Vui lòng chọn tỉnh, huyện, xã , hẻm, tên đường nơi cho thuê.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
          }
          if (_currentStep == 2) {
            if (_selectedImages.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Vui lòng chọn hình ảnh cho bài đăng '),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  );
                },
              );
              return;
            }
          }
          // Nếu không có lỗi, tiếp tục tới bước tiếp theo
          if (_currentStep < _getSteps().length - 1) {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: _getSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
          return Row(
            children: <Widget>[
              TextButton(
                onPressed: controls.onStepContinue,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: controls.onStepCancel,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Xac nhan
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zalophoneController = TextEditingController();
  final TextEditingController _facebooklinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Step> _getSteps() {
    return [
      Step(
        title: Text(
          'Thông tin',
          style: TextStyle(fontSize: 8),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Loại tin:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedType == 'Cho thuê'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
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
                        _selectedType = 'Tìm người ở ghép';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedType == 'Tìm người ở ghép'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Loại phòng:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRoomType = 'Phòng';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Phòng'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
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
                        _selectedRoomType = 'Căn hộ';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Căn hộ'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
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
                        _selectedRoomType = 'Nhà';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _selectedRoomType == 'Nhà'
                                ? Colors.blue
                                : Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
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
            SizedBox(height: 8),
            Text(
              'Giá phòng (VND):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập giá phòng',
                border: OutlineInputBorder(),
              ),
              controller: _priceController,
              onChanged: (value) {
                _priceController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Diện tích (m2):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập diện tích',
                border: OutlineInputBorder(),
              ),
              controller: _areaController,
              onChanged: (value) {
                _areaController.text = value;
              },
            ),
            SizedBox(height: 8),
            Text(
              'Tiện ích phòng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                amenities.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAmenities[index] = !selectedAmenities[index];
                      // Nếu tiện ích được chọn, thêm tên của nó vào mảng
                      if (selectedAmenities[index]) {
                        selectedAmenitiesNames.add(amenities[index]['name']);
                      } else {
                        // Nếu bỏ chọn, loại bỏ tên của tiện ích khỏi mảng
                        selectedAmenitiesNames.remove(amenities[index]['name']);
                      }
                    });
                  },
                  child: Chip(
                    label: Text(amenities[index]['name']),
                    avatar: Icon(
                      amenities[index]['icon'],
                      color: selectedAmenities[index]
                          ? Colors.green
                          : Colors.black,
                    ),
                    backgroundColor:
                        selectedAmenities[index] ? Colors.grey[300] : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Địa chỉ', style: TextStyle(fontSize: 8)),
        content: Column(
          children: <Widget>[
            SizedBox(height: 20),
            // AnimatedContainer và DropdownButton cho tỉnh/thành phố
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
                hint: Text('Chọn tỉnh/thành phố',
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
                    selectedProvinceName = selectedProvince != null
                        ? provinces.firstWhere((element) =>
                            element['idProvince'].toString() ==
                            selectedProvince)['name']
                        : null;
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
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
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
                          selectedDistrictName = selectedDistrict != null
                              ? districts.firstWhere((element) =>
                                  element['idDistrict'].toString() ==
                                  selectedDistrict)['name']
                              : null;
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
              height: 50.0,
              width: 400,
              // Kích thước tùy thuộc vào biến isExpanded
              child: DropdownButton<String>(
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
                          selectedCommuneName = selectedCommune != null
                              ? communes.firstWhere((element) =>
                                  element['idCommune'].toString() ==
                                  selectedCommune)['name']
                              : null;
                        });
                      },
              ),
            ),

            SizedBox(height: 1),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'hẻm và tên đường (có thẻ điền 1 trong 2)  ',
                border: OutlineInputBorder(),
              ),
              controller: _streetController,
              onChanged: (value) {
                _streetController.text = value;
              },
            ),
            SizedBox(height: 1),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Số nhà(nếu có)',
                border: OutlineInputBorder(),
              ),
              controller: _houseController,
              onChanged: (value) {
                _houseController.text = value;
              },
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Hình ảnh', style: TextStyle(fontSize: 8)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Chọn hình ảnh từ thiết bị của bạn tối đa 6 hình.'),
            SizedBox(height: 10),
            Container(
              height: 220, // Có thể cần chỉnh chiều cao tùy theo nhu cầu
              width: double.infinity, // Sử dụng chiều rộng toàn màn hình
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Số lượng cột là 3
                  crossAxisSpacing: 4, // Khoảng cách giữa các cột
                  mainAxisSpacing: 4, // Khoảng cách giữa các hàng
                  childAspectRatio: 1, // Tỷ lệ khung hình của các item
                ),
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    // Chỉ cho phép thêm mới nếu số lượng hình ảnh chưa đạt tối đa
                    return InkWell(
                      onTap: () {
                        if (_selectedImages.length < 6) {
                          pickImage();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Icon(Icons.add),
                      ),
                    );
                  } else {
                    // Thực hiện thay thế hình ảnh khi nhấn vào hình ảnh đã chọn
                    return InkWell(
                      onTap: () {
                        pickImage(replaceIndex: index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.file(
                          _selectedImages[index]!.absolute,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                });
              },
              icon: Icon(Icons.refresh),
              label: Text("Chọn lại"),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Xác nhận', style: TextStyle(fontSize: 8)),
        content: Column(
          children: <Widget>[
            SizedBox(height: 8),
            Text(
              'Tiêu đề:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập tiêu đề',
                border: OutlineInputBorder(),
              ),
              controller: _topicController,
              onChanged: (value) {
                _priceController.text = value;
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
    ];
  }
}
