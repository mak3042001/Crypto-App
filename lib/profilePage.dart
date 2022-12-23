import 'package:crypto_currency_app/AppTheme.dart';
import 'package:crypto_currency_app/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController age = TextEditingController();

  Future<void> saveDetails({required String key, required String value}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
    print("done:${name.text}");
    print("done:${email.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile Update",
        ),
      ),
      body: Column(
        children: [
          textFieldValue(name: "Name", controller: name, isAge: false),
          textFieldValue(name: "Email", controller: email, isAge: false),
          textFieldValue(name: "Age", controller: age, isAge: true),
          ElevatedButton(
            onPressed: () {
              saveDetails(key: "name", value: name.text);
              saveDetails(key: "email", value: email.text);
              saveDetails(key: "age", value: age.text);
              Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
            },
            child: const Text("Save Details"),
          )
        ],
      ),
    );
  }

  Widget textFieldValue(
      {required String name,
      required TextEditingController controller,
      required bool isAge}) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        keyboardType: isAge ? TextInputType.number : null,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.isDarkModeEnable ? Colors.white:Colors.grey)
          ),
          hintText: name,
          hintStyle: TextStyle(
            color: AppTheme.isDarkModeEnable ? Colors.white:null,
          )
        ),
      ),
    );
  }
}
