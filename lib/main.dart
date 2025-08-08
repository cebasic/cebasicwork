import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'CEBasic Work'),
        '/dashboard': (context) => Dashboard(),
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF3B82F6),
          surface: Colors.white,
          background: Colors.white,
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1F2937),
          onBackground: Color(0xFF1F2937),
          onError: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: Color(0xFF0F172A),
        cardColor: Color(0xFF1E293B),
        dialogBackgroundColor: Color(0xFF1E293B),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFF1F5F9),
          onBackground: Color(0xFFF1F5F9),
          onError: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class MyHomePage extends StatefulWidget {
  String title = "";
  MyHomePage({Key? key, required this.title}) : super(key: key);
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController userController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
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
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });

    getStringValuesSF("user");
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ]
                : [
                    Color(0xFF1E3A8A),
                    Color(0xFF3B82F6),
                    Color(0xFF10B981),
                  ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.02)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Color(0xFF1E293B).withOpacity(0.95)
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
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
                          // Logo with animation
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Color(0xFF10B981).withOpacity(0.2)
                                  : Color(0xFF10B981).withOpacity(0.1),
                            ),
                            child: Image(
                              image: AssetImage('images/logot.png'),
                              height: 80,
                              width: 80,
                            ),
                          ),

                          SizedBox(height: 30),

                          // Welcome text
                          Text(
                            'Bienvenido',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'Inicia sesión en tu cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Color(0xFF94A3B8)
                                  : Color(0xFF6B7280),
                            ),
                          ),

                          SizedBox(height: 40),

                          // Username field
                          _buildTextField(
                            controller: userController,
                            hintText: 'Usuario',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.text,
                            isDark: isDark,
                          ),

                          SizedBox(height: 20),

                          // Password field
                          _buildTextField(
                            controller: passController,
                            hintText: 'Contraseña',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            isDark: isDark,
                          ),

                          SizedBox(height: 30),

                          // Login button
                          _buildLoginButton(isDark: isDark),

                          SizedBox(height: 20),

                          // Help text
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Color(0xFF334155)
                                  : Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                              border: isDark
                                  ? Border.all(
                                      color: Color(0xFF475569),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: isDark
                                      ? Color(0xFF94A3B8)
                                      : Color(0xFF6B7280),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Usa tu usuario y contraseña del sistema de punto de venta',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Color(0xFF94A3B8)
                                          : Color(0xFF6B7280),
                                    ),
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
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.7)
                      : Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
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
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981)),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Iniciando sesión...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF334155) : Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Color(0xFFF1F5F9) : Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Color(0xFF64748B) : Color(0xFF9CA3AF),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({required bool isDark}) {
    return Container(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _loginButtonClickHandler,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Color(0xFF10B981).withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _loginButtonClickHandler() {
    var username = userController.text.trim();
    var password = passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showFancyDialog(
        "Campos Requeridos",
        "Por favor, completa todos los campos",
        Icons.warning_amber_rounded,
        Colors.orange,
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      login(username, password).then((response) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          _isLoading = false;
        });
        _showFancyDialog(
          "Error de Conexión",
          "No se pudo conectar al servidor",
          Icons.error_outline,
          Colors.red,
        );
      });
    }
  }

  login(u, p) async {
    String urla = 'https://cebasicapi-node-caab21788dab.herokuapp.com/auth/' +
        u +
        '/' +
        p;
    print(urla);
    Uri url = Uri.parse(urla);
    final response = await http.get(url);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      if (responseJson['results'] == true) {
        addStringToSF("user", u);
        if (responseJson['isadmin'] == 1) {
          addStringToSF("admin", "1");
        } else {
          addStringToSF("admin", "0");
        }
        Future<dynamic> responseuser = getStringValuesSF("user");
        _navigateToNextScreen(context);
      } else {
        _showFancyDialog(
          "Credenciales Incorrectas",
          "El usuario o contraseña son incorrectos",
          Icons.lock_outline,
          Colors.red,
        );
        passController.clear();
      }
      return responseJson['results'];
    } else {
      _showFancyDialog(
        "Error de Conexión",
        "No se pudo conectar al servidor",
        Icons.wifi_off,
        Colors.red,
      );
    }
  }

  void _navigateToNextScreen(BuildContext context) {
    passController.clear();
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  void _showFancyDialog(
      String title, String message, IconData icon, Color color) {
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
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Entendido',
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

  addStringToSF(id, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(id, value);
  }

  getStringValuesSF(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString(id);
    if (stringValue != null) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      print("Sin user guardado");
    }
    return stringValue;
  }
}

class AuthModel {
  int userId = 0;
  int pass = 0;
  AuthModel({required this.userId, required this.pass});
  AuthModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    pass = json['id'];
  }
}
