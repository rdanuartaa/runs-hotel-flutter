import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../hotel/presentation/cubit/hotel_cubit.dart';

import '../../../hotel/data/models/hotel_model.dart';

class AdminAddHotelScreen extends StatefulWidget {
  final HotelModel? hotel;
  const AdminAddHotelScreen({super.key, this.hotel});

  @override
  State<AdminAddHotelScreen> createState() => _AdminAddHotelScreenState();
}

class _AdminAddHotelScreenState extends State<AdminAddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _starController = TextEditingController(text: '3');
  final _thumbnailController = TextEditingController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  File? _selectedImage;
  bool _isUploadingImage = false;

  final List<String> _availableFacilities = [
    'Wi-Fi gratis',
    'Kolam renang',
    'Restoran',
    'Cafe',
    'Parkir gratis',
    'Resepsionis 24 jam',
    'Gym',
    'Spa',
    'Laundry',
    'Lift',
    'Ruang meeting',
    'Layanan kamar',
    'Antar-jemput bandara',
    'Penyewaan kendaraan',
    'Area merokok',
    'Taman',
  ];
  final List<String> _selectedFacilities = [];

  final List<Map<String, dynamic>> _mockHotels = [
    {
      'name': 'Hotel Indonesia Kempinski Jakarta',
      'display_name': 'Hotel Indonesia Kempinski Jakarta',
      'street_address': 'Jl. M.H. Thamrin No.1, Menteng, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10310',
      'address': {'city': 'Jakarta Pusat', 'state': 'DKI Jakarta'},
      'lat': '-6.194917',
      'lon': '106.822557',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'WiFi, Kolam Renang, Spa, Gym, Restoran, Parkir Valet',
      'description': 'Hotel mewah ikonik di jantung kota Jakarta dengan pemandangan Bundaran HI.',
      'is_mock': true,
    },
    {
      'name': 'The Ritz-Carlton Bali',
      'display_name': 'The Ritz-Carlton Bali',
      'street_address': 'Jalan Raya Nusa Dua Selatan Lot III, Sawangan, Nusa Dua, Kabupaten Badung, Bali 80363',
      'address': {'city': 'Badung', 'state': 'Bali'},
      'lat': '-8.825227',
      'lon': '115.218525',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'Private Beach, WiFi, Spa, Infinity Pool, Gym, Kids Club',
      'description': 'Resor tepi laut yang menakjubkan dengan pemandangan Samudra Hindia.',
      'is_mock': true,
    },
    {
      'name': 'Padma Hotel Bandung',
      'display_name': 'Padma Hotel Bandung',
      'street_address': 'Jl. Ranca Bentang No.56-58, Ciumbuleuit, Kec. Cidadap, Kota Bandung, Jawa Barat 40142',
      'address': {'city': 'Bandung', 'state': 'Jawa Barat'},
      'lat': '-6.850729',
      'lon': '107.603378',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'WiFi, Kolam Renang Air Hangat, Gym, Restoran, Layanan Jemput',
      'description': 'Hotel elegan yang menawarkan pemandangan bukit hijau yang spektakuler.',
      'is_mock': true,
    },
    {
      'name': 'Tentrem Yogyakarta',
      'display_name': 'Hotel Tentrem Yogyakarta',
      'street_address': 'Jl. P. Mangkubumi No.72A, Cokrodiningratan, Kec. Jetis, Kota Yogyakarta, Daerah Istimewa Yogyakarta 55233',
      'address': {'city': 'Yogyakarta', 'state': 'DI Yogyakarta'},
      'lat': '-7.771960',
      'lon': '110.368735',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1542314831-c6a4d27160c1?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'WiFi, Kolam Renang Mewah, Spa Tradisional, Pusat Kebugaran, Galeri Seni',
      'description': 'Hotel bintang lima yang menggabungkan kemewahan modern dengan sentuhan tradisional Jawa.',
      'is_mock': true,
    },
    {
      'name': 'Ayana Resort and Spa Bali',
      'display_name': 'Ayana Resort and Spa, Bali',
      'street_address': 'Jl. Karang Mas Sejahtera, Jimbaran, Kec. Kuta Sel., Kabupaten Badung, Bali 80364',
      'address': {'city': 'Badung', 'state': 'Bali'},
      'lat': '-8.7844',
      'lon': '115.1417',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'Rock Bar, 12 Kolam Renang, Private Beach, Spa On The Rocks, Kids Club, Lapangan Golf',
      'description': 'Resor terkemuka di Bali dengan pemandangan tebing Jimbaran yang tiada duanya.',
      'is_mock': true,
    },
    {
      'name': 'Amanjiwo Borobudur',
      'display_name': 'Amanjiwo, Borobudur',
      'street_address': 'Sawah, Majaksingi, Borobudur, Magelang Regency, Central Java 56553',
      'address': {'city': 'Magelang', 'state': 'Jawa Tengah'},
      'lat': '-7.6186',
      'lon': '110.1917',
      'star': '5',
      'thumbnail': 'https://images.unsplash.com/photo-1585552309506-692fc3b53c65?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'facilities': 'Private Pool, Pemandangan Candi Borobudur, Spa Tradisional, Restoran Mewah',
      'description': 'Resor ultra-mewah berbentuk stupa yang menghadap langsung ke Candi Borobudur.',
      'is_mock': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      final h = widget.hotel!;
      _nameController.text = h.name;
      _descriptionController.text = h.description ?? '';
      _addressController.text = h.address;
      _cityController.text = h.city;
      _provinceController.text = h.province ?? '';
      _latController.text = h.latitude.toString();
      _lonController.text = h.longitude.toString();
      _starController.text = h.starRating.toString();
      _thumbnailController.text = h.thumbnailUrl ?? '';
      
      _selectedFacilities.clear();
      for (var f in h.facilities) {
        if (!_availableFacilities.contains(f)) {
          _availableFacilities.add(f);
        }
        _selectedFacilities.add(f);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _starController.dispose();
    _thumbnailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    
    // 1. Search in our smart mock database first
    List<Map<String, dynamic>> mockResults = _mockHotels
        .where((h) => h['name'].toString().toLowerCase().contains(query.toLowerCase()) || 
                      h['address']['city'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    try {
      // 2. Search OpenStreetMap as fallback
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&countrycodes=id');
      final response = await http.get(url, headers: {'User-Agent': 'HotelAppAdmin/1.0'});
      if (response.statusCode == 200) {
        final apiResults = List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          _searchResults = [...mockResults, ...apiResults];
        });
      } else {
        setState(() => _searchResults = mockResults);
      }
    } catch (e) {
       setState(() => _searchResults = mockResults);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onLocationSelected(Map<String, dynamic> location) {
    final addressDetails = location['address'] as Map<String, dynamic>? ?? {};
    
    // Use street_address if provided, otherwise clean up display_name
    final defaultAddr = location['display_name']?.toString().split(',').take(3).join(', ') ?? '';
    _addressController.text = location['street_address'] ?? defaultAddr;
    
    _cityController.text = addressDetails['city'] ?? addressDetails['town'] ?? addressDetails['county'] ?? '';
    _provinceController.text = addressDetails['state'] ?? '';
    _latController.text = location['lat'] ?? '';
    _lonController.text = location['lon'] ?? '';
    
    // Automatically set name if empty
    if (_nameController.text.isEmpty && location['name'] != null) {
      _nameController.text = location['name'];
    }

    final isMock = location['is_mock'] == true;
    if (isMock) {
      _descriptionController.text = location['description'] ?? '';
      _starController.text = location['star'] ?? '3';
      _thumbnailController.text = location['thumbnail'] ?? '';
      
      _selectedFacilities.clear();
      final fac = location['facilities']?.toString().split(',') ?? [];
      for (var f in fac) {
        if (f.trim().isNotEmpty) {
          if (!_availableFacilities.contains(f.trim())) {
             _availableFacilities.add(f.trim());
          }
          _selectedFacilities.add(f.trim());
        }
      }
    }

    setState(() {
      _searchResults.clear();
      _searchController.clear();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      String? uploadedUrl = _thumbnailController.text.trim();

      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          uploadedUrl = await context.read<HotelCubit>().uploadImage(_selectedImage!, 'hotels');
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
          }
          setState(() => _isUploadingImage = false);
          return;
        }
        setState(() => _isUploadingImage = false);
      }

      if (!mounted) return;

      bool success = false;
      if (widget.hotel != null) {
        success = await context.read<HotelCubit>().updateHotel(
          id: widget.hotel!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
          latitude: double.tryParse(_latController.text) ?? 0.0,
          longitude: double.tryParse(_lonController.text) ?? 0.0,
          starRating: int.tryParse(_starController.text) ?? 3,
          thumbnailUrl: uploadedUrl,
          facilities: _selectedFacilities,
        );
      } else {
        success = await context.read<HotelCubit>().addHotel(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
          latitude: double.tryParse(_latController.text) ?? 0.0,
          longitude: double.tryParse(_lonController.text) ?? 0.0,
          starRating: int.tryParse(_starController.text) ?? 3,
          thumbnailUrl: uploadedUrl,
          facilities: _selectedFacilities,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.hotel != null ? 'Hotel berhasil diupdate' : 'Hotel berhasil ditambahkan')),
        );
        context.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.hotel != null ? 'Edit Hotel' : 'Tambah Hotel', style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<HotelCubit, HotelState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto-fill section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pencarian Pintar (Auto-fill)', style: AppTextStyles.h4),
                        const Gap(8),
                        Text('Cari nama hotel atau alamat untuk mengisi form otomatis.', style: AppTextStyles.bodySmall),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Contoh: Hotel Indonesia...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onSubmitted: _searchLocation,
                              ),
                            ),
                            const Gap(8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: _isSearching 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.search),
                              onPressed: () => _searchLocation(_searchController.text),
                            ),
                          ],
                        ),
                        if (_searchResults.isNotEmpty) ...[
                          const Gap(12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on, color: AppColors.primary),
                                  title: Text(item['name'] ?? item['display_name'] ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(item['display_name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                  onTap: () => _onLocationSelected(item),
                                );
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  
                  const Gap(24),
                  Text('Informasi Dasar', style: AppTextStyles.h4),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Nama Hotel',
                    hint: 'Masukkan nama hotel',
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Deskripsi',
                    hint: 'Deskripsi tentang hotel',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const Gap(16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Rating Bintang',
                          hint: '1 - 5',
                          controller: _starController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            final val = int.tryParse(v);
                            if (val == null || val < 1 || val > 5) return '1-5 saja';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  
                  Text('Lokasi', style: AppTextStyles.h4),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Alamat Lengkap',
                    hint: 'Jalan, Nomor, RT/RW',
                    controller: _addressController,
                    maxLines: 2,
                    validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  const Gap(16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Kota',
                          hint: 'Contoh: Jakarta',
                          controller: _cityController,
                          validator: (v) => v == null || v.isEmpty ? 'Kota wajib diisi' : null,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Provinsi',
                          hint: 'Contoh: DKI Jakarta',
                          controller: _provinceController,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Latitude',
                          hint: '-6.200000',
                          controller: _latController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Longitude',
                          hint: '106.816666',
                          controller: _lonController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  
                  Text('Fasilitas & Gambar', style: AppTextStyles.h4),
                  const Gap(16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        if (_selectedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                          )
                        else if (_thumbnailController.text.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(_thumbnailController.text, height: 150, width: double.infinity, fit: BoxFit.cover),
                          )
                        else
                          Icon(Icons.image_outlined, size: 60, color: Colors.grey[400]),
                        const Gap(16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Pilih Foto dari Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  
                  Text('Fasilitas Hotel (Pilih)', style: AppTextStyles.labelLarge),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: _availableFacilities.map((facility) {
                      final isSelected = _selectedFacilities.contains(facility);
                      return FilterChip(
                        label: Text(facility),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFacilities.add(facility);
                            } else {
                              _selectedFacilities.remove(facility);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(32),
                  
                  CustomButton(
                    text: widget.hotel != null ? 'Update Hotel' : 'Simpan Hotel',
                    isLoading: state is HotelLoading || _isUploadingImage,
                    onPressed: _handleSubmit,
                  ),
                  const Gap(32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
