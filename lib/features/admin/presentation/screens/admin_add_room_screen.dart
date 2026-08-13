import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../hotel/presentation/cubit/hotel_cubit.dart';
import '../../../hotel/data/models/room_model.dart';

class AdminAddRoomScreen extends StatefulWidget {
  final String hotelId;
  final RoomModel? room;
  const AdminAddRoomScreen({super.key, required this.hotelId, this.room});

  @override
  State<AdminAddRoomScreen> createState() => _AdminAddRoomScreenState();
}

class _AdminAddRoomScreenState extends State<AdminAddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController(text: '2');
  final _totalRoomsController = TextEditingController(text: '1');
  final _thumbnailController = TextEditingController();
  String _selectedRoomType = 'standard';

  File? _selectedImage;
  bool _isUploadingImage = false;

  final List<String> _roomTypes = ['standard', 'deluxe', 'suite', 'presidential'];
  
  final List<String> _availableAmenities = [
    'Wi-Fi gratis',
    'AC',
    'TV',
    'Kamar mandi pribadi',
    'Air panas',
    'Shower',
    'Toilet',
    'Meja kerja',
    'Lemari pakaian',
    'Brankas',
    'Kulkas / minibar',
    'Hair dryer',
    'Air mineral',
    'Perlengkapan mandi',
    'Handuk',
    'Balkon',
    'Pemandangan kota / kolam / gunung',
    'Sarapan',
  ];
  final List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      final r = widget.room!;
      _nameController.text = r.name;
      _descriptionController.text = r.description ?? '';
      _selectedRoomType = r.roomType;
      _priceController.text = r.pricePerNight.toString();
      _maxGuestsController.text = r.maxGuests.toString();
      _totalRoomsController.text = r.totalRooms.toString();
      _thumbnailController.text = r.thumbnailUrl ?? '';
      
      _selectedAmenities.clear();
      for (var a in r.amenities) {
        if (!_availableAmenities.contains(a)) {
          _availableAmenities.add(a);
        }
        _selectedAmenities.add(a);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _totalRoomsController.dispose();
    _thumbnailController.dispose();
    super.dispose();
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
          uploadedUrl = await context.read<HotelCubit>().uploadImage(_selectedImage!, 'rooms');
        } catch (e) {
          if (mounted) {
            DialogUtils.showError(context, 'Gagal upload gambar: $e');
          }
          setState(() => _isUploadingImage = false);
          return;
        }
        setState(() => _isUploadingImage = false);
      }

      if (!mounted) return;

      bool success = false;
      if (widget.room != null) {
        success = await context.read<HotelCubit>().updateRoom(
          id: widget.room!.id,
          hotelId: widget.hotelId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          roomType: _selectedRoomType,
          pricePerNight: int.tryParse(_priceController.text) ?? 0,
          maxGuests: int.tryParse(_maxGuestsController.text) ?? 2,
          totalRooms: int.tryParse(_totalRoomsController.text) ?? 1,
          thumbnailUrl: uploadedUrl,
          amenities: _selectedAmenities,
        );
      } else {
        success = await context.read<HotelCubit>().addRoom(
          hotelId: widget.hotelId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          roomType: _selectedRoomType,
          pricePerNight: int.tryParse(_priceController.text) ?? 0,
          maxGuests: int.tryParse(_maxGuestsController.text) ?? 2,
          totalRooms: int.tryParse(_totalRoomsController.text) ?? 1,
          thumbnailUrl: uploadedUrl,
          amenities: _selectedAmenities,
        );
      }

      if (success && mounted) {
        DialogUtils.showSuccess(
          context, 
          widget.room != null ? 'Kamar berhasil diperbarui' : 'Kamar berhasil ditambahkan'
        ).then((_) {
          if (mounted) context.pop(true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.room != null ? 'Edit Kamar' : 'Tambah Kamar', style: AppTextStyles.h3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<HotelCubit, HotelState>(
        listener: (context, state) {
          if (state is HotelError) {
            DialogUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Kamar', style: AppTextStyles.h4),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Nama Kamar (misal: Standard Room City View)',
                    hint: 'Masukkan nama kamar',
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const Gap(16),

                  DropdownButtonFormField<String>(
                    value: _selectedRoomType,
                    decoration: InputDecoration(
                      labelText: 'Tipe Kamar',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _roomTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRoomType = val);
                    },
                  ),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Harga per Malam (Rp)',
                    hint: 'Contoh: 500000',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const Gap(16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Maks. Tamu',
                          hint: '2',
                          controller: _maxGuestsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Jumlah Kamar Tersedia',
                          hint: '10',
                          controller: _totalRoomsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  
                  Text('Detail Tambahan', style: AppTextStyles.h4),
                  const Gap(16),
                  
                  CustomTextField(
                    label: 'Deskripsi Kamar',
                    hint: 'Penjelasan tentang fasilitas kamar, dll',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
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
                  
                  Text('Fasilitas Kamar (Pilih)', style: AppTextStyles.labelLarge),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: _availableAmenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const Gap(32),
                  
                  CustomButton(
                    text: widget.room != null ? 'Update Kamar' : 'Simpan Kamar',
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
