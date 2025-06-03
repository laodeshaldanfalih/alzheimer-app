// ======================================================================
// WIDGET UNTUK TAB 1: INPUT DATA MANUAL (Struktur diubah sesuai gambar)
// ======================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Pastikan path ini benar dan HealthData model adalah yang baru Anda berikan
import 'package:project/features/health_page/health_data_model.dart';
import 'package:project/features/health_page/health_provider.dart';

class HealthInputPage extends ConsumerStatefulWidget {
  const HealthInputPage({super.key});
  @override
  ConsumerState<HealthInputPage> createState() => _HealthInputPageState();
}

class _HealthInputPageState extends ConsumerState<HealthInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _waistController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _symptomsController = TextEditingController();

  double _bmi = 0.0;
  String _bmiCategory = "";

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _bloodSugarController.dispose();
    _temperatureController.dispose();
    _respiratoryRateController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    if (weight != null && weight > 0 && height != null && height > 0) {
      setState(() {
        final double heightInMeters = height / 100;
        _bmi = weight / (heightInMeters * heightInMeters);
        if (_bmi < 18.5) {
          _bmiCategory = "Berat Badan Kurang";
        } else if (_bmi >= 18.5 && _bmi <= 24.9) {
          _bmiCategory = "Berat Badan Normal";
        } else if (_bmi >= 25 && _bmi <= 29.9) {
          _bmiCategory = "Kelebihan Berat Badan";
        } else {
          _bmiCategory = "Obesitas";
        }
      });
    } else {
      setState(() {
        _bmi = 0.0;
        _bmiCategory = "";
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _weightController.clear();
    _heightController.clear();
    _waistController.clear();
    _systolicController.clear();
    _diastolicController.clear();
    _heartRateController.clear();
    _bloodSugarController.clear();
    _temperatureController.clear();
    _respiratoryRateController.clear();

    _symptomsController.clear();
    setState(() {
      _bmi = 0;
      _bmiCategory = "";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulir dibersihkan.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  bool _areAllFieldsEmpty() {
    return _weightController.text.isEmpty &&
        _heightController.text.isEmpty &&
        _waistController.text.isEmpty &&
        _systolicController.text.isEmpty &&
        _diastolicController.text.isEmpty &&
        _heartRateController.text.isEmpty &&
        _bloodSugarController.text.isEmpty &&
        _temperatureController.text.isEmpty &&
        _respiratoryRateController.text.isEmpty &&
        _symptomsController.text.isEmpty;
  }

  Future<void> _saveAllData() async {
    FocusScope.of(context).unfocus();

    if (_areAllFieldsEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom kosong. Harap isi minimal satu data.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beberapa input angka tidak valid. Harap perbaiki.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Membuat objek HealthData dengan memperhatikan nullability dari model
      await ref
          .read(healthProvider.notifier)
          .addHealthRecord(
            HealthData(
              // id akan di-generate oleh Firestore atau biarkan null jika model mengizinkan
              timestamp: Timestamp.now(),
              heartRate:
                  double.tryParse(_heartRateController.text) ??
                  0.0, // Default 0.0 jika kosong
              respiratoryRate:
                  double.tryParse(_respiratoryRateController.text) ??
                  0.0, // Default karena non-nullable di model & tidak ada di form
              temperature: double.tryParse(_temperatureController.text) ?? 0.0,
              systolic:
                  int.tryParse(_systolicController.text) ??
                  0, // Default 0 jika kosong
              diastolic:
                  int.tryParse(_diastolicController.text) ??
                  0, // Default 0 jika kosong
              weight:
                  double.tryParse(_weightController.text) ??
                  0.0, // Default 0.0 jika kosong
              height:
                  double.tryParse(_heightController.text) ??
                  0.0, // Default 0.0 jika kosong
              waistCircumference:
                  double.tryParse(_waistController.text) ??
                  0.0, // Default 0.0 jika kosong
              bloodSugar: double.tryParse(
                _bloodSugarController.text,
              ), // Boleh null sesuai model
              symptoms:
                  _symptomsController.text.isNotEmpty
                      ? _symptomsController.text
                      : null, // Boleh null sesuai model
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kesehatan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? sectionTitleStyle = Theme.of(context).textTheme.titleLarge
        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87);
    final TextStyle? fieldLabelStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Pengukuran Tubuh & Tanda Vital",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _weightController,
                    label: 'Berat Badan',
                    hint: '(kg)',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFF2F80ED),
                    onChanged: (_) => _calculateBmi(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _heightController,
                    label: 'Tinggi Badan',
                    hint: '(cm)',
                    unit: 'cm',
                    icon: Icons.height_outlined,
                    iconColor: const Color(0xFF27AE60),
                    onChanged: (_) => _calculateBmi(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _waistController,
                    label: 'Lingkar Pinggang',
                    hint: '(cm)',
                    unit: 'cm',
                    icon: Icons.straighten_outlined,
                    iconColor: const Color(0xFFF2994A),
                  ),
                  if (_bmi > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'IMT Anda: ${_bmi.toStringAsFixed(1)} ($_bmiCategory)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              _buildInputCard(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF29A165).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons
                              .monitor_heart, // Atau Icons.medical_services_outlined
                          size: 20,
                          color: Color(0xFF29A165),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Tekanan Darah",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          controller: _systolicController,
                          label: 'Sistolik',
                          hint: 'Sistolik',
                          unit: 'mmHg',
                          icon:
                              Icons
                                  .arrow_upward, // Tidak akan ditampilkan jika hideIconAndLabelPrefix true
                          iconColor: Colors.grey.shade600,
                          hideIconAndLabelPrefix:
                              true, // Sembunyikan prefix ikon+label utama
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextFormField(
                          controller: _diastolicController,
                          label: 'Diastolik',
                          hint: 'Diastolik',
                          unit: 'mmHg',
                          icon:
                              Icons
                                  .arrow_downward, // Tidak akan ditampilkan jika hideIconAndLabelPrefix true
                          iconColor: Colors.grey.shade600,
                          hideIconAndLabelPrefix:
                              true, // Sembunyikan prefix ikon+label utama
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _heartRateController,
                    label: 'Detak Jantung',
                    hint: 'BPM',
                    icon: Icons.favorite_border,
                    iconColor: const Color(0xFFEB5757),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _temperatureController,
                    label: 'Suhu Tubuh',
                    hint: '(°C)',
                    unit: '°C',
                    icon: Icons.thermostat,
                    iconColor: const Color(0xFFFF853A),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _respiratoryRateController,
                    label: 'Laju Pernafasan',
                    hint: '(Hembusan/menit)',
                    icon: Icons.air,
                    iconColor: const Color(0xFF55B29C),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _bloodSugarController,
                    label: 'Gula Darah',
                    hint: '(mg/dL)',
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFFF2C94C),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Keluhan dan Gejala",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                children: [
                  _buildTextFormField(
                    controller: _symptomsController,
                    label: 'Catatan',
                    hint:
                        'Tulis keluhan yang dirasakan atau gejala yang tampak...',
                    icon: Icons.notes_outlined,
                    iconColor: Colors.blueAccent,
                    maxLines: 8,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Icon di samping kiri (tetap di baris yang sama)
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8), // Jarak antara icon dan teks
                    Expanded(
                      child: Text(
                        "Semua isian data pada formulir dapat bersifat opsional untuk diisi",
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Kosongi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAllData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required List<Widget> children}) {
    return Card(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? unit,
    required IconData icon,
    Color iconColor = Colors.blue,
    Function(String)? onChanged,
    int maxLines = 1,
    bool hideIconAndLabelPrefix = false,
  }) {
    final TextStyle? labelStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: Color(0xff4B5563),
      fontSize: 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hideIconAndLabelPrefix)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(label, style: labelStyle),
            ],
          ),
        if (!hideIconAndLabelPrefix) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType:
              maxLines > 1
                  ? TextInputType.multiline
                  : const TextInputType.numberWithOptions(decimal: true),
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            suffixText: unit,
            suffixStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !(maxLines > 1 &&
                    (controller.runtimeType ==
                        _symptomsController
                            .runtimeType)) && // Perbaikan: Cek tipe controller untuk symptoms
                (keyboardTypeIsNumeric(
                  maxLines > 1
                      ? TextInputType.multiline
                      : const TextInputType.numberWithOptions(decimal: true),
                )) && // Cek apakah tipe keyboard numerik
                double.tryParse(value) == null) {
              return 'Angka tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Helper untuk mengecek apakah TextInputType adalah numerik
  bool keyboardTypeIsNumeric(TextInputType? type) {
    if (type == null) return false;
    return type.index == TextInputType.number.index ||
        type.index ==
            TextInputType
                .phone
                .index; // TextInputType.numberWithOptions juga termasuk number
  }
}
