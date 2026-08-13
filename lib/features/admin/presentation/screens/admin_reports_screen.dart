import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../booking/presentation/cubit/booking_cubit.dart';
import '../../../booking/data/models/booking_model.dart';
import '../widgets/custom_charts.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _timeframe = 'Harian'; // Harian, Mingguan, Bulanan, Kustom
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back, color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Laporan & Keuangan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const Gap(16),
                  Text(state.message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () => context.read<BookingCubit>().loadAllBookings(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is AllBookingsLoaded) {
            return _buildDashboard(context, state.bookings);
          }
          
          return const SizedBox();
        },
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, List<BookingModel> bookings) {
    int totalPendapatan = 0;
    int totalRefund = 0;
    int pesananAktif = 0;
    int pesananSelesai = 0;

    // Hitung pemasukan per hotel
    Map<String, int> revenueByHotel = {};

    for (var b in bookings) {
      if (b.status == 'confirmed' || b.status == 'checked_in' || b.status == 'checked_out') {
        totalPendapatan += b.totalPrice;
        
        final hotel = b.hotelName ?? 'Unknown Hotel';
        revenueByHotel[hotel] = (revenueByHotel[hotel] ?? 0) + b.totalPrice;

        if (b.status == 'checked_out') {
          pesananSelesai++;
        } else {
          pesananAktif++;
        }
      } else if (b.status == 'cancelled') {
        totalRefund += b.totalPrice;
      }
    }

    // Sort hotel by revenue
    final sortedHotels = revenueByHotel.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // BIG REVENUE CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF5E8AF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Pendapatan Bersih', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
              const Gap(8),
              Text(
                formatCurrency.format(totalPendapatan),
                style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 32),
              ),
              const Gap(16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                  ),
                  const Gap(4),
                  Expanded(
                    child: Text('Hanya pesanan yang sudah dibayar (Confirmed/Selesai)', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
        const Gap(24),

        // STATS GRID
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pesanan Aktif',
                value: pesananAktif.toString(),
                icon: Icons.hotel,
                color: Colors.blue,
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildStatCard(
                title: 'Selesai',
                value: pesananSelesai.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Refund',
                value: formatCurrency.format(totalRefund),
                icon: Icons.money_off,
                color: Colors.red,
              ),
            ),
            const Gap(16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Semua',
                value: bookings.length.toString(),
                icon: Icons.analytics,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const Gap(32),

        // GRAFIK PENDAPATAN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tren Pendapatan', style: AppTextStyles.h4),
            DropdownButton<String>(
              value: _timeframe,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              items: ['Harian', 'Mingguan', 'Bulanan', 'Kustom'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'Kustom' && _customDateRange != null 
                    ? '${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}' 
                    : value),
                );
              }).toList(),
              onChanged: (val) async {
                if (val == 'Kustom') {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: AppColors.primary,
                          colorScheme: const ColorScheme.light(primary: AppColors.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _timeframe = 'Kustom';
                      _customDateRange = picked;
                    });
                  }
                } else if (val != null) {
                  setState(() {
                    _timeframe = val;
                    _customDateRange = null;
                  });
                }
              },
            ),
          ],
        ),
        const Gap(16),
        _buildTrendChart(bookings),
        const Gap(32),

        // PENDAPATAN PER HOTEL
        Text('Pendapatan per Hotel (Proporsi)', style: AppTextStyles.h4),
        const Gap(16),
        if (sortedHotels.isEmpty)
          const Text('Belum ada data pendapatan yang tercatat.', style: TextStyle(color: AppColors.textTertiary))
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                PieChartWidget(
                  data: revenueByHotel.map((k, v) => MapEntry(k, v.toDouble())),
                  colors: const [
                    AppColors.primary, 
                    Colors.orange, 
                    Colors.teal, 
                    Colors.purple, 
                    Colors.pink, 
                    Colors.indigo
                  ],
                ),
                const Gap(24),
                // Legend
                Column(
                  children: sortedHotels.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final hotel = entry.value;
                    final colors = const [AppColors.primary, Colors.orange, Colors.teal, Colors.purple, Colors.pink, Colors.indigo];
                    final color = colors[idx % colors.length];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const Gap(8),
                          Expanded(child: Text(hotel.key, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text(formatCurrency.format(hotel.value), style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        
        const Gap(32),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(12),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const Gap(4),
          Text(value, style: AppTextStyles.h4.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<BookingModel> bookings) {
    // Kumpulkan data chart
    final now = DateTime.now();
    Map<String, int> chartData = {};
    List<String> labels = [];

    // Valid booking filter (Hanya confirmed, checked_in, checked_out)
    final validBookings = bookings.where((b) => 
      b.status == 'confirmed' || b.status == 'checked_in' || b.status == 'checked_out'
    ).toList();

    if (_timeframe == 'Harian') {
      // 7 Hari Terakhir
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        labels.add(DateFormat('dd MMM').format(d));
        chartData[DateFormat('dd MMM').format(d)] = 0;
      }
      for (var b in validBookings) {
        final d = b.createdAt;
        if (now.difference(d).inDays <= 7 && now.isAfter(d)) {
          final label = DateFormat('dd MMM').format(d);
          if (chartData.containsKey(label)) chartData[label] = chartData[label]! + b.totalPrice;
        }
      }
    } else if (_timeframe == 'Mingguan') {
      // 4 Minggu Terakhir
      for (int i = 3; i >= 0; i--) {
        labels.add('W${4-i}');
        chartData['W${4-i}'] = 0;
      }
      for (var b in validBookings) {
        final d = b.createdAt;
        final diffDays = now.difference(d).inDays;
        if (diffDays <= 28 && diffDays >= 0) {
          final weekIndex = 4 - (diffDays ~/ 7);
          final label = 'W$weekIndex';
          if (chartData.containsKey(label)) chartData[label] = chartData[label]! + b.totalPrice;
        }
      }
    } else if (_timeframe == 'Bulanan') {
      // 6 Bulan Terakhir
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        labels.add(DateFormat('MMM').format(d));
        chartData[DateFormat('MMM').format(d)] = 0;
      }
      for (var b in validBookings) {
        final d = b.createdAt;
        final label = DateFormat('MMM').format(d);
        if (chartData.containsKey(label)) chartData[label] = chartData[label]! + b.totalPrice;
      }
    } else if (_timeframe == 'Kustom' && _customDateRange != null) {
      // Custom Range (Daily)
      final start = _customDateRange!.start;
      final end = _customDateRange!.end;
      final diff = end.difference(start).inDays;
      
      for (int i = 0; i <= diff; i++) {
        final d = start.add(Duration(days: i));
        labels.add(DateFormat('dd MMM').format(d));
        chartData[DateFormat('dd MMM').format(d)] = 0;
      }
      
      for (var b in validBookings) {
        final d = b.createdAt;
        // Strip time for accurate day matching
        final dDate = DateTime(d.year, d.month, d.day);
        final sDate = DateTime(start.year, start.month, start.day);
        final eDate = DateTime(end.year, end.month, end.day);
        
        if (dDate.isAfter(sDate.subtract(const Duration(days: 1))) && 
            dDate.isBefore(eDate.add(const Duration(days: 1)))) {
          final label = DateFormat('dd MMM').format(d);
          if (chartData.containsKey(label)) chartData[label] = chartData[label]! + b.totalPrice;
        }
      }
    }

    // Extract values for area chart
    final values = labels.map((l) => chartData[l]!.toDouble()).toList();

    // Hitung lebar dinamis agar label tidak bertumpuk jika jumlah hari banyak
    final double minChartWidth = MediaQuery.of(context).size.width - 64; // width standard
    final double dynamicWidth = labels.length * 50.0;
    final chartWidth = dynamicWidth > minChartWidth ? dynamicWidth : minChartWidth;

    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: chartWidth,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AreaChartWidget(
            values: values,
            labels: labels,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
