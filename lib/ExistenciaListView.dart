import 'dart:convert';
// import 'BuscadorListView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Existencia {
  final String clave;
  final String descripcion;
  final String existencia;
  final String precio;
  final String almacen;

  // flutter 2.8.0
  // Existencia(
  //     {this.clave,
  //     this.descripcion,
  //     this.existencia,
  //     this.precio,
  //     this.almacen});
  // flutter 3.0.0
  Existencia(
      {required this.clave,
      required this.descripcion,
      required this.existencia,
      required this.precio,
      required this.almacen});

  factory Existencia.fromJson(Map<String, dynamic> json) {
    return Existencia(
      clave: json['Clave'].toString(),
      descripcion: json['Descripcion'],
      existencia: json['Existencia'].toString(),
      precio: json['Precio'].toString(),
      almacen: json['cAlmacenDescripcion'],
    );
  }
}

class ExistenciaScreen extends StatelessWidget {
  String clave, title;
  // flutter 2.8.0
  // ExistenciaScreen({Key key, this.clave, this.title}) : super(key: key);
  // flutter 3.0.0
  ExistenciaScreen({Key? key, required this.clave, required this.title})
      : super(key: key);
  // List<dynamic> _articulos = [];

  Widget build(BuildContext context) {
    return ExistenciaListView(
      clave: this.clave,
      title: this.title,
    );
  }
}

class ExistenciaListView extends StatefulWidget {
  String clave, title;

  ExistenciaListView({Key? key, required this.clave, required this.title})
      : super(key: key);

  @override
  _ExistenciaListViewState createState() =>
      _ExistenciaListViewState(this.clave, this.title);
}

class _ExistenciaListViewState extends State<ExistenciaListView> {
  String _clave = "", _title = "";

  _ExistenciaListViewState(String clave, String title) {
    _clave = clave;
    _title = title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _ListView(),
    );
  }

  var _articulos = [];

  _onRefresh() async {
    _fetchArticulos(_clave);
    _refreshController.refreshCompleted();
  }

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  Scaffold _ListView() {
    return Scaffold(
        appBar: AppBar(title: Text(_title, style: TextStyle(fontSize: 15))),
        body: Column(
          children: [
            Expanded(
                child: SmartRefresher(
              header: CustomHeader(
                builder: (context, mode) {
                  Widget body = Text("Jala para recargar ⬇️");
                  if (mode == RefreshStatus.idle) {
                    body = Text("Jala para recargar ⬇️");
                  } else if (mode == RefreshStatus.refreshing) {
                    body = Text("Cargando...");
                  } else if (mode == RefreshStatus.canRefresh) {
                    body = Text("Suelta para recargar ⬆️");
                  } else if (mode == RefreshStatus.completed) {
                    body = Text("Listo ✅");
                  }
                  return Container(
                    height: 60.0,
                    child: Center(
                      child: body,
                    ),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ListView.builder(
                  itemCount: _articulos.length,
                  itemBuilder: (context, index) {
                    if (false) {
                    } else {
                      return _tile(
                        _articulos[index]['Clave'].toString(),
                        _articulos[index]['cAlmacenDescripcion'],
                        _articulos[index]['Existencia'].toString(),
                        _articulos[index]['Precio'].toString(),
                      );
                    }
                  }),
            ))
          ],
        ));
  }

  Future<List<Existencia>> _fetchArticulos(String params) async {
    print("params: " + params);
    String user_id = await getUserSF();
    final jobsListAPIUrl =
        'https://cebasicapi-node-caab21788dab.herokuapp.com/api/user/' +
            user_id +
            '/existenciadetalle/' +
            params;
    print(jobsListAPIUrl);
    final response = await http.get(Uri.parse(jobsListAPIUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      // jsonResponse.insert(0, jsonResponse[0]);
      // print(jsonResponse);
      setState(() {
        _articulos = jsonResponse;
      });
      // print(jsonResponse[0]['Clave']);
      return jsonResponse
          .map<Existencia>((articulo) => new Existencia.fromJson(articulo))
          .toList();
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  getUserSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString("user");
    return stringValue;
  }

  var rng = new Random();
  Card _tile(String clave, String almacen, String existencia, String precio) =>
      Card(
          child: InkWell(
        onTap: () {
          // _navigateToNextScreen(context, BuscadorListView());
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [Text("Clave"), Text(clave)],
              ),
              Container(
                width: 20,
              ),
              Expanded(
                  child: Container(
                child: Text(
                  almacen,
                  overflow: TextOverflow.fade,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "\$" + double.parse(precio).round().toString(),
                    // rng.nextInt(100).toString(),
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Text(
                    "Extistencia: " +
                        int.parse(double.parse(existencia).round().toString())
                            .toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )
            ],
          ),
        ),
      ));
}
