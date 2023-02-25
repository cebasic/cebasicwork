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
  final String comision;
  final String precio;
  final String existencia;
  final String familia;
  // flutter 2.8.0
  // nClave_Familia
  // Articulo(
  //     {this.clave,
  //     this.descripcion,
  //     this.comision,
  //     this.precio,
  //     this.existencia,
  //     this.familia});
  // flutter 3.0.0
  Articulo(
      {required this.clave,
      required this.descripcion,
      required this.comision,
      required this.precio,
      required this.existencia,
      required this.familia});

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
        clave: json['IdArticulo'],
        descripcion: json['cDescripcion'],
        comision: json['nComision'],
        precio: json['PrecioConImpuesto'],
        existencia: json['Existencia'],
        familia: json['nClave_Familia']);
  }
}

class AltaComisionListView extends StatefulWidget {
  AltaComisionListView({Key? key}) : super(key: key);

  _AltaComisionListViewState createState() => _AltaComisionListViewState();
}

class _AltaComisionListViewState extends State<AltaComisionListView> {
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  String server = "http://cbserver.ddnsfree.com:8000";
  List<dynamic> _articulos = [];
  Widget build(BuildContext context) {
    return _AltaComisionListView(_articulos);
  }

  _onRefresh() async {
    // _refreshController.refreshCompleted();
    _fetchArticulos();
  }

  bool _checkedValue = true;
  String _selectedValue = "Teléfonos y accesorios";
  TextEditingController tfcontroller = TextEditingController();
  Scaffold _AltaComisionListView(_articulos) {
    // tfcontroller.addListener(() {
    //   print("probando");
    String _text;
    // });
    return Scaffold(
        appBar: AppBar(
          title: Text('Artículos con comisión alta'),
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
            //   child:
            //   Container(
            //     height: 30,
            //     child:
            //     Row(
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
            //         // Text(
            //         //   "Descartar 0",
            //         //   // style: TextStyle(fontSize: 18),
            //         // ),
            //         // Checkbox(
            //         //   value: _checkedValue,
            //         //   onChanged: (newValue) {
            //         //     setState(() {
            //         //       _checkedValue = newValue;
            //         //       // print(_checkedValue);
            //         //     });
            //         //   },
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
                child: SmartRefresher(
              header: CustomHeader(
                builder: (context, mode) {
                  Widget body = SizedBox(
                    height: 0,
                  );
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
                        // "nComision": "150.0000",
                        // nClave_Familia
                        _articulos[index]['IdArticulo'],
                        _articulos[index]['cDescripcion'],
                        _articulos[index]['Existencia'],
                        _articulos[index]['PrecioConImpuesto'],
                        _articulos[index]['nComision'],
                        _articulos[index]['nClave_Familia'],
                      );
                    }
                  }),
            ))
          ],
        ));
  }

  getUserSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // flutter 2.8.0
    // String stringValue = prefs.getString("user");
    // flutter 3.0.0
    String? stringValue = prefs.getString("user");
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

  Future<List<Articulo>> _fetchArticulos() async {
    // print("params: " + params);
    String user_id = await getUserSF();
    final jobsListAPIUrl = server + '/api/altacomision/user/' + user_id + '/';
    final response = await http.get(jobsListAPIUrl);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      // jsonResponse.insert(0, jsonResponse[0]);
      // Navigator.pop(context);
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      setState(() {
        _articulos = jsonResponse;
      });
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

  Icon _determineIcon(familia) {
    Icon i;
    switch (familia) {
      case '1':
        return Icon(Icons.smartphone);
        break;
      case '2':
        return Icon(Icons.card_travel);
        break;
      case '3':
        return Icon(Icons.settings);
        break;
      default:
        i = Icon(Icons.smartphone);
        return i;
    }
  }

  var rng = new Random();
  Card _tile(String clave, String descripcion, String existencia, String precio,
          String comision, String familia) =>
      Card(
          child: InkWell(
        onTap: () {
          print("touched: " + clave);
          _navigateToNextScreen(
              context, ExistenciaScreen(clave: clave, title: descripcion));
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [_determineIcon(familia), Text(clave)],
              ),
              Container(
                width: 20,
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
                          "Precio: \$" +
                              int.parse(double.parse(precio).round().toString())
                                  .toString(),
                          // rng.nextInt(100).toString(),
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        // SizedBox(
                        //   width: userisadmin ? 10 : 0,
                        // ),
                      ],
                    ),
                  ],
                ),
              )),
              Column(
                children: [
                  Text(
                    "\$" + double.parse(comision).round().toString(),
                    // rng.nextInt(100).toString(),
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Text(
                    "Comisión",
                    // rng.nextInt(100).toString(),
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
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
                ],
              )
              // Flexible(
              //     child: Container(
              //   child: Text(
              //     descripcion,
              //     overflow: TextOverflow.fade,
              //   ),
              // )),
              // Column(
              //   children: [
              //     Text(
              //       "Precio \$" + (double.parse(precio).round()).toString(),
              //       // rng.nextInt(100).toString(),
              //     ),
              //     Text(
              //       "Comisión \$" + double.parse(comision).round().toString(),
              //       // rng.nextInt(100).toString(),
              //       style: TextStyle(
              //           color: Colors.green, fontWeight: FontWeight.bold),
              //     ),
              //     Text(
              //       "Existencia: " +
              //           int.parse(double.parse(existencia).round().toString())
              //               .toString(),
              //       // style: TextStyle(color: Colors.black45),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ));
}
