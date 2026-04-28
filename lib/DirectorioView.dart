import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectorioView extends StatefulWidget {
  const DirectorioView({Key? key}) : super(key: key);

  @override
  _DirectorioViewState createState() => _DirectorioViewState();
}

class _DirectorioViewState extends State<DirectorioView>
    with TickerProviderStateMixin {
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
                        color: Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Directorio de Sucursales",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "Ubicaciones y contactos",
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
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 20),
                        children: [
                          _buildSectionTitle("Sucursales Culiacán", isDark),
                          _buildContactCard("lomita@cebasic.com", "6671460879",
                              "Plaza Lomita", "", isDark),
                          _buildContactCard(
                              "mgalerias@cebasic.com",
                              "6675032726",
                              "Modulo Galerias San Miguel",
                              "",
                              isDark),
                          _buildContactCard("galerias@cebasic.com",
                              "6671460714", "Galerias San Miguel", "", isDark),
                          _buildContactCard(
                              "galerias2@cebasic.com",
                              "6671709765",
                              "Galerias San Miguel 2",
                              "",
                              isDark),
                          _buildContactCard("baurrera@cebasic.com",
                              "6677182218", "Bodega Aurrera", "", isDark),
                          _buildContactCard("isla@cebasic.com", "6671463981",
                              "Isla Musala", "", isDark),
                          _buildContactCard("pfiesta@cebasic.com", "6676483100",
                              "Plaza Fiesta", "", isDark),
                          _buildContactCard("sendero@cebasic.com", "6671133701",
                              "Sendero", "", isDark),
                          _buildContactCard("mvalle@cebasic.com", "6677215353",
                              "Modulo Valle", "", isDark),
                          _buildContactCard("valle@cebasic.com", "6677215784",
                              "Plaza Valle", "", isDark),
                          _buildContactCard("humaya@cebasic.com", "6677100956",
                              "Plaza Humaya", "", isDark),
                          _buildContactCard("forum@cebasic.com", "6677126617",
                              "Forum", "", isDark),
                          _buildContactCard("cuatrorios@cebasic.com",
                              "6671709273", "Cuatro Rios", "", isDark),
                          _buildContactCard("oasis@cebasic.com", "6671706357",
                              "Paseo Oasis", "", isDark),
                          _buildSectionTitle("Sucursales Mazatlán", isDark),
                          _buildContactCard("patio@cebasic.com", "6699803411",
                              "Plaza Patio", "", isDark),
                          _buildContactCard("santarosa@cebasic.com",
                              "6696882046", "Plaza Santa Rosa", "", isDark),
                          _buildContactCard("galeriasmzt@cebasic.com",
                              "6692795264", "Galerias Mazatlan", "", isDark),
                          _buildContactCard("e10@cebasic.com", "6696889148",
                              "Gran Plaza E10", "", isDark),
                          _buildContactCard("granplaza@cebasic.com",
                              "6699833485", "Gran Plaza", "", isDark),
                          _buildSectionTitle("Reparaciones", isDark),
                          _buildContactCard("cellfix@cebasic.com", "6699833128",
                              "Cellfix Mzt", "", isDark),
                          _buildContactCard("reparacionaurrera@cebasic.com",
                              "6677182218", "Reparaciones Aurrera", "", isDark),
                          _buildContactCard("reparacionhumaya@cebasic.com",
                              "6677100956", "Reparaciones Humaya", "", isDark),
                          _buildContactCard("reparacionisla@cebasic.com",
                              "6671463981", "Reparaciones Isla", "", isDark),
                          _buildContactCard(
                              "reparacionsr@cebasic.com",
                              "6696882046",
                              "Reparaciones Plaza Santa Rosa",
                              "",
                              isDark),
                          _buildContactCard(
                              "reparacionvalle@cebasic.com",
                              "6677215784",
                              "Reparaciones Plaza Valle",
                              "",
                              isDark),
                          _buildContactCard(
                              "reparacionlomita@cebasic.com",
                              "6671460879",
                              "Reparaciones Plaza Lomita",
                              "",
                              isDark),
                          _buildSectionTitle("Administrativos", isDark),
                          _buildContactCard("director@cebasic.com", "",
                              "Miguel Torrontegui", "", isDark),
                          _buildContactCard("recursos@cebasic.com",
                              "6673080900", "America Iribe", "", isDark),
                          _buildContactCard("recursos2@cebasic.com",
                              "6672060481", "Dalia Arce", "", isDark),
                          _buildContactCard("finanzas@cebasic.com",
                              "6673080900", "Finanzas", "", isDark),
                          _buildContactCard(
                              "contabilidad@cebasic.com",
                              "6674310282",
                              "Contabilidad - Arturo Carmona",
                              "",
                              isDark),
                          _buildContactCard(
                              "cadenas@cebasic.com",
                              "",
                              "Cadenas comerciales - Ivan Sandoval",
                              "",
                              isDark),
                          _buildSectionTitle("Almacenes y Operaciones", isDark),
                          _buildContactCard(
                              "almacen1@cebasic.com",
                              "6671540474",
                              "Almacen teléfonos - Leonardo Sanchez",
                              "",
                              isDark),
                          _buildContactCard(
                              "almacen2@cebasic.com",
                              "6671010840",
                              "Almacen teléfonos - Juan Pablo",
                              "",
                              isDark),
                          _buildContactCard(
                              "almacen3@cebasic.com",
                              "6672928909",
                              "Almacen accesorios - Sofia Payan",
                              "",
                              isDark),
                          _buildContactCard(
                              "operaciones2@cebasic.com",
                              "6674075833",
                              "Auditoria y Operaciones - Erick Meza",
                              "",
                              isDark),
                          _buildContactCard(
                              "garantias@cebasic.com",
                              "",
                              "Garantias - Jorge Rojo/Saturnino Gaxiola",
                              "",
                              isDark),
                          _buildContactCard("somos@cebasic.com", "6672454125",
                              "Ecommerce - Elias Gamez", "", isDark),
                          _buildContactCard(
                              "mercadotecnia@cebasic.com",
                              "6676938366",
                              "Mercadotecnia - Cristell Gamez",
                              "",
                              isDark),
                          _buildContactCard(
                              "contacto@cebasic.com",
                              "6672646767",
                              "Credibasic - Manuel Bustamante",
                              "",
                              isDark),
                          _buildContactCard(
                              "telcel.basic@hotmail.com",
                              "6672360065",
                              "Planes Telcel - Francisco Mada",
                              "",
                              isDark),
                          _buildContactCard(
                              "artegrafica@cebasic.com",
                              "",
                              "Diseño Grafico - Maria Jose Gonzalez",
                              "",
                              isDark),
                        ],
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Color(0xFF111111).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(
                color: Color(0xFF1A1A1A),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.category_rounded,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Color(0xFFF1F5F9) : Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      String correo, String tel, String title, String whatsapp, bool isDark) {
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
            // Puedes agregar funcionalidad aquí si es necesario
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon and Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              correo.toLowerCase(),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Color(0xFF94A3B8)
                                    : Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (tel.isNotEmpty) ...[
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Color(0xFF94A3B8)
                                      : Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (whatsapp.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _launchWSP(tel),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFF25D366).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF25D366).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.message,
                                color: Color(0xFF25D366),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (tel.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _calling(tel),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF10B981).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.phone,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
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

  void _calling(numero) {
    _launchURL(numero);
  }

  _launchURL(String telp) async {
    if (await canLaunch('tel:$telp')) {
      await launch('tel:' + telp);
    } else {
      throw 'Could not launch $telp';
    }
  }

  _launchWSP(String telp) async {
    try {
      await launch('whatsapp://send?text=Hello World!&phone=+521' + telp);
    } catch (e) {
      print(e);
    }
  }
}
