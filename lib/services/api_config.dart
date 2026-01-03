class ApiConfig {
  // Directus base URL (NO /items here)
  static const String directusBaseUrl = "http://goatedcodoer:8056";

  // Collection endpoints
  static String items(String collection) => "$directusBaseUrl/items/$collection";

  // Specific helpers (optional but convenient)
  static String users() => items("user");
}
