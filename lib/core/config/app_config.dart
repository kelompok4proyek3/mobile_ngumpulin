  // class AppConfig {
  //   static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  //   static String get baseUrl => isProduction
  //       ? 'https://localhostnya.my.id/api'   // production domain
  //       : 'http://10.0.2.2/api';        // emulator → laptop
  // }

  class AppConfig {
  // Selalu pakai development URL dulu
  static String get baseUrl => 'https://localhostnya.my.id/api';
}