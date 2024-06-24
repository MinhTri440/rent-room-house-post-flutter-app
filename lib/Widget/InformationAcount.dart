import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformationAccount extends StatefulWidget {
  const InformationAccount({super.key});

  @override
  State<InformationAccount> createState() => _InformationAccountState();
}

class _InformationAccountState extends State<InformationAccount> {
  // Khởi tạo các controller cho TextField
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String username = 'nologin';
  String imageUrl = 'https://example.com/default-avatar.png';
  String email = 'noemail';
  String phone = 'phone';
  bool _isLoading = true;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('username') ?? 'User';
      imageUrl =
          prefs.getString('image') ?? 'https://example.com/default-avatar.png';
      _emailController.text = prefs.getString('email') ?? 'abc@gmail.com';
    });
    Map<String, dynamic>? search =
        await MongoDatabase.getUser(prefs.getString('email'));
    setState(() {
      _phoneController.text = search?['phone'];
      _isLoading = false; // Đánh dấu đã tải xong dữ liệu
    });
  }

  bool isPhoneNumber(String input) {
    // Sử dụng biểu thức chính quy để kiểm tra xem chuỗi có phải là số điện thoại hay không
    // Biểu thức này sẽ phù hợp với các số điện thoại theo định dạng quốc tế, ví dụ: +12 3456 7890
    final RegExp phoneRegex = RegExp(r'^(?:\+?84|0)(?:\d{9,10})$');
    return phoneRegex.hasMatch(input);
  }

  void _SaveInformation() {
    if (_nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Vui lòng nhập tên người dùng '),
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
    if (_emailController.text.isEmpty ||
        !EmailValidator.validate(_emailController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Vui lòng nhập email và đúng định dạng email '),
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

    if (_phoneController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Vui lòng nhập số điện thoại '),
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

    if (!isPhoneNumber(_phoneController.text)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Vui lòng nhập đúng định dạng số điện thoại '),
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Dọn dẹp các controller khi không còn sử dụng để tránh rò rỉ bộ nhớ
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin tài khoản"),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Hiển thị tiến trình tải dữ liệu
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _SaveInformation();
                      // Thực hiện lưu các thông tin đã sửa đổi
                      print("Đã lưu thông tin");
                    },
                    child: Text('Cập nhật avatar'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tên:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Số điện thoại:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _SaveInformation();
                      // Thực hiện lưu các thông tin đã sửa đổi
                      print("Đã lưu thông tin");
                    },
                    child: Text('Lưu Thông Tin'),
                  ),
                ],
              ),
            ),
    );
  }
}
