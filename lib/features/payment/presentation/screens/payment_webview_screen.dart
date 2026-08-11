import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
            _simulateWebhook(widget.bookingId).then((_) {
              if (mounted) {
                context.go('/payment-status', extra: {'status': 'success', 'bookingId': widget.bookingId});
              }
            });
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.snapRedirectUrl));
  }

  Future<void> _simulateWebhook(String bookingId) async {
    // Karena kita tidak memakai Edge Function (Webhook), kita update status manual via API Admin
    try {
      final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3eGhxZHdzcG5ycHZicnFtbXVjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjMzNzUzMywiZXhwIjoyMTAxOTEzNTMzfQ.dceuL-WMMCZd43PsJQayzc9lV9bBRW5DrwojJ29T5To';
      
      final adminClient = SupabaseClient(
        'https://bwxhqdwspnrpvbrqmmuc.supabase.co',
        serviceRoleKey,
      );
      
      // 1. Update payments table
      await adminClient.from('payments').update({'status': 'settlement'}).eq('booking_id', bookingId);
      
      // 2. Update bookings table
      await adminClient.from('bookings').update({'status': 'confirmed'}).eq('id', bookingId);
      
      debugPrint('Webhook bypass SUCCESS: Database updated!');
    } catch (e) {
      debugPrint('Webhook bypass failed: $e');
    }
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
