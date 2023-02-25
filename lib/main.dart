import 'dart:convert';
import 'dart:ui';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.deepBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        darkIsTrueBlack: true,
      ),
      // themeMode: ThemeMode.dark,

      // theme: ThemeData(
      //   primarySwatch: Colors.green,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      // ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title = "";
  MyHomePage({Key? key, required this.title}) : super(key: key);
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  Widget build(BuildContext context) {
    getStringValuesSF("user"); //checa si hay user guardado
    //    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        padding: new EdgeInsets.all(60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: new EdgeInsets.all(0),
              child: Image(image: AssetImage('images/logot.png')),
            ),
            SizedBox(height: 20),
            TextField(
              controller: userController,
              decoration: InputDecoration(
                hintText: 'Usuario',
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: true,
              // keyboardType: Text,
              controller: passController,
              decoration: InputDecoration(
                hintText: 'Contraseña',
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Usa tu usuario y contraseña del sistema de punto de venta',
              style: TextStyle(fontSize: 10),
            ),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                _loginButtonClickHandler();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              // padding: EdgeInsets.all(15),
              child: Container(
                padding: EdgeInsets.all(15),
                child: Text('Iniciar sesión', style: TextStyle(fontSize: 20)),
              ),
              // color: Colors.lightGreen,
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(10.0),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginButtonClickHandler() {
    var username = userController.text;
    var password = passController.text;
    if (username.length == 0 || password.length == 0) {
      _showDialog("Usuario y contraseña obligatorios");
    } else {
      login(username, password).then((response) {
        Navigator.pop(context);
      }).catchError((e) {});
    }
  }

  login(u, p) async {
    _showDialog("Iniciando sesión ...");

    String urla = 'http://cbserver.ddnsfree.com:8000/auth/' + u + '/' + p;
    print(urla);
    final response = await http.get(urla);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      if (responseJson['results'] == true) {
        Navigator.pop(context);
        addStringToSF("user", u);
        if (responseJson['isadmin'] == 1) {
          addStringToSF("admin", "1");
        } else {
          addStringToSF("admin", "0");
        }
        Future<dynamic> responseuser = getStringValuesSF("user");
        _navigateToNextScreen(context);
      } else {
        Navigator.pop(context);
        passController.clear();
        _showDialog("Contraseña o usuario incorrectos");
      }
      return responseJson['results'];
    } else {
      _showDialog("Error de conexión");
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    // print("NAVIGATE DASHBOARD");
    passController.clear();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Dashboard()));
  }

  void _showDialog(message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(message),
          // actions: <Widget>[
          //   // usually buttons at the bottom of the dialog
          //   new FlatButton(
          //     child: new Text("Cerrar"),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }

  addStringToSF(id, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, value);
  }

  getStringValuesSF(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString(id);
    if (stringValue != null) {
      _navigateToNextScreen(context);
    } else {
      print("Sin user guardado");
    }
    return stringValue;
  }
}

class AuthModel {
  int userId = 0;
  int pass = 0;
  AuthModel({required this.userId, required this.pass});
  AuthModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    pass = json['id'];
  }
}
