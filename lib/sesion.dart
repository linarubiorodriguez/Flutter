import 'package:shared_preferences/shared_preferences.dart';

class Sesion {
  static String? token;
  static String? id;

  static Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    id = prefs.getString("id");
  }

  static Future<void> cerrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("id");
    await prefs.remove("isLogged");
    await prefs.remove("rol");
  }
}
