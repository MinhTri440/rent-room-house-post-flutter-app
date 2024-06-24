import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:post_house_rent_app/Widget/InformationAcount.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart'; // Đảm bảo rằng bạn đã tạo trang đăng nhập

class AccountManager extends StatefulWidget {
  @override
  _AccountManagerState createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  String username = 'nologin';
  String imageUrl = 'nologin';
  String typeAccount = '';

  @override
  void initState() {
    super.initState();
    check_if_already_login();
  }

  void check_if_already_login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      imageUrl =
          prefs.getString('image') ?? 'https://example.com/default-avatar.png';
      typeAccount = prefs.getString('type')!;
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    await prefs.remove('username');
    await prefs.remove('image');
    await prefs.remove('type');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _showInformationAccount() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformationAccount()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài khoản'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.tealAccent,
      ),
      body: Center(
        child: username == 'nologin' && imageUrl == 'nologin'
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Yêu cầu đăng nhập để sử dụng chức năng này.',
                    style: TextStyle(color: Colors.teal),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Đăng nhập'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.teal,
// Màu chữ của nút
                    ),
                  ),
                ],
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 40.0,
                ),
                SizedBox(height: 10),
                Text(
                  '$username',
                  style: TextStyle(fontSize: 28.0, color: Colors.teal),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  child: Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.teal,
                    // Màu chữ của nút
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: typeAccount == 'system',
                  child: ElevatedButton(
                    onPressed: _showInformationAccount,
                    child: Text('Thông tin tài khoản'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.teal,
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}
