import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/history_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _latestData;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        if (history.isNotEmpty) {
          _latestData = history.first;
        }
        _isLoading = false;
      });
      if (_latestData != null) {
        _animController.forward();
      }
    }
  }

  // Normalization Methods: 0 to 100 scale
  double _normalizeStudy(dynamic value) {
    double v = (value ?? 4.0) is num ? (value ?? 4.0).toDouble() : 4.0;
    return (v / 10) * 100;
  }

  double _normalizeSleep(dynamic value) {
    double v = (value ?? 7.0) is num ? (value ?? 7.0).toDouble() : 7.0;
    return (v / 10) * 100;
  }

  double _normalizeAttendance(dynamic value) {
    double v = (value ?? 85.0) is num ? (value ?? 85.0).toDouble() : 85.0;
    return v;
  }

  double _normalizeStress(dynamic value) {
    double v = (value ?? 40.0) is num ? (value ?? 40.0).toDouble() : 40.0;
    return 100 - v;
  }

  double _normalizeEntertainment(dynamic value) {
    double v = (value ?? 30.0) is num ? (value ?? 30.0).toDouble() : 30.0;
    return 100 - v;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    if (_latestData == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            "Execute a prediction first to see your analytics.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final studyVal = _normalizeStudy(_latestData!['study_hours']);
    final sleepVal = _normalizeSleep(_latestData!['sleep_hours']);
    final attendanceVal = _normalizeAttendance(_latestData!['attendance']);
    final stressVal = _normalizeStress(_latestData!['stress']);
    final entertainmentVal = _normalizeEntertainment(_latestData!['entertainment_time']);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "🕸️ Performance Radar Analysis",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Visualize your strengths and weaknesses based on your latest inputs.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              // Animated Premium Card for Radar Chart
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: 440,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C1B4D), Color(0xFF16203B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: RadarChart(
                            RadarChartData(
                              tickCount: 5,
                              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                              gridBorderData: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                              radarBorderData: const BorderSide(color: Colors.transparent),
                              tickBorderData: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                              radarBackgroundColor: Colors.transparent,
                              radarShape: RadarShape.polygon,
                              getTitle: (index, angle) {
                                switch (index) {
                                  case 0:
                                    return RadarChartTitle(text: 'Study\nHours', angle: angle);
                                  case 1:
                                    return RadarChartTitle(text: 'Sleep\nHours', angle: angle);
                                  case 2:
                                    return RadarChartTitle(text: 'Attendance', angle: angle);
                                  case 3:
                                    return RadarChartTitle(text: 'Stress\nControl', angle: angle);
                                  case 4:
                                    return RadarChartTitle(text: 'Focus\n(Less Ent.)', angle: angle);
                                  default:
                                    return const RadarChartTitle(text: '');
                                }
                              },
                              titleTextStyle: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              dataSets: [
                                RadarDataSet(
                                  fillColor: Colors.cyanAccent.withOpacity(0.25),
                                  borderColor: Colors.cyanAccent,
                                  entryRadius: 4,
                                  dataEntries: [
                                    RadarEntry(value: studyVal),
                                    RadarEntry(value: sleepVal),
                                    RadarEntry(value: attendanceVal),
                                    RadarEntry(value: stressVal),
                                    RadarEntry(value: entertainmentVal),
                                  ],
                                  borderWidth: 2.5,
                                ),
                              ],
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 800),
                            swapAnimationCurve: Curves.easeOutBack,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "This chart shows your strengths and weaknesses across key performance factors.",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Legend/Explainer
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "How to read this chart",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "• The closer the shape is to the outer edge, the better your performance in that category.\n\n"
                        "• Stress Control and Focus are inverted: having lower stress and less entertainment time pushes the chart outwards, indicating better habits.",
                        style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
