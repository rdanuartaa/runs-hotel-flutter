import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String snapRedirectUrl;
  final String bookingId;

  const PaymentWebViewScreen({
    super.key,
    required this.snapRedirectUrl,
    required this.bookingId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          if (request.url.contains('hotelbooking://payment/finish')) {
            context.go('/payment-status', extra: {'status': 'pending', 'bookingId': widget.bookingId});
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.snapRedirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Pembayaran', style: AppTextStyles.h4),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Pembayaran belum selesai. Yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
