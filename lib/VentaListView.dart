import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:badges/badges.dart';

class Venta {
  final String nfolio;
  final String cdescripcion;
  final String nimporte;
  final String nimporteComision;
  final String dfecha_reg;
  final String fam;

  Venta({
    required this.nfolio,
    required this.cdescripcion,
    required this.nimporte,
    required this.nimporteComision,
    required this.dfecha_reg,
    required this.fam,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      nfolio: json['nfolio'].toString(), // Convertir int a String
      cdescripcion: json['cdescripcion'] as String,
      nimporte:
          json['nimporte'].toString(), // Convertir double a String y redondear
      nimporteComision: json['nimporteComision'].toString(),
      dfecha_reg: json['dfecha_reg'] as String,
      fam: json['fam'].toString(),
    );
  }
}

class VentaListView extends StatefulWidget {
  VentaListView({Key? key}) : super(key: key);
  _VentaListViewState createState() => _VentaListViewState();
}

class _VentaListViewState extends State<VentaListView> {
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  List<dynamic> _ventas = [];
  String _ventatotal = "",
      _comisiontotal = "",
      _name = "",
      _retardos_del_mes = "";
  Widget build(BuildContext context) {
    return _ventaListView(_ventas);
  }

  _onRefresh() async {
    HapticFeedback.mediumImpact();
    _fetchVentas();
    _refreshController.refreshCompleted();
  }

  Scaffold _ventaListView(_ventas) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mi historial de ventas"),
        ),
        body: SmartRefresher(
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
          child: _ventas.length != 0
              ? ListView.builder(
                  itemCount: _ventas.length,
                  itemBuilder: (context, index) {
                    // if (_ventas.length == 0) {
                    // return _resumen(_ventas[index]['cdescripcion']);
                    // }
                    // if (index == 0) {
                    //   return _resumen(_name);
                    // } else {
                    return _tile(
                        _ventas[index]['cdescripcion'],
                        _ventas[index]['nimporte'].toString(),
                        _ventas[index]['nimporteComision'].toString(),
                        _ventas[index]['nfolio'].toString(),
                        _ventas[index]['dfecha_reg'].toString(),
                        _ventas[index]['fam'].toString());
                    // }
                  })
              : (SizedBox(
                  height: 100, child: Center(child: Text("Cargando...")))),
        ));
  }

  getUserSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString("user");
    return stringValue;
  }

  Future<List<Venta>> _fetchVentas() async {
    String user = await getUserSF();
    final jobsListAPIUrl =
        'https://cebasicapi-node-caab21788dab.herokuapp.com/reporteuserventas/' +
            user;
    print(jobsListAPIUrl);
    Uri uri = Uri.parse(jobsListAPIUrl);
    final response = await http.get(uri);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        _ventatotal = jsonResponse['ventatotal']?.toString() ?? "0.0";
        _comisiontotal = jsonResponse['comisiontotal']?.toString() ?? "0.0";
        _retardos_del_mes = jsonResponse['retardos_del_mes']?.toString() ?? "0";
        _ventas = jsonResponse['venta'];
        _name = jsonResponse['name'] ?? '';
        HapticFeedback.mediumImpact();
      });

      // Extraer la lista de ventas desde el campo 'venta'
      List<dynamic> ventasList = jsonResponse['venta'] ?? [];

      // Convertir la lista de ventas al tipo List<Venta>
      return ventasList.map((venta) => Venta.fromJson(venta)).toList();
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  var now = new DateTime.now();
  var monthNames = [
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
  var rng = new Random();
  String formatFecha(String fecha) {
    var arr = fecha.split('.');
    return arr[0];
  }

  Card _tile(String title, String venta, String comision, String folio,
          String dfecha_reg, String familia) =>
      Card(
          child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              children: [
                Icon(Icons.point_of_sale),
                Text("Folio", style: TextStyle(fontSize: 10)),
                Text(folio, style: TextStyle(fontSize: 10))
              ],
            ),
            Container(
              width: 20,
            ),
            Flexible(
                child: Container(

                    // padding: EdgeInsets.only(right: 10),
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.fade,
                ),
                Text(
                  dfecha_reg.split('.')[0],
                  overflow: TextOverflow.fade,
                ),
              ],
            ))),
            Column(
              children: [
                familia == "2" || double.parse(comision).round() == 0
                    ? SizedBox(
                        height: 0,
                      )
                    : Text(
                        "\$" + double.parse(comision).round().toString(),
                        // rng.nextInt(100).toString(),
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                familia == "2" || double.parse(comision).round() == 0
                    ? SizedBox(
                        height: 0,
                      )
                    : Text(
                        "Comisión",
                        // rng.nextInt(100).toString(),
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                Text(
                  "\$" + double.parse(venta).round().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Venta",
                  // style: TextStyle(color: Colors.black45),
                ),
              ],
            )
          ],
        ),
      ));

  Card _resumen(String title) => Card(
          child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // new Container(
            //     width: 120.0,
            //     height: 120.0,
            //     decoration: new BoxDecoration(
            //         shape: BoxShape.circle,
            //         image: new DecorationImage(
            //             fit: BoxFit.fill,
            //             image: AssetImage('images/userblank.png')))),
            SizedBox(height: 5),
            new Text(
              title,
              // textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            _retardos_del_mes.compareTo("0") > 0
                ? retardosLabel()
                : SizedBox(height: 0),
            // Container(
            //   child: Text(
            //     "Resumen",
            //     // overflow: TextOverflow.fade,
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            //   ),
            // ),
            // SizedBox(height: 8),
            Text(
              "\$" + double.parse(_comisiontotal).round().toString(),
              // rng.nextInt(100).toString(),
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 35),
            ),
            Text(
              "Comisión",
              // rng.nextInt(100).toString(),
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 23),
            ),
            SizedBox(height: 8),
            Text("Venta \$" + double.parse(_ventatotal).round().toString(),
                // rng.nextInt(100).toString(),
                style: TextStyle(fontSize: 20)),
          ],
        ),
      ));
  Column retardosLabel() {
    return Column(
      children: [
        Chip(
          padding: EdgeInsets.all(0),
          backgroundColor: Colors.red,
          label: new Text(
            "Retardos:" + _retardos_del_mes,
            // textScaleFactor: 1.5,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
        ),
        SizedBox(height: 0)
      ],
    );
  }

  Card _resumenVacio(String title) => Card(
          child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            new Container(
                width: 120.0,
                height: 120.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('images/userblank.png')))),
            SizedBox(height: 8),
            new Text(
              title,
              // textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
            ),
            SizedBox(height: 8),
            // Container(
            //   child: Text(
            //     "Resumen",
            //     // overflow: TextOverflow.fade,
            //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            //   ),
            // ),
            // SizedBox(height: 8),
            Text(
              "Comisión \$0",
              // rng.nextInt(100).toString(),
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            SizedBox(height: 8),
            Text("Venta \$0",
                // rng.nextInt(100).toString(),
                style: TextStyle(fontSize: 20)),
          ],
        ),
      ));
}
