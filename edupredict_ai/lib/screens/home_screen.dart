import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import '../widgets/input_card.dart';
import '../widgets/custom_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // --- All 15 Numerical / TextField Inputs ---
  final TextEditingController _ageController = TextEditingController(text: "16");
  final TextEditingController _cgpaController = TextEditingController(text: "7.0");
  final TextEditingController _attendanceController = TextEditingController(text: "85");
  final TextEditingController _studyController = TextEditingController(text: "4.0");
  final TextEditingController _sleepController = TextEditingController(text: "7.0");
  final TextEditingController _mathController = TextEditingController(text: "75");
  final TextEditingController _scienceController = TextEditingController(text: "75");
  final TextEditingController _englishController = TextEditingController(text: "75");

  // --- All Categorical / Dropdown Inputs ---
  String _gender = 'other';
  String _parentEducation = 'high school';
  String _schoolType = 'public';
  String _travelTime = '15-30 min';
  String _extraActivities = 'no';
  String _internetAccess = 'yes';
  String _studyMethod = 'mixed';

  bool _isLoading = false;
  double? _predictedScore;
  Map<String, dynamic> _apiData = {};
  String _errorMessage = '';

  // Animation controller for the AI card
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));
  }

  Future<void> _loadProfileData() async {
    final details = await AuthService.getUserDetails();
    if (!mounted) return;
    setState(() {
      if (details['age'] != null && details['age'] != 0) {
        _ageController.text = details['age'].toString();
      }
      if (details['gender'] != null && details['gender'].toString().isNotEmpty) {
        final g = details['gender'].toString().toLowerCase();
        if (['male', 'female', 'other'].contains(g)) _gender = g;
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _makePrediction() async {
    setState(() {
      _isLoading = true;
      _predictedScore = null;
      _errorMessage = '';
      _animController.reset();
    });

    // Extracting strict values
    final Map<String, dynamic> payload = {
      'age': int.tryParse(_ageController.text) ?? 16,
      'cgpa': double.tryParse(_cgpaController.text) ?? 7.0,
      'attendance': double.tryParse(_attendanceController.text) ?? 85.0,
      'study_hours': double.tryParse(_studyController.text) ?? 4.0,
      'sleep_hours': double.tryParse(_sleepController.text) ?? 7.0,
      'math_score': double.tryParse(_mathController.text) ?? 75.0,
      'science_score': double.tryParse(_scienceController.text) ?? 75.0,
      'english_score': double.tryParse(_englishController.text) ?? 75.0,
      'gender': _gender,
      'parent_education': _parentEducation,
      'school_type': _schoolType,
      'travel_time': _travelTime,
      'extra_activities': _extraActivities,
      'internet_access': _internetAccess,
      'study_method': _studyMethod,
    };

    final result = await ApiService.predictPerformance(payload);

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _predictedScore = result['score'];
        _apiData = {
          'level': result['level'],
          'improvement': result['improvement'],
          'insights': result['insights'] ?? [],
        };
        if (result['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _errorMessage = result['error'] ?? 'Unknown Error';
      }
    });

    if (result['success'] == true) {
      // Save to History using a copy of payload to append the score
      final historyData = Map<String, dynamic>.from(payload);
      historyData['predicted_score'] = result['score'];
      await HistoryService.savePrediction(historyData);
      
      // Fire Animation
      _animController.forward();
    }
  }

  // Helper method to derive AI insights based on score
  Map<String, dynamic> _getInsightDetails(double score) {
    if (score >= 85) {
      return {
        'level': 'Excellent',
        'potential': 'Mastery - 100',
        'improvement': '+${(100 - score).toStringAsFixed(1)} marks possible',
        'message': "Incredible work! You are performing at the highest tier. Keep refining your knowledge to hit absolute mastery.",
        'color': Colors.cyanAccent,
      };
    } else if (score >= 70) {
      return {
        'level': 'Good',
        'potential': 'Excellent - 85+',
        'improvement': '+${(100 - score).toStringAsFixed(1)} marks possible',
        'message': "You're on the right track! With better consistency and focus, you can unlock your full potential and achieve top grades.",
        'color': Colors.greenAccent,
      };
    } else if (score >= 50) {
      return {
        'level': 'Average',
        'potential': 'Good - 70+',
        'improvement': '+${(100 - score).toStringAsFixed(1)} marks possible',
        'message': "There's room for improvement. Focus on your weaker subjects and try to build more consistent study habits.",
        'color': Colors.yellowAccent,
      };
    } else {
      return {
        'level': 'Needs Improvement',
        'potential': 'Average - 50+',
        'improvement': '+${(100 - score).toStringAsFixed(1)} marks possible',
        'message': "Don't lose hope. A shift in strategy and intensive review can dramatically pull your scores up into the Excellent bracket.",
        'color': Colors.orangeAccent,
      };
    }
  }

  Widget _buildInsightRow(IconData icon, String label, String value, {Color valueColor = Colors.white70}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsightCard() {
    if (_errorMessage.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 30),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    if (_predictedScore == null) return const SizedBox.shrink();

    final insight = _getInsightDetails(_predictedScore!);
    final primaryColor = insight['color'] as Color;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 24, bottom: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF2C1B4D), Color(0xFF16203B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
            border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Glowing background effect
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 40)
                      ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            "AI-Powered Academic Insight",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const Text("🎓 Predicted Exam Score", 
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              "${_predictedScore!.toStringAsFixed(1)} / 100",
                              style: TextStyle(
                                fontSize: 36, // Standard explicit format
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                                shadows: [
                                  Shadow(
                                    color: primaryColor.withOpacity(0.8),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildInsightRow(Icons.bar_chart, "Current Level:", _apiData['level'] ?? insight['level']),
                      const SizedBox(height: 12),
                      _buildInsightRow(Icons.rocket_launch, "Potential Level:", insight['potential']),
                      const SizedBox(height: 12),
                      _buildInsightRow(Icons.trending_up, "Improvement Potential:", _apiData['improvement'] ?? insight['improvement'], valueColor: Colors.white),
                      const SizedBox(height: 24),
                      
                      // Dynamic Web Insights
                      if (_apiData['insights'] != null && (_apiData['insights'] as List).isNotEmpty)
                        ...(_apiData['insights'] as List).map((msg) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    msg.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )).toList()
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  insight['message'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Basic Stats Card
          InputCard(
            title: "Student Profile",
            icon: Icons.person_outline,
            children: [
              CustomNumberInput(label: "Age", controller: _ageController, helperText: "Years (e.g. 16)"),
              CustomNumberInput(label: "CGPA", controller: _cgpaController, helperText: "Out of 10.0"),
              CustomNumberInput(label: "Attendance", controller: _attendanceController, helperText: "Percentage (%)"),
            ],
          ),

          // 2. Behavioral Metrics Card
          InputCard(
            title: "Study Habits",
            icon: Icons.access_time,
            children: [
              CustomNumberInput(label: "Study Hours", controller: _studyController, helperText: "Hours/day"),
              CustomNumberInput(label: "Sleep Hours", controller: _sleepController, helperText: "Hours/day"),
            ],
          ),

          // 3. Testing Matrix
          InputCard(
            title: "Academic Performance",
            icon: Icons.analytics_outlined,
            children: [
              CustomNumberInput(label: "Math Score", controller: _mathController, helperText: "0 - 100 Score"),
              CustomNumberInput(label: "Science Score", controller: _scienceController, helperText: "0 - 100 Score"),
              CustomNumberInput(label: "English Score", controller: _englishController, helperText: "0 - 100 Score"),
            ],
          ),

          // 4. Categorical Demographics
          InputCard(
            title: "Background Information",
            icon: Icons.location_city,
            children: [
              CustomDropdownInput(label: "Gender", value: _gender, options: const ['male', 'female', 'other'], onChanged: (v) => setState(() => _gender = v!)),
              CustomDropdownInput(label: "Parent Education", value: _parentEducation, options: const ['no formal', 'high school', 'diploma', 'graduate', 'post graduate', 'phd'], onChanged: (v) => setState(() => _parentEducation = v!)),
              CustomDropdownInput(label: "School Type", value: _schoolType, options: const ['public', 'private'], onChanged: (v) => setState(() => _schoolType = v!)),
              CustomDropdownInput(label: "Travel Time", value: _travelTime, options: const ['<15 min', '15-30 min', '30-60 min', '>60 min'], onChanged: (v) => setState(() => _travelTime = v!)),
            ],
          ),

          // 5. Categorical Extras
          InputCard(
            title: "Extracurricular",
            icon: Icons.extension_outlined,
            children: [
              CustomDropdownInput(label: "Extra Activities", value: _extraActivities, options: const ['yes', 'no'], onChanged: (v) => setState(() => _extraActivities = v!)),
              CustomDropdownInput(label: "Internet Access", value: _internetAccess, options: const ['yes', 'no'], onChanged: (v) => setState(() => _internetAccess = v!)),
              CustomDropdownInput(label: "Study Method", value: _studyMethod, options: const ['notes', 'textbook', 'online videos', 'group study', 'coaching', 'mixed'], onChanged: (v) => setState(() => _studyMethod = v!)),
            ],
          ),

          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _makePrediction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B3B4F),
              foregroundColor: Colors.tealAccent,
              side: const BorderSide(color: Colors.tealAccent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _isLoading ? 0 : 5,
              shadowColor: Colors.tealAccent.withOpacity(0.4),
            ),
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 3))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.memory, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "EXECUTE PREDICTION",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
          ),

          _buildAiInsightCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
