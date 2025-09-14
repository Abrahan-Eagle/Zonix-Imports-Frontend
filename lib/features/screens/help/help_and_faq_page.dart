import 'package:flutter/material.dart';

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

class HelpAndFAQPage extends StatelessWidget {
  const HelpAndFAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.lightGray,
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;
            final fontSize = isTablet ? 24.0 : 20.0;
            
            return Text(
              'Ayuda y Comentarios',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                letterSpacing: 0.5,
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? ZonixColors.darkGray
            : ZonixColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Bienvenido a la sección de Ayuda y Comentarios',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? ZonixColors.white
                    : ZonixColors.darkGray,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aquí encontrarás información útil sobre cómo utilizar la aplicación Zonix.',
              style: TextStyle(
                fontSize: 16,
                color: ZonixColors.mediumGray,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              color: ZonixColors.mediumGray.withOpacity(0.2),
              thickness: 1,
            ),
            const SizedBox(height: 20),
            _buildFAQItem(
              context,
              '¿Cómo registrarse en la aplicación?', // TODO: internacionalizar
              'Para registrarse en la aplicación Zonix, sigue estos pasos:\n\n'
              '1. Abre la aplicación y selecciona "Registrarse".\n'
              '2. Ingresa tu información personal, incluyendo nombre, dirección y número de contacto.\n'
              '3. Acepta los términos y condiciones.\n'
              '4. Haz clic en "Enviar" para completar el registro.\n'
              '5. Recibirás un correo electrónico de confirmación.',
            ),
            _buildFAQItem(
              context,
              '¿Cómo iniciar sesión?', // TODO: internacionalizar
              'Para iniciar sesión en tu cuenta Zonix, sigue estos pasos:\n\n'
              '1. Abre la aplicación y selecciona "Iniciar sesión".\n'
              '2. Ingresa tu dirección de correo electrónico y contraseña.\n'
              '3. Haz clic en "Iniciar sesión".\n'
              '4. Si olvidaste tu contraseña, puedes restablecerla desde la opción "Olvidé mi contraseña".',
            ),
            _buildFAQItem(
              context,
              '¿Cómo agendar una cita?', // TODO: internacionalizar
              'Para agendar una cita en Zonix, sigue estos pasos:\n\n'
              '1. Inicia sesión en tu cuenta.\n'
              '2. Selecciona "Agendar Cita" en el menú principal.\n'
              '3. Selecciona el restaurante que deseas y la fecha y hora de la cita.\n'
              '4. Revisa la información y haz clic en "Confirmar Cita".\n'
              '5. Recibirás un mensaje de confirmación de tu cita.',
            ),
            _buildFAQItem(
              context,
              '¿Qué hacer si tengo un problema?', // TODO: internacionalizar
              'Si tienes algún problema con la aplicación, por favor sigue estos pasos:\n\n'
              '1. Verifica tu conexión a internet.\n'
              '2. Reinicia la aplicación y vuelve a intentarlo.\n'
              '3. Si el problema persiste, dirígete a la sección de "Comentarios" para enviar tu consulta o reportar el problema.\n'
              '4. Nuestro equipo de soporte se pondrá en contacto contigo lo antes posible.',
            ),
            _buildFAQItem(
              context,
              '¿Cómo contactar al soporte?', // TODO: internacionalizar
              'Para contactar al soporte de Zonix, puedes:\n\n'
              '1. Enviar un correo electrónico a soporte@zonix.com.\n'
              '2. Utilizar el formulario de contacto en la aplicación.\n'
              '3. Visitar nuestra página web y utilizar el chat en vivo.',
            ),
            const SizedBox(height: 20),
            Divider(
              color: ZonixColors.mediumGray.withOpacity(0.2),
              thickness: 1,
            ),
            const SizedBox(height: 20),
            const Text(
              'Comentarios y Sugerencias', // TODO: internacionalizar
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nos encantaría saber de ti. Si tienes comentarios o sugerencias sobre la aplicación, por favor envíanos un mensaje utilizando el formulario de comentarios.', // TODO: internacionalizar
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Theme.of(context).brightness == Brightness.dark
          ? ZonixColors.darkGray
          : ZonixColors.white,
      shadowColor: ZonixColors.primaryBlue.withOpacity(0.15),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? ZonixColors.white
                : ZonixColors.darkGray,
            letterSpacing: 0.5,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                color: ZonixColors.mediumGray,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
