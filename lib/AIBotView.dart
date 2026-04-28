import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AIBotView extends StatefulWidget {
  @override
  _AIBotViewState createState() => _AIBotViewState();
}

class _AIBotViewState extends State<AIBotView> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentUser = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
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
    _fadeController.forward();
    _getCurrentUser();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('user') ?? 'usuario';
    });
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text:
          "¡Hola! Soy tu asistente de IA y tengo acceso a ver registros en la base de datos del punto de venta ¿En qué puedo ayudarte hoy?",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    // Agregar un mensaje de prueba con enlace CSV para verificar la funcionalidad
    // _messages.add(ChatMessage(
    //   text:
    //       "Se obtuvieron 871 resultados para los iPhone 16 en existencia. Para esta consulta, uní las tablas vw_Ctl_Articulos y vw_ExistenciasGlobales utilizando el campo IdArticulo. Filtré los artículos para que sus descripciones incluyan 'iPhone 16' y comprobé que las existencias sean mayores a cero, lo que garantiza que solo se muestren los modelos actualmente disponibles. Puedes descargar los resultados [aquí](https://cebasictickets.s3.us-east-1.amazonaws.com/sqlbot/sqlresult-miguelt-2025-08-08-04:25:24.csv).",
    //   isUser: false,
    //   timestamp: DateTime.now(),
    // ));
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _sendToAI(userMessage);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text:
              "Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<String> _sendToAI(String message) async {
    final url = Uri.parse(
        'https://mobipay-n8n-c3b39ac1d2a0.herokuapp.com/webhook/ffd3b7be-02b8-4e97-af7c-a91a8957354b');

    final body = {
      "sessionId": _currentUser,
      "chatInput": message,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error en la comunicación con el bot');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF6366F1),
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Chat inteligente',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF111111) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Color(0xFFF8FAFC),
          ),
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return _buildTypingIndicator(isDark);
                    }
                    return _buildMessage(_messages[index], isDark);
                  },
                ),
              ),

              // Input area
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF111111) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Color(0xFF1A1A1A) : Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF1A1A1A) : Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Color(0xFF64748B)
                                  : Color(0xFF9CA3AF),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 24,
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
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDark) {
    final csvLinks = _extractCsvLinks(message.text);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Color(0xFF6366F1)
                    : (isDark ? Color(0xFF1A1A1A) : Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(20),
                border: !message.isUser
                    ? Border.all(
                        color: isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto del mensaje con enlaces detectados
                  _buildMessageText(message.text, isDark, message.isUser),

                  // Botones para archivos CSV si existen
                  if (csvLinks.isNotEmpty) ...[
                    SizedBox(height: 12),
                    ...csvLinks
                        .map((link) => _buildCsvActionButtons(link, isDark)),
                  ],

                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark ? Color(0xFF64748B) : Color(0xFF9CA3AF)),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageText(String text, bool isDark, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final csvLinks = _extractCsvLinks(text);

    if (csvLinks.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : colorScheme.onSurface,
          fontSize: 16,
        ),
      );
    }

    // Dividir el texto en partes para mostrar enlaces como botones
    String displayText = text;
    // Usar regex para reemplazar todos los enlaces CSV de una vez
    final linkRegex = RegExp(r'\[([^\]]+)\]\((https?://[^\s)]+\.csv)\)');
    displayText = displayText.replaceAll(linkRegex, '');

    // Limpiar espacios extra y líneas vacías
    displayText = displayText.trim();

    // Si el texto está vacío después de remover enlaces, mostrar un mensaje
    if (displayText.isEmpty) {
      displayText = 'Archivo CSV disponible para descarga.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: TextStyle(
            color: isUser ? Colors.white : colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCsvActionButtons(String csvUrl, bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _previewCsv(csvUrl),
              icon: Icon(Icons.visibility, size: 16),
              label: Text('Vista previa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _downloadCsv(csvUrl),
              icon: Icon(Icons.download, size: 16),
              label: Text('Descargar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractCsvLinks(String text) {
    // Regex que detecta enlaces CSV con cualquier texto entre corchetes
    final RegExp linkRegex = RegExp(r'\[([^\]]+)\]\((https?://[^\s)]+\.csv)\)');
    final matches = linkRegex.allMatches(text);
    final links = matches.map((match) => match.group(2)!).toList();

    // Debug: imprimir para verificar
    print('Texto original: $text');
    print('Enlaces encontrados: $links');

    return links;
  }

  void _previewCsv(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CsvPreviewScreen(csvUrl: url),
      ),
    );
  }

  void _downloadCsv(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('No se pudo abrir el enlace');
      }
    } catch (e) {
      _showErrorSnackBar('Error al abrir el enlace: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1A1A1A) : Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Color(0xFF475569) : Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color(0xFF6366F1).withOpacity(0.3 + (0.7 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class CsvPreviewScreen extends StatefulWidget {
  final String csvUrl;

  const CsvPreviewScreen({Key? key, required this.csvUrl}) : super(key: key);

  @override
  _CsvPreviewScreenState createState() => _CsvPreviewScreenState();
}

class _CsvPreviewScreenState extends State<CsvPreviewScreen> {
  bool _isLoading = true;
  List<List<String>> _csvData = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCsvContent();
  }

  Future<void> _loadCsvContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await http.get(Uri.parse(widget.csvUrl));

      if (response.statusCode == 200) {
        final content = response.body;
        setState(() {
          _csvData = _parseCsv(content);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar el archivo CSV: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el archivo CSV: $e';
        _isLoading = false;
      });
    }
  }

  List<List<String>> _parseCsv(String csvContent) {
    final lines = csvContent.split('\n');
    final data = <List<String>>[];

    for (String line in lines) {
      if (line.trim().isNotEmpty) {
        // Parsear CSV simple (asumiendo que no hay comas dentro de campos)
        final fields = line.split(',').map((field) => field.trim()).toList();
        data.add(fields);
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vista previa CSV',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF111111) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _downloadCsv(widget.csvUrl),
            tooltip: 'Descargar CSV',
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () => _openInBrowser(widget.csvUrl),
            tooltip: 'Abrir en navegador',
          ),
        ],
      ),
      body: Container(
        color: isDark ? Colors.black : Color(0xFFF8FAFC),
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando archivo CSV...',
              style: TextStyle(
                color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCsvContent,
              child: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_csvData.isEmpty) {
      return Center(
        child: Text(
          'No hay datos para mostrar',
          style: TextStyle(
            color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Información del archivo
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF111111) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Color(0xFF1A1A1A) : Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.table_chart,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Archivo CSV',
                      style: TextStyle(
                        color: isDark ? Color(0xFFF1F5F9) : Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_csvData.length} filas de datos',
                      style: TextStyle(
                        color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabla de datos
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: TextStyle(
                  color: isDark ? Color(0xFFF1F5F9) : Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                dataTextStyle: TextStyle(
                  color: isDark ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  fontSize: 13,
                ),
                columns: _csvData.isNotEmpty
                    ? _csvData[0]
                        .map((header) => DataColumn(label: Text(header)))
                        .toList()
                    : [],
                rows: _csvData.length > 1
                    ? _csvData.skip(1).map((row) {
                        return DataRow(
                          cells:
                              row.map((cell) => DataCell(Text(cell))).toList(),
                        );
                      }).toList()
                    : [],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _downloadCsv(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('No se pudo abrir el enlace');
      }
    } catch (e) {
      _showErrorSnackBar('Error al abrir el enlace: $e');
    }
  }

  void _openInBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('No se pudo abrir el enlace');
      }
    } catch (e) {
      _showErrorSnackBar('Error al abrir el enlace: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
