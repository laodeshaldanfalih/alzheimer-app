import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project/features/health_dashboard/data/health_data_model.dart';
import 'package:project/features/health_dashboard/providers/health_provider.dart';

class HealthHistoryListPage extends ConsumerStatefulWidget {
  const HealthHistoryListPage({super.key});

  @override
  ConsumerState<HealthHistoryListPage> createState() =>
      _HealthHistoryListPageState();
}

class _HealthHistoryListPageState extends ConsumerState<HealthHistoryListPage> {
  void _showDeleteConfirmation(BuildContext context, HealthData record) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: !isDeleting,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin menghapus data ini secara permanen? Tindakan ini tidak dapat diurungkan.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Batal'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Hapus'),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        try {
                          await ref
                              .read(healthProvider.notifier)
                              .deleteHealthRecord(record.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Data berhasil dihapus.'),
                                backgroundColor: Colors.green[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menghapus data: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, HealthData record) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _EditHealthRecordDialog(record: record);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final healthState = ref.read(healthProvider);
      if (healthState.healthRecords.isEmpty && !healthState.isLoading) {
        ref.read(healthProvider.notifier).loadHealthRecords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);
    final records = healthState.healthRecords;
    if (healthState.isLoading && records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!healthState.isLoading && records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Belum ada riwayat data untuk ditampilkan. Silakan input data pada tab 'Input Data'.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    if (records.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(healthProvider.notifier).loadHealthRecords(),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final date = record.timestamp.toDate();
            final formattedDate = DateFormat(
              'EEEE, d MMMM yyyy', // yyyy untuk tahun
              'id_ID',
            ).format(date);
            final formattedTime = DateFormat('HH:mm').format(date);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$formattedDate - $formattedTime WIB',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const Divider(height: 16, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInfoColumn(
                            'BB/TB',
                            '${record.weight}kg / ${record.height}cm',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildInfoColumn(
                            'TD',
                            '${record.systolic}/${record.diastolic}',
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildInfoColumn(
                            'Nadi',
                            '${record.heartRate.toInt()} bpm',
                          ),
                        ),
                        if (record.bloodSugar != null)
                          Expanded(
                            flex: 2,
                            child: _buildInfoColumn(
                              'GDS',
                              '${record.bloodSugar?.toInt() ?? "-"} mg/dL',
                            ),
                          ),
                        if (record.temperature != null)
                          Expanded(
                            flex: 2,
                            child: _buildInfoColumn(
                              'Suhu',
                              '${record.temperature?.toStringAsFixed(1) ?? "-"}°C',
                            ),
                          ),
                      ],
                    ),
                    if (record.symptoms != null &&
                        record.symptoms!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Keluhan:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.symptoms!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showEditDialog(context, record),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Hapus'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                          ),
                          onPressed:
                              () => _showDeleteConfirmation(context, record),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return const Center(
      child: Text("Terjadi kesalahan atau state tidak dikenal."),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EditHealthRecordDialog extends ConsumerStatefulWidget {
  final HealthData record;
  const _EditHealthRecordDialog({required this.record});

  @override
  ConsumerState<_EditHealthRecordDialog> createState() =>
      _EditHealthRecordDialogState();
}

class _EditHealthRecordDialogState
    extends ConsumerState<_EditHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _waistController;
  late TextEditingController _tempController;
  late TextEditingController _respRateController;
  late TextEditingController _systolicController;
  late TextEditingController _diastolicController;
  late TextEditingController _heartRateController;
  late TextEditingController _bloodSugarController;
  late TextEditingController _symptomsController;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _weightController = TextEditingController(text: r.weight.toString());
    _heightController = TextEditingController(text: r.height.toString());
    _waistController = TextEditingController(
      text: r.waistCircumference.toString(),
    );
    _tempController = TextEditingController(text: r.temperature.toString());
    _respRateController = TextEditingController(
      text: r.respiratoryRate.toString(),
    );
    _systolicController = TextEditingController(text: r.systolic.toString());
    _diastolicController = TextEditingController(text: r.diastolic.toString());
    _heartRateController = TextEditingController(text: r.heartRate.toString());
    _bloodSugarController = TextEditingController(
      text: r.bloodSugar?.toString() ?? '',
    );
    _symptomsController = TextEditingController(text: r.symptoms ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    _tempController.dispose();
    _respRateController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _bloodSugarController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final updatedData = HealthData(
      id: widget.record.id,
      timestamp: widget.record.timestamp,
      heartRate:
          double.tryParse(_heartRateController.text) ?? widget.record.heartRate,
      respiratoryRate:
          double.tryParse(_respRateController.text) ??
          widget.record.respiratoryRate,
      temperature:
          double.tryParse(_tempController.text) ?? widget.record.temperature,
      systolic:
          int.tryParse(_systolicController.text) ?? widget.record.systolic,
      diastolic:
          int.tryParse(_diastolicController.text) ?? widget.record.diastolic,
      weight: double.tryParse(_weightController.text) ?? widget.record.weight,
      height: double.tryParse(_heightController.text) ?? widget.record.height,
      waistCircumference:
          double.tryParse(_waistController.text) ??
          widget.record.waistCircumference,
      bloodSugar:
          _bloodSugarController.text.isNotEmpty
              ? double.tryParse(_bloodSugarController.text)
              : null,
      symptoms:
          _symptomsController.text.isNotEmpty ? _symptomsController.text : null,
    );

    try {
      await ref.read(healthProvider.notifier).updateHealthRecord(updatedData);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        "Pengukuran Tubuh & Tanda Vital",
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Pengukuran Tubuh",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildEditTextField(_weightController, 'Berat Badan (kg)'),
              _buildEditTextField(_heightController, 'Tinggi Badan (cm)'),
              _buildEditTextField(_waistController, 'Lingkar Pinggang (cm)'),
              const SizedBox(height: 12),

              Text(
                "Tanda Vital",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildEditTextField(_systolicController, 'Sistolik'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildEditTextField(
                      _diastolicController,
                      'Diastolik',
                    ),
                  ),
                ],
              ),
              _buildEditTextField(_heartRateController, 'Detak Jantung (BPM)'),
              _buildEditTextField(
                _bloodSugarController,
                'Gula Darah (mg/dL)',
                isRequired: false,
              ),
              const SizedBox(height: 12),

              Text(
                "Lainnya (Jika Ada)",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildEditTextField(
                _tempController,
                'Suhu Tubuh (°C)',
                isRequired: false,
              ),
              _buildEditTextField(
                _respRateController,
                'Laju Pernapasan (/menit)',
                isRequired: false,
              ),
              _buildEditTextField(
                _symptomsController,
                'Keluhan dan Gejala',
                isRequired: false,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.blueAccent),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            disabledBackgroundColor: Colors.blueAccent.withOpacity(0.5),
          ),
          onPressed: _isProcessing ? null : _updateData,
          child:
              _isProcessing
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Simpan Perubahan'),
        ),
      ],
    );
  }

  Widget _buildEditTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType:
            maxLines > 1
                ? TextInputType.multiline
                : const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        validator: (value) {
          if (isRequired) {
            if (value == null || value.isEmpty) return 'Wajib diisi';
            if (maxLines == 1 && double.tryParse(value) == null)
              return 'Angka tidak valid';
          } else {
            if (value != null &&
                value.isNotEmpty &&
                maxLines == 1 &&
                double.tryParse(value) == null)
              return 'Angka tidak valid';
          }
          return null;
        },
      ),
    );
  }
}
