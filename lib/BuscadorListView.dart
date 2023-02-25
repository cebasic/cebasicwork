import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'ExistenciaListView.dart';

class Articulo {
  final String clave;
  final String descripcion;
  final String existencia;
  final String precio;
  final String fam;

  // flutter 2.8.0
  // Articulo(
  //     {this.clave, this.descripcion, this.existencia, this.precio, this.fam});
  // flutter 3.0.0
  Articulo(
      {required this.clave,
      required this.descripcion,
      required this.existencia,
      required this.precio,
      required this.fam});

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
        clave: json['Clave'],
        descripcion: json['Descripcion'],
        existencia: json['Existencia'],
        precio: json['Precio'],
        fam: json['fam']);
  }
}

class BuscadorListView extends StatefulWidget {
  BuscadorListView({Key? key}) : super(key: key);
  _BuscadorListViewState createState() => _BuscadorListViewState();
}

class _BuscadorListViewState extends State<BuscadorListView> {
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  String server = "http://cbserver.ddnsfree.com:8000";
  List<dynamic> _articulos = [];
  String? _ventatotal, _comisiontotal, _name;
  bool userisadmin = false;
  Widget build(BuildContext context) {
    return _buscadorListView(_articulos);
  }

  _onRefresh() async {
    // _refreshController.refreshCompleted();
  }
  bool _checkedValue = true;
  String _selectedValue = "Teléfonos y accesorios";
  TextEditingController tfcontroller = TextEditingController();

  Scaffold _buscadorListView(_ventas) {
    // tfcontroller.addListener(() {
    //   print("probando");
    String _text = "";
    // getIsAdmin();
    // });
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            textInputAction: TextInputAction.search,
            autofocus: true,
            style: TextStyle(fontSize: 20.0, color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Buscar ',
              contentPadding:
                  const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
            ),
            onEditingComplete: () {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              if (_text.length > 1) {
                _showLoading("Buscando");
                // print(_text);
                _fetchArticulos(_text);
              } else {
                _showDialog("Para buscar, escribe más de 1 caracter");
              }
            },
            onChanged: (text) {
              _text = text;
            },
          ),
          //     TextField(
          //   // border: OutlineInputBorder(),
          //   textInputAction: TextInputAction.search,
          //   autofocus: true,
          //   autocorrect: true,
          //   // onChanged: _fetchData(),
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       hintText: 'Escribe aquí para buscar',
          //       suffix: Icon(Icons.search)),
          //   // controller: tfcontroller,
          //   onEditingComplete: () {
          //     if (_text.length > 3) {
          //       print(_text);
          //       _fetchArticulos(_text);
          //     }
          //   },

          //   onChanged: (text) {
          //     _text = text;
          //   },
          // )
        ),
        body: Column(
          children: [
            // Container(
            //   color: Colors.white38,
            //   padding: EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
            //   child: Container(
            //     height: 30,
            //     child: Row(
            //       children: [
            //         DropdownButton<String>(
            //           hint: Text(_selectedValue),
            //           items: <String>[
            //             'Celulares y accesorios',
            //             'Celulares',
            //             'Accesorios'
            //           ].map((String value) {
            //             return new DropdownMenuItem<String>(
            //               value: value,
            //               child: new Text(value),
            //             );
            //           }).toList(),
            //           onChanged: (selected) {
            //             this.setState(() {
            //               _selectedValue = selected;
            //               print(_selectedValue);
            //             });
            //           },
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //         Text(
            //           "Descartar 0",
            //           // style: TextStyle(fontSize: 18),
            //         ),
            //         Checkbox(
            //           value: _checkedValue,
            //           onChanged: (newValue) {
            //             setState(() {
            //               _checkedValue = newValue;
            //               // print(_checkedValue);
            //             });
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
                child: SmartRefresher(
              header: CustomHeader(
                builder: (context, mode) {
                  Widget body = SizedBox(height: 0);

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
                    if (userisadmin) {
                      return _tile(
                          _articulos[index]['Clave'],
                          _articulos[index]['Descripcion'],
                          _articulos[index]['Existencia'],
                          _articulos[index]['Precio'],
                          _articulos[index]['nComision'],
                          _articulos[index]['costo'],
                          true,
                          _articulos[index]['fam'] != "A");
                    } else {
                      return _tile(
                          _articulos[index]['Clave'],
                          _articulos[index]['Descripcion'],
                          _articulos[index]['Existencia'],
                          _articulos[index]['Precio'],
                          _articulos[index]['nComision'],
                          _articulos[index]['costo'],
                          false,
                          _articulos[index]['fam'] != "A");
                    }
                  }),
            ))
          ],
        ));
  }

  getUserSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString("user");
    return stringValue;
  }

  getIsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString("admin");
    return stringValue == "1";
  }

  addStringToSF(id, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, value);
  }

  getStringValuesSF(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString(id);
    return stringValue;
  }

  void filtraTipo() {}

  void _showLoading(message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Row(
            children: [
              new Text("Cargando"),
              SizedBox(
                width: 20,
              ),
              CircularProgressIndicator(),
            ],
          ),
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

  void _showDialog(message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              child: new Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Articulo>> _fetchArticulos(
    String params,
  ) async {
    bool userisadminSaved = await getIsAdmin();
    // print("params: " + params);
    String user_id = await getUserSF();
    final jobsListAPIUrl =
        server + '/api/searchparam/user/' + user_id + '/' + params;
    final response = await http.get(jobsListAPIUrl);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      // jsonResponse.insert(0, jsonResponse[0]);
      Navigator.pop(context);
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      setState(() {
        _articulos = jsonResponse;
        userisadmin = userisadminSaved;
      });

      // setState(() {
      //   _articulos = jsonResponse;
      // });
      _refreshController.refreshCompleted();
      // print(jsonResponse[0]['Clave']);
      return jsonResponse
          .map<Articulo>((articulo) => new Articulo.fromJson(articulo))
          .toList();
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  void _navigateToNextScreen(BuildContext context, Widget pantalla) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => pantalla));
  }

  var rng = new Random();

  Card _tile(String clave, String descripcion, String existencia, String precio,
          String comision, String costo, bool isadmin, bool showcomision) =>
      Card(
          child: InkWell(
        onTap: () {
          print("touched: " + clave);
          _navigateToNextScreen(
              context, ExistenciaScreen(clave: clave, title: descripcion));
        },
        child: Container(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Row(
            children: [
              Column(
                children: [
                  Text("Clave"),
                  Text(clave, style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
              Container(
                width: 10,
              ),
              Flexible(
                  child: Container(
                child: Column(
                  children: [
                    Text(
                      '${descripcion[0].toUpperCase()}${descripcion.toUpperCase().substring(1)}',
                      overflow: TextOverflow.fade,
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Text(
                          "\$" +
                              int.parse(double.parse(precio).round().toString())
                                  .toString(),
                          // rng.nextInt(100).toString(),
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        SizedBox(
                          width: userisadmin ? 10 : 0,
                        ),
                        userisadmin
                            ? Text(
                                "\$" +
                                    int.parse(double.parse(costo)
                                            .round()
                                            .toString())
                                        .toString(),
                                // rng.nextInt(100).toString(),
                                style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  ],
                ),
              )),
              Column(
                children: [
                  Text(
                    int.parse(double.parse(existencia).round().toString())
                        .toString(),
                    style: TextStyle(
                        // color: Colors.black45
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    "Existencia",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  showcomision
                      ? Text(
                          "\$" +
                              int.parse(
                                      double.parse(comision).round().toString())
                                  .toString(),
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))
                      : SizedBox(height: 0),
                  showcomision
                      ? Text("Comisión",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10))
                      : SizedBox(height: 0),
                ],
              )
            ],
          ),
        ),
      ));
}
