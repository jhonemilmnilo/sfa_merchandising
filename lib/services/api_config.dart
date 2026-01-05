class ApiConfig {
  // Directus base URL (NO /items here)
  static const String directusBaseUrl = "http://goatedcodoer:8056";

  // Collection endpoints: /items/{collection}
  static String items(String collection) => "$directusBaseUrl/items/$collection";

  // Single item endpoint: /items/{collection}/{id}
  static String itemById(String collection, Object id) =>
      "${items(collection)}/$id";

  // Specific helpers (optional but convenient)
  static String users() => items("user");
  static String userById(int userId) => itemById("user", userId);
}
