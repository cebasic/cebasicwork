import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'widgets/barcode_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Existencia {
  final String clave;
  final String descripcion;
  final String existencia;
  final String precio;
  final String almacen;

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

  ExistenciaScreen({Key? key, required this.clave, required this.title})
      : super(key: key);

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

class _ExistenciaListViewState extends State<ExistenciaListView>
    with TickerProviderStateMixin {
  String _clave = "", _title = "";
  var _articulos = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  _ExistenciaListViewState(String clave, String title) {
    _clave = clave;
    _title = title;
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _ListView(),
    );
  }

  _onRefresh() async {
    _fetchArticulos(_clave);
    _refreshController.refreshCompleted();
  }

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  Scaffold _ListView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: isDark
                      ? Color(0xFF1E293B).withOpacity(0.95)
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
                                  ? Color(0xFF334155)
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
                        color: Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Detalle de existencias",
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

              // Content
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
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          itemCount: _articulos.length,
                          itemBuilder: (context, index) {
                            return _buildExistenciaCard(
                              _articulos[index]['Clave'].toString(),
                              _articulos[index]['cAlmacenDescripcion'],
                              _articulos[index]['Existencia'].toString(),
                              _articulos[index]['Precio'].toString(),
                              isDark,
                            );
                          },
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

  Widget _buildExistenciaCard(String clave, String almacen, String existencia,
      String precio, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        border: isDark
            ? Border.all(
                color: Color(0xFF334155),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Puedes agregar funcionalidad aquí si es necesario
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Clave Section
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
                      BarcodeIcon(
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Clave",
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        clave,
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
                        almacen,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Existencia: " +
                                int.parse(double.parse(existencia)
                                        .round()
                                        .toString())
                                    .toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Color(0xFF94A3B8)
                                  : Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),

                // Price Section
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFF59E0B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "\$" + double.parse(precio).round().toString(),
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Precio",
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      setState(() {
        _articulos = jsonResponse;
      });
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
}
