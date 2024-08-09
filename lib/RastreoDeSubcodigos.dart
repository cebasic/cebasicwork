import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'ExistenciaListView.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class RastreoDeSubcodigos extends StatefulWidget {
  @override
  _RastreoDeSubcodigosState createState() => _RastreoDeSubcodigosState();
}

class _RastreoDeSubcodigosState extends State<RastreoDeSubcodigos> {
  @override
  String _querytext = "";
  String defaultdata = "Escribe o escanea un IMEI/Serial";
  var data;

  Widget build(BuildContext context) {
    return _buscadorListView();
  }

  void _scanBarcode() async {
    String barcodeScanRes = "";
    // save results from getData() to data

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (barcodeScanRes != "-1") {
        // barcodeScanRes = "356938045643809";
        setState(() {
          _querytext = barcodeScanRes;
          getData(_querytext).then((value) {
            // count items and print it
            var count = value.length;
            print(count);
          });
        });
      } else {
        // _showDialog("Para buscar, escribe más de 1 caracter");
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    } catch (e) {
      print(e);
    }
  }

  // get data from http://cbserver.ddnsfree.com:8000/getmovimientosbyimei/{{imei}}
  getData(String imei) async {
    _showLoading("Cargando");
    var url =
        "https://cebasicapi-node-caab21788dab.herokuapp.com/getmovimientosbyimei/$imei";
    Uri uri = Uri.parse(url);
    print(uri);
    var response = await http.get(uri);
    var datares = jsonDecode(response.body);

    // ordena al revés datares
    datares = datares.reversed.toList();

    setState(() {
      defaultdata = (datares.length == 0 || datares == null)
          ? "No se encontraron resultados"
          : "Escribe o escanea un IMEI/Serie";
      this.data = datares;
      Navigator.pop(context);
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    return datares;
  }

  //
  Scaffold _buscadorListView() {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: TextEditingController(text: _querytext),
            textInputAction: TextInputAction.search,
            autofocus: false,
            style: TextStyle(fontSize: 20.0, color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Buscar IMEI/Serie',
              contentPadding:
                  const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 10.0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(23.7),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(23.7),
              ),
            ),
            onEditingComplete: () {
              // SystemChannels.textInput.invokeMethod('TextInput.hide');
              if (_querytext.length > 1) {
                getData(_querytext).then((value) {
                  // print result
                });
              } else {
                // _showDialog("Para buscar, escribe más de 1 caracter");
                // SystemChannels.textInput.invokeMethod('TextInput.hide');
              }
            },
            onChanged: (text) {
              _querytext = text;
            },
          ),
          // a button for scan barcode
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.qr_code_scanner_sharp),
              onPressed: () {
                _scanBarcode();
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: data == null
                    ? Center(
                        child: Text(defaultdata),
                      )
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return _tile(
                              data[index]["Clave_Movimiento"].toString(),
                              data[index]["Decripcion_Movimiento"].toString(),
                              data[index]["Descripcion_Articulo"].toString(),
                              data[index]["Descripcion_Involucrado"].toString(),
                              data[index]["Descripcion_Almacen"].toString(),
                              data[index]["Nombre_Empleado"].toString(),
                              data[index]["Fecha"].toString());
                        },
                      ))
          ],
        ));
  }

  // a custom list tile for show results
  Card _tile(
      String clave_movimiento,
      String descripcion_movimiento,
      String descripcion_articulo,
      String involucrado,
      String almacen,
      String usuario,
      String fecha) {
    // remove all spaces at the end of the string
    descripcion_articulo = descripcion_articulo.trimRight();
    descripcion_movimiento == null
        ? descripcion_movimiento = ""
        : descripcion_movimiento;
    descripcion_articulo == null
        ? descripcion_articulo = ""
        : descripcion_articulo;
    involucrado == null ? involucrado = "" : involucrado;
    almacen == null ? almacen = "" : almacen;
    usuario == null ? usuario = "" : usuario;

    // format fecha to dd/mm/yyyy
    fecha = fecha.substring(0, 10).replaceAll("-", "/");
    String year = fecha.substring(0, 4);
    String month = fecha.substring(5, 7);
    String day = fecha.substring(8, 10);

    // month name array in spanish
    List<String> meses = [
      "",
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];

    // Array of emojis
    //                        0   1     2      3     4     5     6     7    8   9   10  11  12  13  14  15  16  17
    List<String> simbolos = [
      "",
      "📦",
      "🛒",
      "🧾",
      "📤",
      "📥",
      "↔️",
      "🔧",
      "🔧",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️",
      "↔️"
    ];

    String movimiento = "";
    switch (clave_movimiento) {
      case "2":
        movimiento = "Recibido en " + almacen;
        break;
      case "3":
        movimiento = almacen;
        break;
      case "4":
        movimiento = almacen + " ➡️ " + involucrado;
        break;
      case "5":
        movimiento = involucrado + " ➡️ " + almacen;
        break;
      default:
        movimiento = "Almacen: " + almacen + " - Involucrado:" + involucrado;
    }

    return Card(
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // icon
                  // Column(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         simbolos[int.parse(clave_movimiento)],
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold, fontSize: 25),
                  //       ),
                  //     ]),
                  // SizedBox(width: 15),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          capitalizeEachWord(descripcion_movimiento) +
                              " " +
                              simbolos[int.parse(clave_movimiento)],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          capitalizeEachWord(descripcion_articulo),
                          overflow: TextOverflow.ellipsis,
                        ),
                        movimiento == ""
                            ? SizedBox(height: 0)
                            : Text(movimiento),
                        // involucrado == ""
                        //     ? SizedBox(height: 0)
                        //     : Text('Envía: ' + involucrado + ""),
                        // almacen == "" ? SizedBox(height: 0) : Text('Recibe: ' + almacen),
                        Text(
                          'Usuario: ' + usuario,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Text('Fecha: ' + fecha),
                      ])),
                  // fecha
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(day,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(meses[int.parse(month)],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(year,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                ])));
  }

  String capitalizeEachWord(String input) {
    return input.split(" ").map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(" ");
  }

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
}
