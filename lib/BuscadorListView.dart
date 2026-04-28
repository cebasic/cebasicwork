import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'widgets/barcode_icon.dart';
import 'ExistenciaListView.dart';

class Articulo {
  final String clave;
  final String descripcion;
  final String existencia;
  final String precio;
  final String fam;

  Articulo(
      {required this.clave,
      required this.descripcion,
      required this.existencia,
      required this.precio,
      required this.fam});

  factory Articulo.fromJson(Map<String, dynamic> json) {
    return Articulo(
        clave: json['Clave'].toString(),
        descripcion: json['Descripcion'],
        existencia: json['Existencia'].toString(),
        precio: json['Precio'].toString(),
        fam: json['fam'].toString());
  }
}

class BuscadorListView extends StatefulWidget {
  BuscadorListView({Key? key}) : super(key: key);
  _BuscadorListViewState createState() => _BuscadorListViewState();
}

class _BuscadorListViewState extends State<BuscadorListView>
    with TickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  String server = "https://cebasicapi-node-caab21788dab.herokuapp.com";
  List<dynamic> _articulos = [];
  List<dynamic> _articulosresp = [];
  String? _ventatotal, _comisiontotal, _name;
  bool userisadmin = false;
  bool descartaExtZero = true;
  String _text = "";
  Timer? _longPressTimer;
  bool _showingCostForAll = false;
  bool _hasSearched = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _text);
    _focusNode = FocusNode();

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

    // Initialize userisadmin status
    _initializeUserStatus();
  }

  void _initializeUserStatus() async {
    bool isAdmin = await getIsAdmin();
    if (mounted) {
      setState(() {
        userisadmin = isAdmin;
      });
    }
  }

  void _startLongPressTimer(BuildContext context, String costo, String clave) {
    _cancelLongPressTimer(); // Cancel any existing timer
    _longPressTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _showingCostForAll = true;
      });
    });
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _hideCost() {
    setState(() {
      _showingCostForAll = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _cancelLongPressTimer();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return _buscadorListView(_articulos);
  }

  _onRefresh() async {
    if (_text.isNotEmpty) {
      _showLoading("Actualizando...");
      await _fetchArticulos(_text);
      _applyFilter();
      // Asegurar que el teclado permanezca cerrado después del refresh
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    _refreshController.refreshCompleted();
  }

  bool _checkedValue = true;
  String _selectedValue = "Celulares y accesorios";
  TextEditingController tfcontroller = TextEditingController();

  Scaffold _buscadorListView(_ventas) {
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
              // Custom App Bar with Search
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
                    // Search Bar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Color(0xFF1A1A1A).withOpacity(0.5)
                              : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                textInputAction: TextInputAction.search,
                                autofocus: true,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Buscar productos...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Color(0xFF64748B)
                                        : Color(0xFF9CA3AF),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: Icon(
                                    Icons.search_rounded,
                                    color: isDark
                                        ? Color(0xFF94A3B8)
                                        : Color(0xFF6B7280),
                                  ),
                                ),
                                onEditingComplete: () {
                                  _text = _textController.text;
                                  _focusNode.unfocus();
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  if (_text.length > 1) {
                                    _showLoading("Buscando");
                                    _fetchArticulos(_text)
                                        .then((_) => _applyFilter());
                                  } else {
                                    _showDialog(
                                        "Para buscar, escribe más de 1 caracter");
                                  }
                                },
                                onChanged: (text) {
                                  _text = text;
                                },
                              ),
                            ),
                            // Filter Button
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showFilterDialog(context),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF3B82F6).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: Color(0xFF3B82F6),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Cost Visibility Toggle Button
                            if (_showingCostForAll) ...[
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _hideCost,
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFFF59E0B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.visibility_off_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cost Visibility Banner
              if (_showingCostForAll) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFF59E0B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Costos visibles - Mantén presionado cualquier precio para activar",
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _hideCost,
                        child: Icon(
                          Icons.close,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      padding: EdgeInsets.only(top: 20),
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
                        child: _articulos.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.builder(
                                padding: EdgeInsets.only(top: 0, bottom: 20),
                                itemCount: _articulos.length,
                                itemBuilder: (context, index) {
                                  return _buildArticuloCard(
                                    _articulos[index]['Clave'].toString(),
                                    _articulos[index]['Descripcion'],
                                    _articulos[index]['Existencia'].toString(),
                                    _articulos[index]['Precio'].toString(),
                                    _articulos[index]['nComision'].toString(),
                                    _articulos[index]['costo'] != null
                                        ? _articulos[index]['costo']
                                            .toStringAsFixed(2)
                                        : '',
                                    true,
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
      String precio, String comision, String costo, bool isadmin, bool isDark) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            _navigateToNextScreen(
                context, ExistenciaScreen(clave: clave, title: descripcion));
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
                        descripcion,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
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
                              Icons.attach_money_outlined,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onLongPressStart: (details) {
                              _startLongPressTimer(context, costo, clave);
                            },
                            onLongPressEnd: (details) {
                              _cancelLongPressTimer();
                            },
                            child: Text(
                              "\$" + precio,
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Show cost only for admin users when long press is activated
                          if (userisadmin && _showingCostForAll) ...[],
                        ],
                      ),
                      // Show cost below price when long pressed
                      if (_showingCostForAll) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 12,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Costo: \$" + costo,
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 16),

                // Info Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Stock
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFF3B82F6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            existencia,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          Text(
                            "Existencia",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...[
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                              "\$" + comision,
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "Comisión",
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

  // Check if current user has admin privileges
  // Returns true if SharedPreferences "admin" key equals "1"
  // Ten en cuenta que este dato se guarda como "1" para admin y "0" para no admin
  Future<bool> getIsAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? valorAdmin = prefs.getString("admin");
    return valorAdmin == "1";
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
              color: isDark ? Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: Color(0xFF1A1A1A),
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
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF3B82F6),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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

    SystemChannels.textInput.invokeMethod('TextInput.hide');

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
              color: isDark ? Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: Color(0xFF1A1A1A),
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

  Future<List<Articulo>> _fetchArticulos(String params) async {
    bool userisadminSaved = await getIsAdmin();
    String user_id = await getUserSF();
    final jobsListAPIUrl =
        server + '/api/searchparam/user/' + user_id + '/' + params;
    print(jobsListAPIUrl);
    Uri uri = Uri.parse(jobsListAPIUrl);
    final response = await http.get(uri);
    print(response.body);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Navigator.pop(context);

      setState(() {
        _articulosresp = jsonResponse;
        _articulos = jsonResponse;
        userisadmin = userisadminSaved;
        _hasSearched = true;
      });
      _applyFilter();
      _refreshController.refreshCompleted();
      // Asegurar que el teclado permanezca cerrado
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      return jsonResponse
          .map<Articulo>((articulo) => new Articulo.fromJson(articulo))
          .toList();
    } else {
      throw Exception('Failed to load jobs from API');
    }
  }

  void _applyFilter() {
    switch (_selectedValue) {
      case "Celulares y accesorios":
        setState(() {
          _articulos = _articulosresp;
        });
        break;
      case "Celulares":
        setState(() {
          _articulos =
              _articulosresp.where((element) => element['fam'] == "C").toList();
        });
        break;
      case "Accesorios":
        setState(() {
          _articulos =
              _articulosresp.where((element) => element['fam'] == "A").toList();
        });
        break;
    }
  }

  void _showFilterDialog(BuildContext context) {
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
              color: isDark ? Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(
                      color: Color(0xFF1A1A1A),
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
                    color: Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF3B82F6),
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Filtros de Búsqueda",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 25),

                // Category Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Categoría",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF1A1A1A) : Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedValue,
                        isExpanded: true,
                        underline: SizedBox(),
                        dropdownColor:
                            isDark ? Color(0xFF111111) : Colors.white,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        items: <String>[
                          'Celulares y accesorios',
                          'Celulares',
                          'Accesorios'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (selected) {
                          setState(() {
                            _selectedValue = selected!;
                          });
                          Navigator.of(context).pop();
                          if (_text.isNotEmpty) {
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Apply Button
                Container(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (_text.isNotEmpty) {
                          _applyFilter();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Aplicar Filtros",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
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

  void _navigateToNextScreen(BuildContext context, Widget pantalla) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => pantalla));
  }

  Widget _buildEmptyState(bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hasSearched ? Icons.search_off_rounded : Icons.search_rounded,
              size: 60,
              color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
            ),
            SizedBox(height: 20),
            Text(
              _hasSearched ? "No se encontraron artículos" : "Busca artículos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _hasSearched
                  ? "Intenta con otros términos de búsqueda"
                  : "Escribe en el campo la clave o nombre del producto",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  var rng = new Random();
}
