// File: HealthGraphicChartPage.dart
// ======================================================================
// WIDGET UNTUK TAB 2: GRAFIK
// ======================================================================
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project/features/health_dashboard/data/health_data_model.dart';
import 'package:project/features/health_dashboard/providers/health_provider.dart';

class HealthGraphicChartPage extends ConsumerStatefulWidget {
  const HealthGraphicChartPage({super.key});
  @override
  ConsumerState<HealthGraphicChartPage> createState() =>
      _HealthGraphicChartPageState(); // Mengganti nama state agar sesuai
}

class _HealthGraphicChartPageState // Mengganti nama state
    extends ConsumerState<HealthGraphicChartPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentState = ref.read(healthProvider);
      if (currentState.healthRecords.isEmpty && !currentState.isLoading) {
        ref.read(healthProvider.notifier).loadHealthRecords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProvider);
    if (healthState.isLoading && healthState.healthRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (healthState.healthRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Belum ada riwayat data untuk menampilkan grafik. Silakan input data terlebih dahulu.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    final records = healthState.healthRecords;
    // Pengecekan minimal 2 data akan dilakukan di dalam masing-masing chart builder
    // setelah data difilter dan diurutkan.

    return RefreshIndicator(
      onRefresh: () => ref.read(healthProvider.notifier).loadHealthRecords(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChartCard(
              "Tekanan Darah (mmHg)",
              _buildBloodPressureChart(records),
            ),
            _buildChartCard(
              "Indeks Massa Tubuh (IMT)",
              _buildBmiChart(records),
            ),
            _buildChartCard(
              "Detak Jantung (BPM)",
              _buildSingleMetricChart(
                records,
                (d) => d.heartRate,
                Colors.red,
                "Detak Jantung",
              ),
            ),
            _buildChartCard(
              "Lingkar Pinggang (cm)",
              _buildSingleMetricChart(
                records,
                (d) => d.waistCircumference,
                Colors.orange,
                "Lingkar Pinggang",
              ),
            ),
            _buildChartCard(
              "Berat Badan (kg)",
              _buildSingleMetricChart(
                records,
                (d) => d.weight,
                Colors.blueAccent,
                "Berat Badan",
              ),
            ),
            if (records.any(
              // Cek apakah ada data gula darah yang valid sebelum membuat card
              (r) => r.bloodSugar != null && r.bloodSugar! > 0,
            ))
              _buildChartCard(
                "Gula Darah (mg/dL)",
                _buildSingleMetricChart(
                  records,
                  (d) => d.bloodSugar ?? 0, // Akan difilter > 0 di dalam fungsi
                  Colors.greenAccent.shade700,
                  "Gula Darah",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 48, 16),
            child: SizedBox(height: 200, child: chart),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodPressureChart(List<HealthData> initialData) {
    // Langkah 1: Buat salinan data dan urutkan berdasarkan timestamp (terlama ke terbaru)
    List<HealthData> sortedData = List.from(initialData);
    sortedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Langkah 2: Filter data yang sudah diurutkan
    final List<HealthData> validData =
        sortedData.where((d) => d.systolic > 0 && d.diastolic > 0).toList();

    if (validData.length < 2) {
      return Center(
        child: Text(
          "Data Tekanan Darah tidak cukup untuk grafik.",
          style: TextStyle(color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Langkah 3: Buat spots dari validData (yang sudah terurut dan terfilter)
    final spotsSystolic =
        validData
            .asMap()
            .entries
            .map(
              (e) => FlSpot(e.key.toDouble(), e.value.systolic.toDouble()),
            ) // e.key = 0 untuk data terlama yang valid
            .toList();
    final spotsDiastolic =
        validData
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.diastolic.toDouble()))
            .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          _lineChartBarData(spotsSystolic, Colors.blue.shade700, "Sistolik"),
          _lineChartBarData(spotsDiastolic, Colors.green.shade700, "Diastolik"),
        ],
        titlesData: _getTitlesData(
          validData,
        ), // Langkah 4: Gunakan validData untuk titles
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                String text;
                if (barSpot.barIndex == 0) {
                  text = 'Sistolik: ${barSpot.y.toInt()}';
                } else {
                  text = 'Diastolik: ${barSpot.y.toInt()}';
                }
                return LineTooltipItem(
                  text,
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBmiChart(List<HealthData> initialData) {
    // Langkah 1: Buat salinan data dan urutkan berdasarkan timestamp
    List<HealthData> sortedData = List.from(initialData);
    sortedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Langkah 2: Filter data yang sudah diurutkan
    final List<HealthData> validRecordsForBmi = [];
    final List<double> bmiValues = [];

    for (final record in sortedData) {
      if (record.height > 0 && record.weight > 0) {
        final bmi =
            record.weight / ((record.height / 100) * (record.height / 100));
        if (bmi > 0) {
          validRecordsForBmi.add(record);
          bmiValues.add(double.parse(bmi.toStringAsFixed(1)));
        }
      }
    }

    if (validRecordsForBmi.length < 2) {
      return Center(
        child: Text(
          "Data IMT tidak cukup untuk grafik.",
          style: TextStyle(color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Langkah 3: Buat spots dari bmiValues (yang urutannya sesuai validRecordsForBmi)
    final spots =
        bmiValues
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [_lineChartBarData(spots, Colors.purple, "IMT")],
        titlesData: _getTitlesData(
          validRecordsForBmi,
        ), // Langkah 4: Gunakan validRecordsForBmi untuk titles
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  'IMT: ${barSpot.y}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSingleMetricChart(
    List<HealthData> initialData,
    double Function(HealthData) getMetric,
    Color color,
    String metricName,
  ) {
    // Langkah 1: Buat salinan data dan urutkan berdasarkan timestamp
    List<HealthData> sortedData = List.from(initialData);
    sortedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Langkah 2: Filter data yang sudah diurutkan
    final List<HealthData> validRecordsForMetric = [];
    final List<double> metricValues = [];

    for (final record in sortedData) {
      final metricValue = getMetric(record);
      if (metricValue > 0) {
        validRecordsForMetric.add(record);
        metricValues.add(metricValue);
      }
    }

    if (validRecordsForMetric.length < 2) {
      return Center(
        child: Text(
          "Data untuk $metricName tidak cukup untuk grafik.",
          style: TextStyle(color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Langkah 3: Buat spots dari metricValues (yang urutannya sesuai validRecordsForMetric)
    final spots =
        metricValues
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [_lineChartBarData(spots, color, metricName)],
        titlesData: _getTitlesData(
          validRecordsForMetric,
        ), // Langkah 4: Gunakan validRecordsForMetric untuk titles
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(spots),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                String yValueString;
                if (metricName == "Gula Darah" ||
                    metricName == "Lingkar Pinggang" ||
                    metricName == "Detak Jantung") {
                  yValueString = barSpot.y.toInt().toString();
                } else {
                  yValueString = barSpot.y.toStringAsFixed(1);
                }
                return LineTooltipItem(
                  '$metricName: $yValueString',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    if (spots.first.y > 30 && spots.first.y < 200) {
      return 2;
    }
    double minY = spots.first.y;
    double maxY = spots.first.y;
    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    double range = maxY - minY;
    if (range <= 0) return maxY > 1 ? maxY / 5 : (maxY > 0 ? maxY : 1);

    double interval = range / 5;
    if (interval == 0) return 1;

    double magnitude = 1.0;
    if (interval > 0) {
      double tempInterval = interval;
      if (tempInterval < 1) {
        magnitude = 0.1; // Inisialisasi untuk desimal
        while (tempInterval < 1 && magnitude > 0.00001) {
          // Batasi presisi
          tempInterval *= 10;
          magnitude /= 10;
        }
        // Setelah loop, magnitude mungkin jadi 0.01, 0.001 etc. tempInterval jadi >= 1
        // Koreksi magnitude agar menjadi 1, 10, 100 atau 0.1, 0.01
        magnitude = double.parse(
          '1e${(interval.toStringAsFixed(10).split('.').last.indexOf(RegExp(r'[1-9]')) + 1) * -1}',
        );
        if (interval >= 1)
          magnitude = double.parse(
            '1e${(interval.toStringAsFixed(0).length - 1)}',
          );
      } else {
        magnitude = double.parse(
          '1e${(interval.toStringAsFixed(0).length - 1)}',
        );
      }
      if (magnitude == 0) magnitude = 1; // Fallback jika magnitude jadi 0

      // Pembulatan interval ke angka yang 'bagus'
      if (interval / magnitude <= 1.0)
        interval = 1 * magnitude; // jika hasil bagi sangat kecil
      else if (interval / magnitude <= 1.5)
        interval = 1.5 * magnitude; // atau 1 * magnitude
      else if (interval / magnitude <= 2.5)
        interval = 2.5 * magnitude; // atau 2 * magnitude
      else if (interval / magnitude <= 3.5)
        interval = 2.5 * magnitude; // Penyesuaian
      else if (interval / magnitude <= 5.0)
        interval = 5 * magnitude;
      else if (interval / magnitude <= 7.5)
        interval = 5 * magnitude; // Penyesuaian
      else
        interval = 10 * magnitude;
    }
    return interval > 0 ? interval : 1;
  }

  LineChartBarData _lineChartBarData(
    List<FlSpot> spots,
    Color color,
    String name,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
    );
  }

  FlTitlesData _getTitlesData(List<HealthData> data) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            int dataCount = data.length;

            if (index >= 0 && index < dataCount) {
              final date =
                  data[index].timestamp
                      .toDate(); // data[index] sekarang merujuk pada data yang sudah terurut dan terfilter
              bool showThisLabel = true;

              if (dataCount > 20) {
                int interval =
                    (dataCount / 4).ceil(); // Target sekitar 4-5 label
                if (index != 0 &&
                    index != dataCount - 1 &&
                    index % interval != 0)
                  showThisLabel = false;
              } else if (dataCount > 10) {
                int interval = (dataCount / 5).ceil();
                if (index != 0 &&
                    index != dataCount - 1 &&
                    index % interval != 0)
                  showThisLabel = false;
              } else if (dataCount > 5) {
                // Antara 6-10 data
                if (index != 0 &&
                    index != dataCount - 1 &&
                    (index % ((dataCount / 3).ceil()) != 0)) {
                  // Coba tampilkan sekitar 3-4 label
                  if (dataCount > 7 &&
                      index % 2 != 0 &&
                      index != dataCount - 1 &&
                      index != 0)
                    showThisLabel = false; // Alternatif untuk 8-10 data
                  else if (dataCount <= 7 &&
                      index % 2 != 0 &&
                      index != dataCount - 1 &&
                      index != 0)
                    showThisLabel = false;
                }
              }

              // Selalu coba tampilkan label pertama dan terakhir
              if (index == 0 || index == dataCount - 1) showThisLabel = true;
              // Jika total data sangat sedikit, tampilkan semua
              if (dataCount <= 5) showThisLabel = true;

              if (!showThisLabel) return const SizedBox.shrink();

              return SideTitleWidget(
                meta: meta,
                space: 8.0,
                child: Text(
                  DateFormat('d/M').format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45, // Sedikit lebih lebar untuk angka Y-axis
          getTitlesWidget: (value, meta) {
            // Format angka untuk sumbu Y agar tidak terlalu panjang jika desimal
            String text;
            if (value == value.toInt().toDouble()) {
              // Jika bilangan bulat
              text = value.toInt().toString();
            } else {
              text = value.toStringAsFixed(1); // Satu angka desimal jika perlu
            }
            return Padding(
              padding: const EdgeInsets.only(
                right: 6.0,
              ), // Padding agar tidak terlalu mepet garis
              child: Text(
                text,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
    );
  }
}
