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
      nfolio: json['nfolio'].toString(),
      cdescripcion: json['cdescripcion'] as String,
      nimporte: json['nimporte'].toString(),
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

class _VentaListViewState extends State<VentaListView>
    with TickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  List<dynamic> _ventas = [];
  String _ventatotal = "",
      _comisiontotal = "",
      _name = "",
      _retardos_del_mes = "";
  bool _isFetchingInitially = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return _ventaListView(_ventas);
  }

  _onRefresh() async {
    HapticFeedback.mediumImpact();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Color(0xFFF8FAFC),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: isDark
                      ? Color(0xFF111111).withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color(0xFF1A1A1A)
                                  : Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark
                                  ? Color(0xFF94A3B8)
                                  : Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.point_of_sale_rounded,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mi Historial de Ventas",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "Revisa tus transacciones",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Color(0xFF94A3B8)
                                  : Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
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
                        child: _isFetchingInitially && _ventas.isEmpty
                            ? Center(
                                child: Container(
                                  padding: EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Color(0xFF1E293B).withOpacity(0.95)
                                        : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF10B981)),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "Cargando información...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _ventas.isNotEmpty
                                ? ListView.builder(
                                    padding:
                                        EdgeInsets.only(top: 30, bottom: 20),
                                    itemCount: _ventas.length,
                                    itemBuilder: (context, index) {
                                      return _buildVentaCard(
                                        context,
                                        _ventas[index]['cdescripcion'],
                                        _ventas[index]['nimporte'].toString(),
                                        _ventas[index]['nimporteComision']
                                            .toString(),
                                        _ventas[index]['nfolio'].toString(),
                                        _ventas[index]['dfecha_reg'].toString(),
                                        _ventas[index]['fam'].toString(),
                                        isDark,
                                      );
                                    })
                                : Center(
                                    child: Container(
                                      padding: EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Color(0xFF1E293B)
                                                .withOpacity(0.95)
                                            : Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.2)
                                                : Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.receipt_long_outlined,
                                            size: 60,
                                            color: isDark
                                                ? Color(0xFF94A3B8)
                                                : Color(0xFF6B7280),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            "Sin ventas registradas",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "No se encontraron transacciones",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Color(0xFF94A3B8)
                                                  : Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVentaCard(
    BuildContext context,
    String title,
    String venta,
    String comision,
    String folio,
    String dfecha_reg,
    String familia,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Color(0xFF111111).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: isDark
            ? Border.all(
                color: Color(0xFF1A1A1A),
                width: 1,
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folio Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Folio",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    folio,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),

            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF1A1A1A) : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formatFecha(dfecha_reg),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),

            // Amounts Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (double.parse(comision).round() != 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF10B981).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "\$" + double.parse(comision).round().toString(),
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Comisión",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (double.parse(comision).round() != 0) SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFFF59E0B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "\$" + double.parse(venta).round().toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      Text(
                        "Venta",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
        });
      }
      throw Exception('Failed to load jobs from API: $e');
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
      print('Error al formatear fecha: $e');
      var arr = fecha.split('.');
      if (arr.isNotEmpty) {
        return arr[0];
      }
      return fecha;
    }
  }
}
