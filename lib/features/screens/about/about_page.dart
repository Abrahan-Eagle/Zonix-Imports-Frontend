import 'package:about/about.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'pubspec.dart';

// Paleta de colores profesional
class ZonixColors {
  static const Color primaryBlue = Color(0xFF1E40AF); // Azul profesional
  static const Color secondaryBlue = Color(0xFF3B82F6); // Azul secundario
  static const Color accentBlue = Color(0xFF60A5FA); // Azul de acento
  static const Color darkGray = Color(0xFF1E293B); // Gris oscuro
  static const Color mediumGray = Color(0xFF64748B); // Gris medio
  static const Color lightGray = Color(0xFFF1F5F9); // Gris claro
  static const Color white = Color(0xFFFFFFFF); // Blanco
  static const Color successGreen = Color(0xFF10B981); // Verde éxito
  static const Color warningOrange = Color(0xFFF59E0B); // Naranja advertencia
  static const Color errorRed = Color(0xFFEF4444); // Rojo error
  
  // Colores adicionales para efectos modernos
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color neumorphicLight = Color(0xFFFFFFFF);
  static const Color neumorphicDark = Color(0xFFE0E0E0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIos = theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.macOS;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? ZonixColors.darkGray
                : ZonixColors.lightGray,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: ZonixColors.primaryBlue,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando información...',
                    style: TextStyle(
                      color: ZonixColors.mediumGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final packageInfo = snapshot.data!;
        final aboutPage = AboutPage(
          values: {
            'version': packageInfo.version,
            'buildNumber': packageInfo.buildNumber,
            'year': DateTime.now().year.toString(),
            'author': Pubspec.authorsName.join(', '),
          },
          title: Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isTablet = screenWidth > 600;
              final fontSize = isTablet ? 28.0 : 24.0;
              
              return Text(
                'Acerca de Zonix',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? ZonixColors.white
                      : ZonixColors.darkGray,
                  letterSpacing: 0.5,
                ),
              );
            },
          ),
          applicationVersion: 'Versión ${packageInfo.version}, Build #${packageInfo.buildNumber}',
          applicationDescription: Text(
            getAppDescription(),
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 16,
              color: ZonixColors.mediumGray,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          applicationIcon: Container(
            margin: const EdgeInsets.only(bottom: 0), // Ajuste de margen sin valores negativos
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ajusta el tamaño de la imagen de acuerdo al ancho de la pantalla
                double imageSize = constraints.maxWidth * 0.3; // 60% del ancho de la pantalla

                return Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'assets/images/2.png'
                      : 'assets/images/1.png',
                  width: imageSize,
                  height: imageSize,
                );
              },
            ),
          ),
          applicationLegalese: '© ${DateTime.now().year} ${Pubspec.authorsName.join(', ')}. Todos los derechos reservados.',
          children: const <Widget>[
            MarkdownPageListTile(
              filename: 'README.md',
              title: Text('Ver Readme'),
              icon: Icon(Icons.all_inclusive),
            ),
            MarkdownPageListTile(
              filename: 'CHANGELOG.md',
              title: Text('Ver Cambios'),
              icon: Icon(Icons.view_list),
            ),
            MarkdownPageListTile(
              filename: 'LICENSE.md',
              title: Text('Ver Licencia'),
              icon: Icon(Icons.description),
            ),
            MarkdownPageListTile(
              filename: 'CONTRIBUTING.md',
              title: Text('Contribuciones'),
              icon: Icon(Icons.share),
            ),
            MarkdownPageListTile(
              filename: 'CODE_OF_CONDUCT.md',
              title: Text('Código de Conducta'),
              icon: Icon(Icons.sentiment_satisfied),
            ),
            LicensesPageListTile(
              title: Text('Licencias de Código Abierto'),
              icon: Icon(Icons.favorite),
            ),
          ],
        );

        return isIos ? _buildCupertinoApp(aboutPage) : _buildMaterialApp(aboutPage);
      },
    );
  }

  Widget _buildMaterialApp(Widget aboutPage) {
    return MaterialApp(
      title: 'Acerca de Zonix',
      debugShowCheckedModeBanner: false, // Quitar el banner de depuración
      home: SafeArea(child: aboutPage),
      theme: ThemeData(
        primaryColor: ZonixColors.primaryBlue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: ZonixColors.primaryBlue,
          foregroundColor: ZonixColors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: ZonixColors.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: ZonixColors.darkGray,
          foregroundColor: ZonixColors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoApp(Widget aboutPage) {
    return CupertinoApp(
      title: 'Acerca de Zonix (Cupertino)',
      home: SafeArea(child: aboutPage),
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
    );
  }
}
