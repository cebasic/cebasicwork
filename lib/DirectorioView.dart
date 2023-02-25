import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_launch/flutter_launch.dart';

class DirectorioView extends StatelessWidget {
  const DirectorioView({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Directorio"),
      ),
      body: ListView(
        children: [
          // -Plaza Lomita: Prol. Álvaro Obregón 1796 Sur- Local 2, Colinas de San Miguel. Cp. 80228 tel. 6671460879 Correo: lomita@cebasic.com
          // -Modulo Galerias San Miguel: Prol. Álvaro Obregón 1880 SUR-S/N, Colinas de San Miguel, 80228 Culiacán Rosales, Sin Tel. 6675032726 correo: mgalerias@cebasic.com
          // -Galerias San Miguel:Prol. Álvaro Obregón 1880 SUR-S/N, Colinas de San Miguel, 80228 Culiacán Rosales, Sin Tel. 6671460714 correo: galerias@cebasic.com
          // -Galerias San Miguel 3:Prol. Álvaro Obregón 1880 SUR-S/N Local 19B, Colinas de San Miguel, 80228 Culiacán Rosales, SinTel. 6671709765 correo: galerias2@cebasic.com
          // -Bodega Aurrera:Mercado de Abastos, 80299 Culiacán Rosales, Sintel. 6677182218 correo: baurrera@cebasic.com
          // -Isla Musala: Blvd. Isla Musalá NUM. 1479, Fracc Musalá Isla Bonita, MUSALA, 80065 Culiacán Rosales, Sin.tel. 6671463981 correo: isla@cebasic.com
          // -Plaza Fiesta: De Los Insurgentes 1601, Centro Sinaloa, Centro, 80200 Culiacán Rosales, Sin.Tel: 6676483100 correo: pfiesta@cebasic.com
          // -Sendero:Sendero Culiacán Boulevard José Limon, Humaya No. 2545 Local C19, C.P. 8002 Culiacán Rosales, Sin.Tel.6671133701 correo: sendero@cebasic.com
          // -Modulo Valle:Blvd. Emiliano Zapata, Gasolinera del Valle, San Rafael, 80150 Culiacán Rosales, Sin.Tel.6677215353 correo: mvalle@cebasic.com
          // -Plaza Valle:Blvd. Emiliano Zapata Local 4, Gasolinera del Valle, San Rafael, 80150 Culiacán Rosales, Sin.Tel. 6677215784 correo: valle@cebasic.com
          // -Plaza Humaya:Gral. Ignacio Ramírez 1125, Jorge Almada.tel. 6677100956 Correo: humaya@cebasic.com
          // -Plaza Forum:BLVD. JOSE, Diego Valadés Ríos 1676 PTE, Desarrollo Urbano Tres Ríos, 80060 Culiacán Rosales, Sintel. 6677126617 correo: forum@cebasic.com
          // -Cuatro Rios-Blvd Enrique Sanchez Alonso #2079 N Local A-043A, Plaza Cuatro Rios Fracc. 3 Rios, c.p.: 80020 Tel. Correo: cuatrorios@cebasic.com
          // -Plaza Paseo Oasis:Carretera a imala #2880 nte. Local 2, ejido tierra blanca c.p. 80014tel.6671706357 correo: oasis@cebasic.com
          _tile("lomita@cebasic.com", "6671460879", "Plaza Lomita", ""),
          _tile("mgalerias@cebasic.com", "6675032726",
              "Modulo Galerias San Miguel", ""),
          _tile(
              "galerias@cebasic.com", "6671460714", "Galerias San Miguel", ""),
          _tile("galerias2@cebasic.com", "6671709765", "Galerias San Miguel 2",
              ""),
          _tile("baurrera@cebasic.com", "6677182218", "Bodega Aurrera", ""),
          _tile("isla@cebasic.com", "6671463981", "Isla Musala", ""),
          _tile("pfiesta@cebasic.com", "6676483100", "Plaza Fiesta", ""),
          _tile("sendero@cebasic.com", "6671133701", "Sendero", ""),
          _tile("mvalle@cebasic.com", "6677215353", "Modulo Valle", ""),
          _tile("valle@cebasic.com", "6677215784", "Plaza Valle", ""),
          _tile("humaya@cebasic.com", "6677100956", "Plaza Humaya", ""),
          _tile("forum@cebasic.com", "6677126617", "Forum", ""),
          _tile("cuatrorios@cebasic.com", "6671709273", "Cuatro Rios", ""),
          _tile("oasis@cebasic.com", "6671706357", "Paseo Oasis", ""),
          // _tile("", "", "Mazatlan", ""),
          // Mazatlán
          // Plaza Patio:Carretera Internacional y Libramiento Culiacán, Local 9, C.P.82190 Mazatlán, Sin. Tel.  6699803411 Correo: patio@cebasic.com
          // Plaza Santa Rosa: Av Sta Rosa 17301 Local 1, Valle Dorado, 82132 Mazatlán, Sin. Tel. 669 688 2046 correo: santarosa@cebasic.com
          // Galerias MazatlánAv. De la Marina 6204 Local 6, Cp. 82103, Desarrollo residencial turistico Marina MazatlánTel. 6692795264 Correo: galeriasmzt@cebasic.com
          // Gran Plaza E10 Av. Reforma s/n, Alameda. Local E10, 82123 Mazatlán, Sin.Tel. 6696889148 correo: E10@cebasic.com
          // Gran plaza Av. Reforma s/n, Alameda. Local u1 y u2, 82123 Mazatlán, Sin.Tel.6699833485 correo: granplaza@cebasic.com
          _tile("patio@cebasic.com", "6699803411", "Plaza Patio", ""),
          _tile("santarosa@cebasic.com", "6696882046", "Plaza Santa Rosa", ""),
          _tile(
              "galeriasmzt@cebasic.com", "6692795264", "Galerias Mazatlan", ""),
          _tile("e10@cebasic.com", "6696889148", "Gran Plaza E10", ""),
          _tile("granplaza@cebasic.com", "6699833485", "Gran Plaza", ""),
          // Reparaciones:Cellfix Mzt:tel 6699833128 correo: cellfix@cebasic.com
          // Reparaciones Bodega Aurrera Tel. 6677182218 correo: reparacionaurrera@cebasic.com
          // Reparaciones Plaza Humaya Tel. 6677100956 correo: reparacionhumaya@cebasic.com
          // Reparaciones Isla: Tel. 6671463981 correo: reparacionisla@cebasic.com
          // Reparaciones Plaza Santa Rosa: Tel. 6696882046 correo: reparacionsr@cebasic.com
          // Reparaciones Plaza Valle: Tel. 6677215784 correo: reparacionvalle@cebasic.com
          // Reparaciones Lomita: Tel. 667 146 0879 correo: reparacionlomita@cebasic.com
          _tile("cellfix@cebasic.com", "6699833128", "Cellfix Mzt", ""),
          _tile("reparacionaurrera@cebasic.com", "6677182218",
              "Reparaciones Aurrera", ""),
          _tile("reparacionhumaya@cebasic.com", "6677100956",
              "Reparaciones Humaya", ""),
          _tile("reparacionisla@cebasic.com", "6671463981", "Reparaciones Isla",
              ""),
          _tile("reparacionsr@cebasic.com", "6696882046",
              "Reparaciones Plaza Santa Rosa", ""),
          _tile("reparacionvalle@cebasic.com", "6677215784",
              "Reparaciones Plaza Valle", ""),
          _tile("reparacionlomita@cebasic.com", "6671460879",
              "Reparaciones Plaza Lomita", ""),
          // Administrativos:
          // Director: Miguel Torrontegui Correo: director@cebasic.com
          // Recursos Humanos:
          // America Iribe: tel: 6673080900 correo:recursos@cebasic.com
          // Finanzas: Tel: 6673080900 Correo: finanzas@cebasic.com
          // Contabilidad:Arturo Carmona Tel: 6674310282 correo: contabilidad@cebasic.com
          // Cadenas comerciales:Ivan Sandoval.correo: cadenas@cebasic.com
          _tile("director@cebasic.com", "", "Miguel Torrontegui", ""),
          _tile("recursos@cebasic.com", "6673080900", "America Iribe", ""),
          _tile("recursos2@cebasic.com", "6672060481", "Dalia Arce", ""),
          _tile("finanzas@cebasic.com", "6673080900", "Finanzas", ""),
          _tile("contabilidad@cebasic.com", "6674310282",
              "Contabilidad - Arturo Carmona", ""),
          _tile("cadenas@cebasic.com", "",
              "Cadenas comerciales - Ivan Sandoval", ""),

          // Almacen 1 Leonardo Sanchez Tel: 6671540474 Correo: almacen1@cebasic.com
          // Almacen 2 Juan Pablo Tel. 6671010840 correo: almacen2@cebasic.com
          //Almacen 3 Sofia PayanTel. 6672928909 correo: almacen3@cebasic.com
          // Almacen 4 Isabel Huerta Tel. 6672926900 correo: almacen4@cebasic.com
          // Almacen 5 Yesica Cardenas Correo: almacen5@cebasic.com
          // Auditoria:Fabiola Rodriguez correo: auditoria@cebasic.com
          // Auditoria y Operaciones
          // Luis Guzman correo: operaciones1@cebasic.com
          // Erick Meza correo: operaciones2@cebasic.com
          // Garantias:
          // Jorge Rojo/ Saturnino Gaxiolacorreo: garantias@cebasic.com
          // Ecommerce:
          // Elias Gamez Tel.6672454125 correo: somos@cebasic.com
          // Mercadotenia:
          // Cristell GamezTel. 6676938366 correo: mercadotecnia@cebasic.com
          // Credibasic:Manuel Bustamante Tel. 6672646767 correo: contacto@cebasic.com
          // Planes Telcel:Francisco MadaTel.6677100956 correo: planes@cebasic.com
          // Auxiliar Administrativo: Dalia ArceTel: 6672060481 Correo: recursos2@cebasic.com
          // Diseño Grafico:
          // Maria Jose Gonzalez Tel: Correo: artegrafica@cebasic.com
          _tile("almacen1@cebasic.com", "6671540474",
              "Almacen teléfonos - Leonardo Sanchez", ""),
          _tile("almacen2@cebasic.com", "6671010840",
              "Almacen teléfonos - Juan Pablo", ""),
          _tile("almacen3@cebasic.com", "6672928909",
              "Almacen accesorios - Sofia Payan", ""),
          _tile("almacen4@cebasic.com", "6672926900",
              "Almacen accesorios - Isabel Huerta", ""),
          _tile("almacen5@cebasic.com", "",
              "Almacen accesorios - Yesica Cardenas", ""),
          // _tile(
          //     "auditoria@cebasic.com", "", "Auditoria - Fabiola Rodriguez", ""),
          // _tile("operaciones1@cebasic.com", "6675032666",
          //     "Auditoria y Operaciones - Luis Guzman", ""),
          _tile("operaciones2@cebasic.com", "6674075833",
              "Auditoria y Operaciones - Erick Meza", ""),
          _tile("garantias@cebasic.com", "",
              "Garantias - Jorge Rojo/Saturnino Gaxiola", ""),
          _tile(
              "somos@cebasic.com", "6672454125", "Ecommerce - Elias Gamez", ""),
          _tile("mercadotecnia@cebasic.com", "6676938366",
              "Mercadotecnia - Cristell Gamez", ""),
          _tile("contacto@cebasic.com", "6672646767",
              "Credibasic - Manuel Bustamante", ""),
          _tile("planes@cebasic.com", "6677100956",
              "Planes Telcel - Francisco Mada", ""),
          _tile("artegrafica@cebasic.com", "",
              "Diseño Grafico - Maria Jose Gonzalez", ""),

// OLD
          // _tile("EXPERTOSCELULAR@HOTMAIL.COM", "6677607309",
          //     "ALMACEN TELÉFONOS", ""),
          // _tile("contacto@cebasic.COM", "6677607309", "Ecommerce", ""),
          // //    _tile("BASIC.AEROPUERTO@HOTMAIL.COM", "6677122597", "AEROPUERTO", ""),
          // _tile("HUMAYA.BASIC@HOTMAIL.COM", "6677100956", "Humaya", ""),
          // _tile("TELCEL.BASIC@HOTMAIL.COM", "6677100956",
          //     "Oficina Francisco Mada", ""),
          // _tile("CELLFIX.VALLE@HOTMAIL.COM", "6677215784", "Tienda Valle", ""),
          // _tile(
          //     "MODULO.VALLE360@HOTMAIL.COM", "6677215353", "Módulo Valle", ""),
          // _tile("boombox.valle@gmail.com", "6675032737", "Boombox Valle", ""),
          // // _tile("VALLEM3.BASIC@HOTMAIL.COM", "", "BOOMBOX"),
          // _tile("BASIC.AURRERA@HOTMAIL.COM", "6677182218",
          //     "Bodega Aurrera Patria", ""),
          // _tile("GALETIENDA2014@OUTLOOK.COM", "6671460714", "Galerías Tienda",
          //     ""),
          // _tile("Basic.fiesta@hotmail.com", "6676483100", "Plaza Fiesta", ""),
          // _tile("sendero.cebasic@gmail.com", "6671133701", "Sendero", ""),

          // _tile("CELULARBASIC_GALERIAS@HOTMAIL.COM", "6675032726",
          //     "Galerías Kiosko", ""),
          // _tile("BASIC.LOMITA@HOTMAIL.COM", "6671460879", "Lomita", ""),
          // _tile("CELULARBASIC_FORUM@LIVE.COM", "6677126617", "Forum", ""),
          // _tile("ISLA.BASIC@HOTMAIL.COM", "6671463981", "Isla Musala", ""),
          // _tile(
          //     "GRANPLAZAMZT.BASIC@HOTMAIL.COM", "6699833485", "Gran Plaza", ""),
          // _tile("GRANPLAZA.CELLFIX@HOTMAIL.COM", "6699833128",
          //     "Cellfix Mazatlán", ""),
          // //_tile("BIGPLAZA.BASIC@HOTMAIL.COM", "6699831653", "BIG PLAZA", ""),
          // _tile("MAZATLANE10.BASIC@HOTMAIL.COM", "6696889148", "E10", ""),
          // _tile("SANTAROSA.BASIC@HOTMAIL.COM", "6696882046", "SANTA ROSA", ""),
          // _tile("PATIO.BASIC@HOTMAIL.COM", "6699803411", "PATIO", ""),
          // // _tile("", "6699683270", "TABLET CENTER"),
          // _tile("GALERIASMAZATLAN@OUTLOOK.COM", "6692705264",
          //     "GALERIAS MAZATLAN", ""),
          // _tile("BASIC.LEONARDO@HOTMAIL.COM", "6671540474", "LEONARDO", ""),
          // _tile("ARCARMU66@HOTMAIL.COM", "6674310282", "ARTURO CARMONA", ""),
          // _tile("JUANPAZ.BASIC@GMAIL.COM", "6671010840", "JUAN PABLO", ""),
          // _tile(
          //     "LUISGUZMAN.BASIC@OUTLOOK.COM", "6675032666", "LUIS GUZMAN", ""),
          // _tile("AMERICAIR.BASIC@GMAIL.COM", "6673080900", "AMERICA", ""),
          // _tile("BUSTAMANTELUJANO@GMAIL.COM", "6672646767", "MANUEL", ""),
          // _tile("SOFIA.BASIC@HOTMAIL.COM", "6672928909", "SOFIA", ""),
          // _tile("ISABELH.BASIC@HOTMAIL.COM", "6672926900", "ISABEL", ""),
        ],
      ),
    );
  }

  Card _tile(String correo, String tel, String title, String whatsapp) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon(Icons.store_mall_directory),
          // SizedBox(
          //   width: 15,
          // ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(correo.toLowerCase()),
              ],
            ),
          ),
          whatsapp == ""
              ? SizedBox(
                  width: 10,
                )
              : IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                    _launchWSP(tel);
                  },
                ),
          tel == ""
              ? SizedBox(
                  width: 10,
                )
              : IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                    _calling(tel);
                  },
                ),
        ],
      ),
    ));
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
      // whatsapp://send?text=Hello World!&phone=+
      await launch('whatsapp://send?text=Hello World!&phone=+521' + telp);
      // await FlutterLaunch.launchWathsApp(phone: "+521$telp", message: "Hello");
    } catch (e) {
      print(e);
    }
  }
}
