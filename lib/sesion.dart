class Sesion {
  static int? idUsuario;
  static String? token;

  static void cerrarSesion() {
    idUsuario = null;
    token = null;
  }
}
