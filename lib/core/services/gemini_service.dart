import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'storage_service.dart';

class GeminiService {
  final StorageService _storageService;

  GeminiService(this._storageService);

  GenerativeModel? _getModel() {
    final key = _storageService.getGeminiApiKey();
    if (key.trim().isEmpty) return null;
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
    );
  }

  // Task 1: Journal Analysis
  Future<Map<String, dynamic>> analyzeJournal(String content, Map<String, dynamic> studentProfile) async {
    final model = _getModel();
    if (model == null) {
      throw Exception('Gemini API key is not configured. Please add your key in Settings.');
    }

    final prompt = '''
You are an expert AI Mental Wellness Coach and UX Psychologist specializing in helping competitive exam students (preparing for ${studentProfile['examType']}).
Analyze the following student daily journal entry. 
Determine wellness parameters, identify recurring stressors, detect triggers, and output EXACTLY a JSON object matching the schema below. 
Do not include any markdown formatting (like ```json ... ```), just output the raw JSON string.
If the journal content is too short or lacks context, make a reasonable estimate, but never fail.

Student info:
- Exam type: ${studentProfile['examType']}
- Target Exam Date: ${studentProfile['targetExamDate']}
- Daily study hours: ${studentProfile['dailyStudyHours']}
- Intake stress level: ${studentProfile['currentStressLevel']}

Journal entry:
"$content"

Target JSON Schema:
{
  "wellnessScore": <integer, 0-100 indicating general emotional stability and wellness>,
  "stressScore": <integer, 0-100 indicating anxiety and pressure level>,
  "focusScore": <integer, 0-100 indicating focus and study concentration capability>,
  "triggers": [<string list of identified triggers from: "Exam Pressure", "Poor Sleep", "Social Comparison", "Family Expectations", "Time Management", "Fear of Failure">],
  "emotionalSummary": "<empathetic, brief summary paragraph of the student's emotional state>",
  "insights": [<string list of 2-3 deep behavioral observations regarding their preparation stress or mental patterns>],
  "recommendations": [<string list of 2-3 specific, actionable stress-relief recommendations suited for a competitive exam student (e.g. pomodoro, walks, breathwork)>]
}
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Clean up markdown markers if any
      var cleanJson = text.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gemini AI failed to analyze journal: $e');
    }
  }

  // Task 2: Wellness Chat Coach
  Future<String> chatCoach(List<Content> history, String newMessage, Map<String, dynamic> studentProfile) async {
    final key = _storageService.getGeminiApiKey();
    if (key.trim().isEmpty) {
      return 'MindMate Coach: Gemini API key is not configured. Please open Settings and add your API key.';
    }

    final systemInstruction = '''
You are MindMate Coach, an empathetic, supportive, and non-judgmental AI Wellness Coach for competitive exam aspirants.
The student is preparing for ${studentProfile['examType']} (daily study hours: ${studentProfile['dailyStudyHours']}, current stress level: ${studentProfile['currentStressLevel']}).
Your goal is to offer emotional support, suggest coping strategies, and help them maintain study-life balance.
Guidelines:
- Maintain an empathetic, motivational, and constructive tone.
- Do NOT provide medical or psychological diagnoses.
- Keep responses relatively brief (1-3 paragraphs) so it's readable on a chat screen.
- Provide practical study-stress techniques (e.g., box breathing, box scheduling, cognitive reframing).
''';

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
      systemInstruction: Content.system(systemInstruction),
    );

    try {
      final chat = model.startChat(
        history: history,
      );
      final response = await chat.sendMessage(Content.text(newMessage));
      return response.text ?? 'I could not process that request. Please try again.';
    } catch (e) {
      return 'Sorry, I encountered an issue: $e';
    }
  }

  // Task 3: Adaptive Mindfulness Exercises
  Future<Map<String, dynamic>> generateMindfulnessExercise(String type, Map<String, dynamic> studentProfile) async {
    final model = _getModel();
    if (model == null) {
      throw Exception('Gemini API key is not configured.');
    }

    final prompt = '''
Generate a custom, personalized mindfulness exercise for a student preparing for the ${studentProfile['examType']} exam.
The user requested a "$type" exercise. (Supported types: "Deep Breathing", "Focus Reset", "Gratitude Reflection", "Exam Anxiety Relief", "Confidence Boost").
Output EXACTLY a JSON object matching the schema below. 
Do not include any markdown formatting (like ```json ... ```), just output the raw JSON string.

Target JSON Schema:
{
  "title": "<short engaging title of the exercise>",
  "description": "<brief description of how it helps exam students>",
  "durationSeconds": <integer, typically between 60 and 300>,
  "steps": [<string list of 3-5 sequential instructions for the user to follow>]
}
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var cleanJson = response.text ?? '';
      cleanJson = cleanJson.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate mindfulness exercise: $e');
    }
  }

  // Task 4: Motivation Engine
  Future<String> generateMotivationMessage(Map<String, dynamic> studentProfile, double wellnessScore) async {
    final model = _getModel();
    if (model == null) {
      return 'Keep pushing forward! Every small step counts toward your dream.';
    }

    final prompt = '''
Generate a single, powerful, uplifting motivational sentence or short paragraph (max 30 words) for a student preparing for the ${studentProfile['examType']} competitive exam.
The student has a current wellness score of $wellnessScore/100 and study goal of ${studentProfile['dailyStudyHours']} hours.
Make it deeply inspiring, empathetic, and tailored to competitive prep. Do not include quotes or authors. Just the raw message.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Believe in yourself. You have the capability to conquer your goals!';
    } catch (_) {
      return 'Your dedication today is building the success of tomorrow. Keep going!';
    }
  }
}
