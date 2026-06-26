// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Mino Chat';

  @override
  String get appTagline => 'Chatea sin límites.';

  @override
  String welcome(String app) {
    return 'Bienvenido a $app';
  }

  @override
  String get loginGoogle => 'Continuar con Google';

  @override
  String get startChatting => 'Empezar a chatear';

  @override
  String get setupProfile => 'Configura tu perfil';

  @override
  String get displayName => 'Nombre visible';

  @override
  String get bio => 'Bio (opcional)';

  @override
  String get chats => 'Chats';

  @override
  String get live => 'En vivo';

  @override
  String get mesh => 'Malla';

  @override
  String get channels => 'Canales';

  @override
  String get me => 'Yo';

  @override
  String get settings => 'Ajustes';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get newChannel => 'Nuevo canal';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get messagePlaceholder => 'Mensaje…';

  @override
  String get searchUsers => 'Buscar por nombre o correo…';

  @override
  String get send => 'Enviar';

  @override
  String get reply => 'Responder';

  @override
  String get forward => 'Reenviar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get copy => 'Copiar';

  @override
  String get react => 'Reaccionar';

  @override
  String get recording => 'Grabando…';

  @override
  String get liveBadge => 'EN VIVO';

  @override
  String get goLive => 'Ir en vivo';

  @override
  String get startRoom => 'Iniciar sala en vivo';

  @override
  String listening(int n) {
    return '$n escuchando';
  }

  @override
  String get raiseHand => 'Levantar mano';

  @override
  String get leave => 'Salir';

  @override
  String get offlineMesh => 'Malla sin conexión';

  @override
  String get scanning => 'Buscando usuarios Mino cercanos…';

  @override
  String get noInternet => '¿Sin internet? Sin problema.';

  @override
  String get stories => 'Historias';

  @override
  String get addStory => 'Agregar a historia';

  @override
  String get postStory => 'Publicar historia';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get readReceipts => 'Confirmaciones de lectura';

  @override
  String get lastSeen => 'Última vez visto';

  @override
  String madeBy(String author, String owner) {
    return 'Hecho por $author · $owner';
  }
}
