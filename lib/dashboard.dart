import 'dart:convert';
import 'dart:io';
import 'package:cebasicwork/AltaComisionListView.dart';

import 'BuscadorListView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'VentaListView.dart';
import 'DirectorioView.dart';
import 'RastreoDeSubcodigos.dart';
import 'AIBotView.dart';
import 'widgets/barcode_icon.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isAdmin = false;

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

    _checkAdminStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdmin = prefs.getString('admin') == '1';
    });
  }

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      // Logo
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'images/logocb.png',
                          fit: BoxFit.contain,
                          height: 24,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ceBasic Work",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              "Panel de Control",
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
                      // Logout Button
                      Container(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showLogoutDialog(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
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

                // Main Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        child: ListView(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          children: [
                            // Bot de IA - Solo para administradores
                            if (_isAdmin)
                              _buildMenuCard(
                                context: context,
                                title: "Asistente IA (beta)",
                                subtitle: "Chat inteligente para consultas",
                                icon: Icons.smart_toy_rounded,
                                color: Color(0xFF6366F1),
                                onTap: () => _navigateToNextScreen(
                                  context,
                                  AIBotView(),
                                ),
                                isDark: isDark,
                              ),
                            _buildMenuCard(
                              context: context,
                              title: "Buscar artículos",
                              subtitle: "Encuentra productos rápidamente",
                              icon: Icons.search_rounded,
                              color: Color(0xFF3B82F6),
                              onTap: () => _navigateToNextScreen(
                                context,
                                BuscadorListView(key: UniqueKey()),
                              ),
                              isDark: isDark,
                            ),
                            _buildMenuCard(
                              context: context,
                              title: "Mi historial de ventas",
                              subtitle: "Revisa tus transacciones",
                              icon: Icons.point_of_sale_rounded,
                              color: Color(0xFF10B981),
                              onTap: () => _navigateToNextScreen(
                                context,
                                VentaListView(),
                              ),
                              isDark: isDark,
                            ),
                            _buildMenuCard(
                              context: context,
                              title: "Artículos con comisión alta",
                              subtitle: "Productos de mayor comisión",
                              icon: Icons.attach_money_rounded,
                              color: Color(0xFFF59E0B),
                              onTap: () => _navigateToNextScreen(
                                context,
                                AltaComisionListView(
                                  key: UniqueKey(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                            _buildMenuCard(
                              context: context,
                              title: "Directorio de sucursales",
                              subtitle: "Ubicaciones y contactos",
                              icon: Icons.store_rounded,
                              color: Color(0xFF8B5CF6),
                              onTap: () => _navigateToNextScreen(
                                context,
                                DirectorioView(),
                              ),
                              isDark: isDark,
                            ),
                            _buildMenuCard(
                              context: context,
                              title: "Rastreo de IMEI/Serie",
                              subtitle: "Escanea códigos de productos",
                              icon: BarcodeIcon(
                                color: Color(0xFFEF4444),
                                size: 24,
                              ),
                              color: Color(0xFFEF4444),
                              onTap: () => _navigateToNextScreen(
                                context,
                                RastreoDeSubcodigos(),
                              ),
                              isDark: isDark,
                            ),
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
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required dynamic icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
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
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: icon is IconData
                      ? Icon(
                          icon,
                          color: color,
                          size: 24,
                        )
                      : icon,
                ),
                SizedBox(width: 20),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => pantalla,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Cerrar Sesión",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "¿Estás seguro de que quieres cerrar sesión?",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color(0xFF334155)
                                  : Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                color: isDark
                                    ? Color(0xFF94A3B8)
                                    : Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _logout(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Cerrar Sesión",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    Navigator.of(context).pop(); // Close dialog

    // Navigate to login screen and clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  }
}
