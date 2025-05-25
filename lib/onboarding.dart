
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final Map<String, dynamic> answers = {};

  final List<String> ageGroups = ['<24', '25–34', '35–44', '45–54', '55–64', '65+'];
  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> risks = ['Smoking', 'Drinking'];
  final List<String> activityLevels = ['Low (little/no activity)', 'Moderate (2-3 times/week)', 'High (daily workouts)'];
  final List<String> dietQualities = ['Poor (junk food mostly)', 'Average (mix of good/bad)', 'Good (balanced diet)'];
  final List<String> sleepQuality = ['Poor', 'Fair', 'Good', 'Excellent'];
  final List<String> conditions = ['Diabetes', 'Hypertension', 'Heart Disease', 'Other'];

  String? selectedAge;
  String? selectedGender;
  Set<String> selectedRisks = {};
  String? selectedActivity;
  String? selectedDiet;
  String? selectedSleep;
  Set<String> selectedConditions = {};
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  void nextStep() async {
    if (step < 7) {
      setState(() => step++);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('userExists', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompletionPage()),
        );
      }
    }
  }

  void previousStep() {
    if (step > 0) {
      setState(() => step--);
    }
  }

  Widget buildChips<T>({
    required List<T> items,
    required dynamic selected,
    required void Function(T) onSelect,
    bool multi = false,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        final isSelected = multi
            ? (selected as Set).contains(item)
            : selected == item;
        return ChoiceChip(
          label: Text(item.toString()),
          selected: isSelected,
          onSelected: (_) {
            onSelect(item);
            if (!multi) nextStep();
          },
          selectedColor: Colors.deepPurple,
          backgroundColor: Colors.grey[800],
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
        );
      }).toList(),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _buildQuestion(
          "How old are you?",
          buildChips(
            items: ageGroups,
            selected: selectedAge,
            onSelect: (val) {
              setState(() {
                selectedAge = val;
                answers['age'] = val;
              });
            },
          ),
        );
      case 1:
        return _buildQuestion(
          "What’s your gender?",
          buildChips(
            items: genders,
            selected: selectedGender,
            onSelect: (val) {
              setState(() {
                selectedGender = val;
                answers['gender'] = val;
              });
            },
          ),
        );
      case 2:
        return _buildQuestion(
          "Do you have any risk habits?",
          buildChips(
            items: risks,
            selected: selectedRisks,
            onSelect: (val) {
              setState(() {
                if (selectedRisks.contains(val)) {
                  selectedRisks.remove(val);
                } else {
                  selectedRisks.add(val);
                }
                answers['risks'] = selectedRisks.toList();
              });
            },
            multi: true,
          ),
        );
      case 3:
        return _buildQuestion(
          "How physically active are you?",
          buildChips(
            items: activityLevels,
            selected: selectedActivity,
            onSelect: (val) {
              setState(() {
                selectedActivity = val;
                answers['activity'] = val;
              });
            },
          ),
        );
      case 4:
        return _buildQuestion(
          "How would you rate your diet?",
          buildChips(
            items: dietQualities,
            selected: selectedDiet,
            onSelect: (val) {
              setState(() {
                selectedDiet = val;
                answers['diet'] = val;
              });
            },
          ),
        );
      case 5:
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
                "Let’s talk numbers: Your weight and height",
                style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: weightController,
                decoration: const InputDecoration(
                labelText: "Weight (kg)",
                filled: true,
                fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                setState(() {
                    answers['weight'] = val;
                });
                },
            ),
            const SizedBox(height: 10),
            TextField(
                controller: heightController,
                decoration: const InputDecoration(
                labelText: "Height (cm)",
                filled: true,
                fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                setState(() {
                    answers['height'] = val;
                });
                },
            ),
            ],
        );
      case 6:
        return _buildQuestion(
          "Do you have any chronic conditions?",
          buildChips(
            items: conditions,
            selected: selectedConditions,
            onSelect: (val) {
              setState(() {
                if (selectedConditions.contains(val)) {
                  selectedConditions.remove(val);
                } else {
                  selectedConditions.add(val);
                }
                answers['conditions'] = selectedConditions.toList();
              });
            },
            multi: true,
          ),
        );
      case 7:
        return _buildQuestion(
          "How’s your sleep quality lately?",
          buildChips(
            items: sleepQuality,
            selected: selectedSleep,
            onSelect: (val) {
              setState(() {
                selectedSleep = val;
                answers['sleep'] = val;
              });
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuestion(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 15),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (step + 1) / 8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  if (step > 0)
                    TextButton(
                      onPressed: previousStep,
                      child: const Text("← Back", style: TextStyle(color: Colors.white)),
                    ),
                  const Spacer(),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[900],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(child: _buildStep()),
              if (step == 2 || step == 6 || step == 5)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if ((step == 2 && selectedRisks.isNotEmpty) ||
                          (step == 5 && weightController.text.isNotEmpty && heightController.text.isNotEmpty) ||
                          (step == 6 && selectedConditions.isNotEmpty)) {
                        nextStep();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Next"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completed")),
      body: const Center(
        child: Text("Thanks! You’re all set.", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
