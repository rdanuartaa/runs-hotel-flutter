class MidtransConfig {
  static const String clientKey = String.fromEnvironment(
    'MIDTRANS_CLIENT_KEY',
    defaultValue: 'SB-Mid-client-rmKFix6Z2-8SRU_K',
  );

  static const bool isProduction = bool.fromEnvironment(
    'MIDTRANS_IS_PRODUCTION',
    defaultValue: false,
  );

  static String get snapBaseUrl => isProduction
      ? 'https://app.midtrans.com/snap/v2/vtweb/'
      : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';

  static const String finishCallbackUrl = 'hotelbooking://payment/finish';
}
