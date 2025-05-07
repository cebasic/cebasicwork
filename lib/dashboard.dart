import 'dart:convert';
import 'dart:io';
import 'package:cebasicwork/AltaComisionListView.dart';

import 'BuscadorListView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'VentaListView.dart';
import 'DirectorioView.dart';
import 'RastreoDeSubcodigos.dart';

class Dashboard extends StatelessWidget {
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // title: AssetImage('images/logot.png'),
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 0),
                  child: Image.asset(
                    'images/logocb.png',
                    fit: BoxFit.contain,
                    height: 27,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    "ceBasic Work",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 0.0),
                  child: GestureDetector(
                      onTap: () {},
                      child: new PopupMenuButton(
                          icon: Icon(Icons.person),
                          itemBuilder: (_) => <PopupMenuItem<String>>[
                                new PopupMenuItem<String>(
                                    child: const Text('Cerrar sesión'),
                                    value: 'logout'),
                              ],
                          onSelected: (valueselected) async {
                            _logout(context);
                          }))),
            ],
          ),
          body: Center(
            child: ListView(
              children: [
                Card(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 15),
                        Text(
                          "Buscar artículos",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    onTap: () {
                      _navigateToNextScreen(
                          context, BuscadorListView(key: UniqueKey()));
                    },
                  ),
                )),
                Card(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.point_of_sale),
                        SizedBox(width: 15),
                        Text(
                          "Mi historial de ventas",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    onTap: () {
                      _navigateToNextScreen(context, VentaListView());
                    },
                  ),
                )),
                Card(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.attach_money_outlined),
                        SizedBox(width: 15),
                        Text(
                          "Artículos con comisión alta",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    onTap: () {
                      _navigateToNextScreen(
                          context,
                          AltaComisionListView(
                            key: UniqueKey(),
                          ));
                    },
                  ),
                )),
                Card(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.store),
                        SizedBox(width: 15),
                        Text(
                          "Directorio de sucursales",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    onTap: () {
                      _navigateToNextScreen(context, DirectorioView());
                    },
                  ),
                )),
                Card(
                    child: Container(
                  padding: EdgeInsets.all(20),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.mobile_friendly),
                        SizedBox(width: 15),
                        Text(
                          "Rastreo de imei/serie",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    onTap: () {
                      _navigateToNextScreen(context, RastreoDeSubcodigos());
                    },
                  ),
                )),
                // Card(
                //     child: Container(
                //   padding: EdgeInsets.all(20),
                //   child: InkWell(
                //     child: Row(
                //       children: [
                //         Icon(Icons.fingerprint),
                //         SizedBox(width: 15),
                //         Text(
                //           "Checador",
                //           style: TextStyle(fontSize: 20),
                //         )
                //       ],
                //     ),
                //     onTap: () {
                //       _navigateToNextScreen(context, RastreoDeSubcodigos());
                //     },
                //   ),
                // )),
              ],
            ),
            // child: VentaListView()
          ),
        ));
  }

  void _navigateToNextScreen(BuildContext context, Widget pantalla) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => pantalla));
  }

  Future<void> _logout(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Navigator.pop(context);
  }
  // ListView.builder(itemCount: this.value,itemBuilder: (context, index) => Text("data")),
}
