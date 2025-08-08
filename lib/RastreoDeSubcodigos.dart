import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'ExistenciaListView.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/barcode_icon.dart';

class RastreoDeSubcodigos extends StatefulWidget {
  @override
  _RastreoDeSubcodigosState createState() => _RastreoDeSubcodigosState();
}

class _RastreoDeSubcodigosState extends State<RastreoDeSubcodigos>
    with TickerProviderStateMixin {
  @override
  String _querytext = "";
  String defaultdata = "Escribe o escanea un IMEI/Serial";
  var data;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _querytext);
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return _buscadorListView();
  }

  void _scanBarcode() async {
    try {
      String? barcodeScanRes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _ScannerPage(),
        ),
      );

      if (barcodeScanRes != null && barcodeScanRes != "-1") {
        setState(() {
          _querytext = barcodeScanRes;
          getData(_querytext).then((value) {
            var count = value.length;
            print(count);
          });
        });
      } else {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    } catch (e) {
      print(e);
    }
  }

  getData(String imei) async {
    _showLoading("Cargando");
    try {
      var url =
          "https://cebasicapi-node-caab21788dab.herokuapp.com/getmovimientosbyimei/$imei";
      Uri uri = Uri.parse(url);
      print(uri);
      var response = await http.get(uri);
      print(response.body);
      var datares = jsonDecode(response.body);

      datares = datares.reversed.toList();

      // Cerrar el modal de carga primero
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        defaultdata = (datares.length == 0 || datares == null)
            ? "No se encontraron resultados"
            : "Escribe o escanea un IMEI/Serie";
        this.data = datares;
      });

      // Asegurar que el teclado permanezca cerrado
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      return datares;
    } catch (e) {
      // Cerrar el modal de carga en caso de error
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      print('Error en getData: $e');
      setState(() {
        defaultdata = "Error al cargar los datos";
        this.data = null;
      });
      // Asegurar que el teclado permanezca cerrado en caso de error
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      return null;
    }
  }

  Scaffold _buscadorListView() {
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

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Color(0xFF334155).withOpacity(0.5)
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
                                  hintText: 'Buscar IMEI/Serie',
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
                                  _querytext = _textController.text;
                                  _focusNode.unfocus();
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  if (_querytext.length > 1) {
                                    getData(_querytext).then((_) {});
                                  }
                                },
                                onChanged: (text) {
                                  _querytext = text;
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _scanBarcode(),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEF4444).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: BarcodeIcon(
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  child: data == null
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
                                BarcodeIcon(
                                  size: 60,
                                  color: isDark
                                      ? Color(0xFF94A3B8)
                                      : Color(0xFF6B7280),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  defaultdata,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return _buildMovimientoCard(
                              data[index]["Clave_Movimiento"].toString(),
                              data[index]["Decripcion_Movimiento"].toString(),
                              data[index]["Descripcion_Articulo"].toString(),
                              data[index]["Descripcion_Involucrado"].toString(),
                              data[index]["Descripcion_Almacen"].toString(),
                              data[index]["Nombre_Empleado"].toString(),
                              data[index]["Fecha"].toString(),
                              isDark,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientoCard(
    String clave_movimiento,
    String descripcion_movimiento,
    String descripcion_articulo,
    String involucrado,
    String almacen,
    String usuario,
    String fecha,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Clean strings
    descripcion_articulo = descripcion_articulo.trimRight();
    descripcion_movimiento =
        descripcion_movimiento.isEmpty ? "" : descripcion_movimiento;
    descripcion_articulo =
        descripcion_articulo.isEmpty ? "" : descripcion_articulo;
    involucrado = involucrado.isEmpty ? "" : involucrado;
    almacen = almacen.isEmpty ? "" : almacen;
    usuario = usuario.isEmpty ? "" : usuario;

    // Format date
    fecha = fecha.substring(0, 10).replaceAll("-", "/");
    String year = fecha.substring(0, 4);
    String month = fecha.substring(5, 7);
    String day = fecha.substring(8, 10);

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

    IconData getMovementIcon(String clave_movimiento) {
      switch (clave_movimiento) {
        case "1":
          return Icons.inventory_2_rounded;
        case "2":
          return Icons.inventory_2_rounded;
        case "3":
          return Icons.shopping_cart_rounded;
        case "4":
          return Icons.receipt_rounded;
        case "5":
          return Icons.file_upload_rounded;
        case "6":
          return Icons.file_download_rounded;
        case "7":
        case "8":
        case "9":
        case "10":
        case "11":
        case "12":
        case "13":
        case "14":
        case "15":
        case "16":
        case "17":
        case "18":
          return Icons.swap_horiz_rounded;
        default:
          return Icons.inventory_2_rounded;
      }
    }

    String movimiento = "";
    switch (clave_movimiento) {
      case "2":
        movimiento = "Recibido en " + almacen;
        break;
      case "3":
        movimiento = almacen;
        break;
      case "4":
        movimiento = almacen + " → " + involucrado;
        break;
      case "5":
        movimiento = involucrado + " → " + almacen;
        break;
      default:
        movimiento = "Almacen: " + almacen + " - Involucrado:" + involucrado;
    }

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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          getMovementIcon(clave_movimiento),
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          capitalizeEachWord(descripcion_movimiento),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    capitalizeEachWord(descripcion_articulo),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movimiento.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      movimiento,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF334155) : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 12,
                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Usuario: ' + usuario,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),

            // Date Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    meses[int.parse(month)],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    year,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalizeEachWord(String input) {
    return input.split(" ").map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(" ");
  }

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
}

// Página separada para el escáner usando mobile_scanner
class _ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escanear Código',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFFEF4444),
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : Colors.white,
            ),
            iconSize: 28.0,
            onPressed: () async {
              try {
                await cameraController.toggleTorch();
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              } catch (e) {
                print('Error toggling torch: $e');
              }
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.camera_rear),
            iconSize: 28.0,
            onPressed: () async {
              try {
                await cameraController.switchCamera();
              } catch (e) {
                print('Error switching camera: $e');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ]
                : [
                    Color(0xFFEF4444),
                    Color(0xFFDC2626),
                  ],
          ),
        ),
        child: MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                Navigator.pop(context, barcode.rawValue);
                return;
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
