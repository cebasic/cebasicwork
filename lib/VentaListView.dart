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
  bool _isFetchingInitially =
      true; // Nueva variable de estado para la carga inicial

  Widget build(BuildContext context) {
    return _ventaListView(_ventas);
  }

  _onRefresh() async {
    HapticFeedback.mediumImpact();
    // No es necesario setState para _isFetchingInitially aquí si la recarga es manual,
    // ya que el header del SmartRefresher indicará la carga.
    // Si es la carga inicial, _isFetchingInitially ya es true.
    try {
      await _fetchVentas();
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      print("Error en _onRefresh: $e");
      if (mounted) {
        _refreshController.refreshFailed();
      }
    }
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
        child: _isFetchingInitially && _ventas.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Cargando información...",
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : _ventas.isNotEmpty
                ? ListView.builder(
                    itemCount: _ventas.length,
                    itemBuilder: (context, index) {
                      return _tile(
                          context,
                          _ventas[index]['cdescripcion'],
                          _ventas[index]['nimporte'].toString(),
                          _ventas[index]['nimporteComision'].toString(),
                          _ventas[index]['nfolio'].toString(),
                          _ventas[index]['dfecha_reg'].toString(),
                          _ventas[index]['fam'].toString());
                    })
                : Center(
                    child: Text(
                      "Sin ventas registradas",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
      ),
    );
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

    try {
      final response = await http.get(uri);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (mounted) {
          setState(() {
            _ventatotal = jsonResponse['ventatotal']?.toString() ?? "0.0";
            _comisiontotal = jsonResponse['comisiontotal']?.toString() ?? "0.0";
            _retardos_del_mes =
                jsonResponse['retardos_del_mes']?.toString() ?? "0";
            _ventas = jsonResponse['venta'];
            _name = jsonResponse['name'] ?? '';
            if (_isFetchingInitially) _isFetchingInitially = false;
            // HapticFeedback.mediumImpact(); // Ya está en _onRefresh
          });
        }

        List<dynamic> ventasList = jsonResponse['venta'] ?? [];
        return ventasList.map((venta) => Venta.fromJson(venta)).toList();
      } else {
        if (mounted) {
          setState(() {
            if (_isFetchingInitially) _isFetchingInitially = false;
          });
        }
        throw Exception(
            'Failed to load jobs from API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error en _fetchVentas: $e");
      if (mounted) {
        setState(() {
          if (_isFetchingInitially) _isFetchingInitially = false;
          // Opcionalmente, limpiar _ventas si falló la carga
          // _ventas = [];
        });
      }
      throw Exception(
          'Failed to load jobs from API: $e'); // Relanzar para que _onRefresh lo maneje
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
    if (fecha.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(fecha);
      String dia = dateTime.day.toString().padLeft(2, '0');
      String mes = dateTime.month.toString().padLeft(2, '0');
      String anio = dateTime.year.toString();
      String hora = dateTime.hour.toString().padLeft(2, '0');
      String minuto = dateTime.minute.toString().padLeft(2, '0');
      return '$dia/$mes/$anio $hora:$minuto';
    } catch (e) {
      // Si hay un error al parsear, devuelve la fecha original o un mensaje de error
      print('Error al formatear fecha: $e');
      // Intenta con el formato anterior si el nuevo falla, por si acaso.
      var arr = fecha.split('.');
      if (arr.isNotEmpty) {
        return arr[0];
      }
      return fecha; // o 'Fecha inválida'
    }
  }

  Card _tile(BuildContext context, String title, String venta, String comision,
      String folio, String dfecha_reg, String familia) {
    final brightness =
        Theme.of(context).brightness; // Determinar el brillo actual

    // Definir colores para modo claro y oscuro
    final Color folioIconColor =
        brightness == Brightness.dark ? Colors.blueGrey[200]! : Colors.blueGrey;
    final Color folioTextColor =
        brightness == Brightness.dark ? Colors.blueGrey[200]! : Colors.blueGrey;
    final Color folioNumberColor = brightness == Brightness.dark
        ? Colors.blueGrey[100]!
        : Colors.blueGrey[700]!;

    final Color dateIconColor =
        brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color dateTextColor =
        brightness == Brightness.dark ? Colors.grey[300]! : Colors.grey[700]!;

    // Colores para Comisión basados en AltaComisionListView (verde)
    final Color commissionAmountColor = brightness == Brightness.dark
        ? Colors.greenAccent[400]!
        : Colors.green; // Verde para modo claro
    final Color commissionTextColor = brightness == Brightness.dark
        ? Colors.greenAccent[200]!
        : Colors.green[700]!; // Verde más oscuro para texto en modo claro

    // Colores para Venta basados en el "Precio" de AltaComisionListView (verde)
    final Color saleAmountColor = brightness == Brightness.dark
        ? const Color.fromARGB(255, 132, 135, 134)!
        : Colors.green; // Verde para modo claro
    final Color saleTextColor = brightness == Brightness.dark
        ? Colors.greenAccent[200]!
        : Colors.green[700]!; // Verde más oscuro para texto en modo claro

    final Color cardBackgroundColor =
        brightness == Brightness.dark ? Colors.grey[900]! : Colors.white;

    return Card(
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna Izquierda: Folio
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrar verticalmente
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, color: folioIconColor, size: 28),
                SizedBox(height: 4),
                Text("Folio",
                    style: TextStyle(fontSize: 10, color: folioTextColor)),
                Text(
                  folio,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: folioNumberColor),
                ),
              ],
            ),
            SizedBox(width: 16),
            // Columna Central: Descripción y Fecha (Expandida)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, // cdescripcion
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight
                            .w500), // Se mantiene, debería adaptarse al tema
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: dateIconColor),
                      SizedBox(width: 4),
                      Text(
                        formatFecha(dfecha_reg),
                        style: TextStyle(fontSize: 12, color: dateTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Columna Derecha: Importes
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrar verticalmente
              children: [
                if (double.parse(comision).round() != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\$" + double.parse(comision).round().toString(),
                        style: TextStyle(
                          color: commissionAmountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Comisión",
                        style: TextStyle(
                          color: commissionTextColor,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                Text(
                  "\$" + double.parse(venta).round().toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: saleAmountColor),
                ),
                Text(
                  "Venta",
                  style: TextStyle(fontSize: 10, color: saleAmountColor),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

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
