// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeSubtitle => 'Activar o desactivar el tema oscuro';

  @override
  String get appearanceSectionTitle => 'Apariencia';

  @override
  String get languageRegionSectionTitle => 'Idioma y Región';

  @override
  String get appLanguageDropdownTitle => 'Idioma de la Aplicación';

  @override
  String get homeAppBarTitle => 'MedAssist+';

  @override
  String get profileTooltip => 'Perfil';

  @override
  String homeGreeting(String userName) {
    return 'Hola, $userName 👋';
  }

  @override
  String get homeSectionTitleKeyStats => 'Tus Estadísticas Clave';

  @override
  String get statLabelBloodType => 'Tipo de Sangre';

  @override
  String get statLabelAllergies => 'Alergias';

  @override
  String get statLabelMedication => 'Medicación';

  @override
  String get statLabelConditions => 'Condiciones';

  @override
  String get homeSectionTitleQuickActions => 'Acciones Rápidas';

  @override
  String get actionLabelMedicalSummary => 'Resumen Médico';

  @override
  String get actionLabelFamilyManagement => 'Gestión Familiar';

  @override
  String get actionLabelEmergencyContacts => 'Contactos de Emergencia';

  @override
  String get actionLabelAppSettings => 'Ajustes de App';

  @override
  String get homeFabLabelEmergencyId => 'ID de Emergencia';

  @override
  String get profileUpdated => '¡Perfil Actualizado!';

  @override
  String get notSet => 'No Establecido';

  @override
  String get featureComingSoon => '¡Característica Próximamente!';

  @override
  String get statLabelMedicalReports => 'Informes Médicos';

  @override
  String get filesSuffix => 'archivos';
}
