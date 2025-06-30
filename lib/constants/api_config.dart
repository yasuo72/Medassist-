/// Centralised API endpoints for MedAssist+ backend.
/// Adjust [base] when switching between environments (dev / staging / prod).
class ApiConfig {
  // Change this to your deployed backend domain
  static const String base = 'https://medassistbackend-production.up.railway.app';

  // REST endpoints
  static const String chat = '$base/chat';

  // Medical records CRUD + AI summarisation
  static const String records = '$base/api/records';
}
