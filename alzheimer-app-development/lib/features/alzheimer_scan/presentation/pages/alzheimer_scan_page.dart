import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/features/alzheimer_scan/utils/api_service.dart';

class AlzheimerScanPage extends StatefulWidget {
  const AlzheimerScanPage({super.key});
  @override
  State<AlzheimerScanPage> createState() => _AlzheimerScanPageState();
}

class _AlzheimerScanPageState extends State<AlzheimerScanPage> {
  File? _image;
  final _picker = ImagePicker();
  String _className = '';
  double _confidence = 0.0;
  bool _isChecking = false; // State untuk loading

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource src) async {
    if (src == ImageSource.camera && !await _ensureCameraPermission()) {
      return _showSnack('Izin kamera ditolak');
    }
    try {
      final picked = await _picker.pickImage(
        source: src,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (picked != null) {
        setState(() {
          _image = File(picked.path);
          _className = '';
          _confidence = 0.0;
        });
      }
    } catch (e) {
      _showSnack('Gagal memilih gambar: $e');
    }
  }

  void _showPickerOptions() => showModalBottomSheet(
    context: context,
    builder:
        (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
  );

  void _showSnack(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  Future<void> _checkImage() async {
    if (_image == null) return;
    
    setState(() {
      _isChecking = true;
      _className = '';
      _confidence = 0.0;
    });

    try {
      final raw = await ApiService.uploadImage(_image!);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _className = data['class_name'] as String;
        _confidence = (data['confidence'] as num).toDouble() * 100;
      });
    } catch (e) {
      _showSnack('Error saat upload: $e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pemeriksaan Alzheimer'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(    
          children: [
            // ── Kotak frame dengan padding di dalamnya ──
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      dashPattern: const [6, 3],
                      color: Colors.grey,
                      strokeWidth: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        // Padding di dalam border
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child:
                              _image == null
                                  ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.cloud_upload,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Unggah gambar MRI otak untuk memulai pemeriksaan',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                  const Color(0xFFA1A4B2),
                                                ),
                                            shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder
                                            >(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                          onPressed: _showPickerOptions,
                                          child: const Text(
                                            'Pilih Gambar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),

                  // Aksen sudut
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(width: 40, height: 4, color: Colors.grey),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(width: 4, height: 40, color: Colors.grey),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(width: 40, height: 4, color: Colors.grey),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(width: 4, height: 40, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 40, height: 4, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(width: 4, height: 40, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(width: 40, height: 4, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(width: 4, height: 40, color: Colors.grey),
                  ),

                  // Tombol tutup
                  if (_image != null)
                    Positioned(
                      right: 25,
                      top: 25,
                      child: GestureDetector(
                        onTap:
                            () => setState(() {
                              _image = null;
                              _className = '';
                              _confidence = 0.0;
                            }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54, // latar gelap transparan
                            shape: BoxShape.circle, // bentuk lingkaran
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.close,
                            size: 20, // sedikit diperbesar
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_image != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA1A4B2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Periksa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Card Hasil Pemeriksaan ──
            Card(
              color: Colors.white, // Background card putih
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Pemeriksaan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kategori'),
                        Text(_className.isEmpty ? '-' : _className),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tingkat Kepercayaan'),
                        Text(
                          _confidence == 0.0
                              ? '-'
                              : '${_confidence.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFA1A4B2,
                          ), // Warna button A1A4B2
                          foregroundColor: Colors.white, // Warna text putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Radius border 6
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ), // Padding button
                        ),
                        onPressed: () {
                          // TODO: simpan hasil
                        },
                        child: const Text('Simpan Hasil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
