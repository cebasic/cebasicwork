# Funcionalidades de Archivos CSV en el Chat de IA

## Descripción

Se han agregado nuevas funcionalidades al chat de IA para manejar respuestas que contengan enlaces a archivos CSV. Cuando el bot de IA responde con un enlace a un archivo CSV, la aplicación ahora puede:

1. **Detectar automáticamente** enlaces CSV en las respuestas
2. **Mostrar botones de acción** para cada archivo CSV encontrado
3. **Vista previa** del contenido del archivo CSV dentro de la aplicación
4. **Descargar** el archivo CSV abriéndolo en el navegador

## Formato de Respuesta Soportado

El sistema detecta automáticamente enlaces CSV que sigan este formato:

```
[Descargar archivo](https://ejemplo.com/archivo.csv)
```

### Ejemplo de Respuesta del Bot

```
Se obtuvieron 970 resultados sobre los iPhone 15 en existencia. [Descargar archivo](https://cebasictickets.s3.us-east-1.amazonaws.com/sqlbot/sqlresult-miguelt-2025-08-08-04:25:20.csv)

Para obtener esta información, realicé una consulta que une las tablas vw_Ctl_Articulos y vw_ExistenciasGlobales utilizando el campo IdArticulo. La consulta filtra los artículos cuyo nombre contenga 'iPhone 15' y verifica que tengan más de cero unidades en existencia.
```

## Funcionalidades Implementadas

### 1. Detección Automática de Enlaces CSV

- **Regex Pattern**: `\[Descargar archivo\]\((https?://[^\s)]+\.csv)\)`
- **Extracción**: Se extraen automáticamente todos los enlaces CSV de las respuestas
- **Limpieza**: Se elimina el texto del enlace del mensaje mostrado

### 2. Botones de Acción

Para cada archivo CSV detectado, se muestran dos botones:

- **Vista previa** (Verde): Abre una pantalla dedicada para previsualizar el contenido
- **Descargar** (Azul): Abre el enlace en el navegador para descargar el archivo

### 3. Pantalla de Vista Previa CSV

#### Características:
- **Carga automática** del contenido del archivo CSV
- **Tabla interactiva** con scroll horizontal y vertical
- **Información del archivo**: Muestra el número de filas de datos
- **Estados de carga**: Indicador de progreso mientras se carga
- **Manejo de errores**: Mensajes de error y botón de reintento
- **Botones adicionales** en la barra superior:
  - Descargar CSV
  - Abrir en navegador

#### Diseño:
- **Tema adaptativo**: Soporte para modo claro y oscuro
- **Colores consistentes**: Usa la paleta de colores de la aplicación
- **Responsive**: Se adapta a diferentes tamaños de pantalla

### 4. Funcionalidades de Descarga

- **URL Launcher**: Utiliza `url_launcher` para abrir enlaces externos
- **Modo externo**: Abre en el navegador predeterminado del dispositivo
- **Manejo de errores**: Muestra mensajes si no se puede abrir el enlace

## Dependencias Agregadas

```yaml
dependencies:
  webview_flutter: ^4.4.2
  url_launcher: ^6.0.17  # Ya estaba incluido
```

## Estructura del Código

### Clases Principales:

1. **`_AIBotViewState`**: Maneja la lógica principal del chat
   - `_extractCsvLinks()`: Extrae enlaces CSV del texto
   - `_buildCsvActionButtons()`: Crea botones de acción
   - `_previewCsv()`: Navega a la pantalla de vista previa
   - `_downloadCsv()`: Abre enlace en navegador

2. **`CsvPreviewScreen`**: Pantalla dedicada para vista previa
   - `_loadCsvContent()`: Descarga y parsea el contenido CSV
   - `_parseCsv()`: Convierte texto CSV en estructura de datos
   - `_buildBody()`: Construye la interfaz de usuario

### Métodos Clave:

```dart
// Extracción de enlaces CSV
List<String> _extractCsvLinks(String text)

// Parseo de contenido CSV
List<List<String>> _parseCsv(String csvContent)

// Construcción de botones de acción
Widget _buildCsvActionButtons(String csvUrl, bool isDark)
```

## Uso

1. **Envío de mensaje**: El usuario envía una pregunta al bot de IA
2. **Respuesta del bot**: Si la respuesta contiene enlaces CSV, se detectan automáticamente
3. **Botones de acción**: Se muestran botones para cada archivo CSV encontrado
4. **Vista previa**: Al tocar "Vista previa", se abre una nueva pantalla con el contenido
5. **Descarga**: Al tocar "Descargar", se abre el enlace en el navegador

## Consideraciones Técnicas

### Limitaciones:
- **Parseo simple**: El parseo CSV asume que no hay comas dentro de campos
- **Tamaño de archivo**: Archivos muy grandes pueden tardar en cargar
- **Formato de enlace**: Solo detecta enlaces con el formato específico

### Mejoras Futuras:
- Parseo CSV más robusto (manejo de comillas, escapes)
- Paginación para archivos grandes
- Filtros y búsqueda en la tabla
- Exportación directa desde la app
- Caché de archivos descargados

## Compatibilidad

- **Flutter**: 3.0.0+
- **Dart**: 2.17.0+
- **Plataformas**: iOS, Android, Web (con limitaciones en WebView)
