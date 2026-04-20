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
    return (v / 10).clamp(0.0, 1.0) * 100;
  }

  double _normalizeAttendance(dynamic value) {
    double v = (value ?? 85.0) is num ? (value ?? 85.0).toDouble() : 85.0;
    return v.clamp(0.0, 100.0);
  }

  double _normalizeScore(dynamic value) {
    double v = (value ?? 50.0) is num ? (value ?? 50.0).toDouble() : 50.0;
    return v.clamp(0.0, 100.0);
  }

  double _normalizeFocus(dynamic method) {
    String m = method?.toString().toLowerCase() ?? 'mixed';
    if (['notes', 'textbook', 'coaching'].contains(m)) return 95.0;
    if (m == 'mixed' || m == 'group study') return 65.0;
    return 35.0;
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
    final attendanceVal = _normalizeAttendance(_latestData!['attendance']);
    final mathVal = _normalizeScore(_latestData!['math_score']);
    final scienceVal = _normalizeScore(_latestData!['science_score']);
    final englishVal = _normalizeScore(_latestData!['english_score']);
    final focusVal = _normalizeFocus(_latestData!['study_method']);

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
                                    return RadarChartTitle(text: 'Attendance', angle: angle);
                                  case 2:
                                    return RadarChartTitle(text: 'Math', angle: angle);
                                  case 3:
                                    return RadarChartTitle(text: 'Science', angle: angle);
                                  case 4:
                                    return RadarChartTitle(text: 'English', angle: angle);
                                  case 5:
                                    return RadarChartTitle(text: 'Focus', angle: angle);
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
                                  fillColor: Colors.deepPurpleAccent.withOpacity(0.15),
                                  borderColor: Colors.deepPurpleAccent.withOpacity(0.6),
                                  entryRadius: 0,
                                  borderWidth: 2,
                                  dataEntries: const [
                                    RadarEntry(value: 80.0), // Ideal Study: 8 hours
                                    RadarEntry(value: 90.0), // Ideal Attendance: 90%
                                    RadarEntry(value: 85.0), // Ideal Math
                                    RadarEntry(value: 85.0), // Ideal Science
                                    RadarEntry(value: 85.0), // Ideal English
                                    RadarEntry(value: 95.0), // Ideal Focus
                                  ],
                                ),
                                RadarDataSet(
                                  fillColor: Colors.cyanAccent.withOpacity(0.25),
                                  borderColor: Colors.cyanAccent,
                                  entryRadius: 4,
                                  dataEntries: [
                                    RadarEntry(value: studyVal),
                                    RadarEntry(value: attendanceVal),
                                    RadarEntry(value: mathVal),
                                    RadarEntry(value: scienceVal),
                                    RadarEntry(value: englishVal),
                                    RadarEntry(value: focusVal),
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
                        "• The outer cyan polygon represents your metrics. The purple inner polygon is the 'Ideal Student' baseline.\n"
                        "• Expand your perimeter beyond the purple line to achieve top tier performance.",
                        style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),
                      const Text(
                        "Smart Insights (Strengths & Weaknesses)",
                        style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      if (studyVal < 60)
                        const Text("⚠️ Weakness: Increase daily study time. Aim for closer to 8 hours.", style: TextStyle(color: Colors.orangeAccent)),
                      if (attendanceVal < 80)
                        const Padding(padding: EdgeInsets.only(top: 8), child: Text("⚠️ Weakness: Improve class attendance to avoid knowledge gaps.", style: TextStyle(color: Colors.orangeAccent))),
                      if (focusVal < 60)
                        const Padding(padding: EdgeInsets.only(top: 8), child: Text("⚠️ Weakness: Consider switching to a structured study method like 'notes' or 'textbook'.", style: TextStyle(color: Colors.orangeAccent))),
                      if (studyVal >= 80 && attendanceVal >= 85)
                        const Padding(padding: EdgeInsets.only(top: 8), child: Text("⭐ Strength: Your discipline in studying and attendance is fantastic. Keep it up!", style: TextStyle(color: Colors.greenAccent))),
                      if (mathVal >= 80 || scienceVal >= 80 || englishVal >= 80)
                        const Padding(padding: EdgeInsets.only(top: 8), child: Text("⭐ Strength: You have a solid grasp on core subjects. You are outperforming the baseline.", style: TextStyle(color: Colors.greenAccent))),
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
