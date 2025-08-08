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

  Articulo(
      {required this.clave,
      required this.descripcion,
      required this.comision,
      required this.precio,
      required this.existencia,
      required this.familia});

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
        clave: json['IdArticulo'].toString(),
        descripcion: json['cDescripcion'],
        comision: json['nComision'].toString(),
        precio: json['PrecioConImpuesto'].toString(),
        existencia: json['Existencia'].toString(),
        familia: json['nClave_Familia'].toString());
  }
}

class AltaComisionListView extends StatefulWidget {
  AltaComisionListView({Key? key}) : super(key: key);

  _AltaComisionListViewState createState() => _AltaComisionListViewState();
}

class _AltaComisionListViewState extends State<AltaComisionListView>
    with TickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );
  String server = "https://cebasicapi-node-caab21788dab.herokuapp.com";
  List<dynamic> _articulos = [];

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
    return _AltaComisionListView(_articulos);
  }

  _onRefresh() async {
    _fetchArticulos();
  }

  bool _checkedValue = true;
  String _selectedValue = "Teléfonos y accesorios";
  TextEditingController tfcontroller = TextEditingController();

  Scaffold _AltaComisionListView(_articulos) {
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
                        color: Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Comisión Alta",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "Productos de mayor comisión",
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
                      margin: EdgeInsets.symmetric(horizontal: 7),
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
                          padding: EdgeInsets.only(top: 20, bottom: 0),
                          itemCount: _articulos.length,
                          itemBuilder: (context, index) {
                            return _buildArticuloCard(
                              _articulos[index]['IdArticulo'].toString(),
                              _articulos[index]['cDescripcion'],
                              _articulos[index]['Existencia'].toString(),
                              _articulos[index]['PrecioConImpuesto'].toString(),
                              _articulos[index]['nComision'].toString(),
                              _articulos[index]['nClave_Familia'].toString(),
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

  Widget _buildArticuloCard(String clave, String descripcion, String existencia,
      String precio, String comision, String familia, bool isDark) {
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
            print("touched: " + clave);
            _navigateToNextScreen(
                context, ExistenciaScreen(clave: clave, title: descripcion));
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon and Clave Section
                Container(
                  padding: EdgeInsets.all(15),
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
                      _determineIcon(familia),
                      SizedBox(height: 8),
                      Text(
                        clave,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${descripcion[0].toUpperCase()}${descripcion.toUpperCase().substring(1)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.attach_money_outlined,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Precio: \$" +
                                int.parse(
                                        double.parse(precio).round().toString())
                                    .toString(),
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),

                // Commission and Stock Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Commission
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            "\$" + double.parse(comision).round().toString(),
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Comisión",
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Stock
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF3B82F6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            int.parse(
                                    double.parse(existencia).round().toString())
                                .toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          Text(
                            "Existencia",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B82F6),
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
        ),
      ),
    );
  }

  getUserSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString("user");
    return stringValue;
  }

  void filtraTipo() {}

  void _showLoading(message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: Color(0xFF334155),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: Color(0xFFF59E0B),
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Cargando",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog(message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: Color(0xFF334155),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Articulo>> _fetchArticulos() async {
    String user_id = await getUserSF();
    final jobsListAPIUrl = server + '/api/altacomision/user/' + user_id;
    final response = await http.get(Uri.parse(jobsListAPIUrl));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      setState(() {
        _articulos = jsonResponse;
      });
      _refreshController.refreshCompleted();
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
        return Icon(Icons.smartphone, color: Color(0xFF3B82F6), size: 24);
        break;
      case '2':
        return Icon(Icons.card_travel, color: Color(0xFF10B981), size: 24);
        break;
      case '3':
        return Icon(Icons.settings, color: Color(0xFFF59E0B), size: 24);
        break;
      default:
        i = Icon(Icons.smartphone, color: Color(0xFF3B82F6), size: 24);
        return i;
    }
  }

  var rng = new Random();
}
