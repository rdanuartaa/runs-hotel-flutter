import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/booking/data/models/booking_model.dart';

class PdfService {
  static Future<void> generateAndShowETicket(BookingModel booking) async {
    final pdf = pw.Document();
    final formatDate = DateFormat('d MMMM yyyy', 'id_ID');
    final bool isCancelled = booking.status == 'cancelled' || booking.status == 'cancel_requested';
    
    // Warna khas ala tiket.com
    final colorBlue = PdfColor.fromHex('#0064D2');
    final colorYellow = PdfColor.fromHex('#FFD000');
    final colorGrey = PdfColors.grey700;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // HEADER SECTION
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // App Brand
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Runs', style: pw.TextStyle(color: colorBlue, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                              pw.Container(
                                margin: const pw.EdgeInsets.only(left: 2, right: 2, bottom: 6),
                                width: 14,
                                height: 14,
                                decoration: pw.BoxDecoration(color: colorYellow, shape: pw.BoxShape.circle),
                              ),
                              pw.Text('Hotel', style: pw.TextStyle(color: colorBlue, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Voucher Hotel', style: pw.TextStyle(color: colorBlue, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      
                      // Booking ID Pill
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Booking ID / Itinerary ID', style: pw.TextStyle(color: colorGrey, fontSize: 10)),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: colorBlue,
                              borderRadius: pw.BorderRadius.circular(20),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Text(booking.id.substring(0, 8).toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                              ]
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.grey300, thickness: 1),
                  pw.SizedBox(height: 16),
                  
                  // HOTEL & DATES SECTION
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Hotel Details
                      pw.Expanded(
                        flex: 6,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Text(booking.hotelName ?? 'Hotel Name', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                pw.SizedBox(width: 8),
                                pw.Row(
                                  children: List.generate(4, (index) => pw.Text('★', style: pw.TextStyle(color: colorYellow, fontSize: 16)))
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 12),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Expanded(child: pw.Text('${booking.hotelCity ?? 'City'}, Indonesia', style: pw.TextStyle(color: colorGrey, fontSize: 11, lineSpacing: 2))),
                              ]
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('+62 800 1234 5678', style: pw.TextStyle(color: colorGrey, fontSize: 11)),
                              ]
                            ),
                            
                            pw.SizedBox(height: 24),
                            
                            // Check in & out
                            pw.Row(
                              children: [
                                // Check-in
                                pw.Container(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border(left: pw.BorderSide(color: colorYellow, width: 4)),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Check-In', style: pw.TextStyle(color: colorGrey, fontSize: 11)),
                                      pw.SizedBox(height: 4),
                                      pw.Text(formatDate.format(booking.checkIn), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(width: 48),
                                // Check-out
                                pw.Container(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border(left: pw.BorderSide(color: colorYellow, width: 4)),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Check-Out', style: pw.TextStyle(color: colorGrey, fontSize: 11)),
                                      pw.SizedBox(height: 4),
                                      pw.Text(formatDate.format(booking.checkOut), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ),
                      ),
                      
                      // QR CODE
                      pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('SCAN UNTUK CHECK-IN/OUT', style: pw.TextStyle(color: colorGrey, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 8),
                              pw.BarcodeWidget(
                                data: booking.id,
                                barcode: pw.Barcode.qrCode(),
                                width: 120,
                                height: 120,
                              ),
                            ]
                          ),
                        ),
                      ),
                    ]
                  ),
                  
                  pw.SizedBox(height: 32),
                  
                  // DETAIL PEMESANAN TABLE
                  pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: pw.BoxDecoration(
                            color: colorBlue,
                            borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(3), topRight: pw.Radius.circular(3)),
                          ),
                          child: pw.Text('Detail Pemesanan', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                        ),
                        // Table Body
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(16),
                          child: pw.Column(
                            children: [
                              _buildTableRow('Tamu', ': ${booking.userName ?? 'Guest'}'),
                              _buildTableRow('Tipe Kamar', ': ${booking.roomType ?? '-'} - ${booking.roomName ?? '-'}'),
                              _buildTableRow('Jumlah Kamar', ': 1'),
                              _buildTableRow('Tamu per Kamar', ': ${booking.totalGuests}'),
                              _buildTableRow('Status Pembayaran', ': LUNAS / CONFIRMED', valueBold: true),
                              _buildTableRow('Permintaan Khusus', ': ${booking.specialRequest?.isNotEmpty == true ? booking.specialRequest : '-'}'),
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 16),
                  
                  // KEBIJAKAN PEMBATALAN
                  pw.Text('Kebijakan Pembatalan', style: pw.TextStyle(color: colorBlue, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 4, right: 8),
                        width: 4, height: 4, decoration: const pw.BoxDecoration(color: PdfColors.black, shape: pw.BoxShape.circle),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Pesanan dapat dibatalkan maksimal H-3 sebelum Check-In. Pengajuan refund akan diproses otomatis oleh sistem atau melalui transfer manual dari pihak hotel.',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ]
                  ),
                ],
              ),
              
              // WATERMARK JIKA DIBATALKAN
              if (isCancelled)
                pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.4,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red.shade(.6), width: 6),
                        borderRadius: pw.BorderRadius.circular(16),
                      ),
                      child: pw.Text(
                        'VOID / REFUNDED',
                        style: pw.TextStyle(
                          fontSize: 64,
                          color: PdfColors.red.shade(.6),
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Voucher_Hotel_${booking.id.substring(0,8)}.pdf',
    );
  }

  static pw.Widget _buildTableRow(String label, String value, {bool valueBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11)),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(value, style: pw.TextStyle(fontWeight: valueBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
