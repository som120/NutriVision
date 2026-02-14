import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ServerException;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/meal_entity.dart';
import '../models/meal_model.dart';

/// Remote data source for meal/scanner operations
class MealRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  late final GenerativeModel _model;
  static const _uuid = Uuid();

  MealRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    String? apiKey,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance {
    _model = GenerativeModel(
      model: ApiConstants.geminiModel,
      apiKey: apiKey ?? ApiConstants.geminiApiKey,
    );
  }

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Not authenticated');
    return user.uid;
  }

  /// Analyze food image using Gemini AI
  Future<MealModel> analyzeFood({
    required String imagePath,
    MealType mealType = MealType.snack,
  }) async {
    try {
      final imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      final content = [
        Content.multi([
          TextPart(AppConstants.nutritionAnalysisPrompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw const AIException(
          message: 'AI did not return a response. Please try again.',
        );
      }

      // Parse the JSON response - handle markdown code blocks
      String jsonString = text.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(imagePath);

      return MealModel.fromAIResponse(
        userId: _userId,
        json: jsonData,
        imageUrl: imageUrl,
        mealType: mealType,
      );
    } on AIException {
      rethrow;
    } on FormatException {
      throw const AIException(
        message: 'Failed to parse AI response. Please try again.',
      );
    } catch (e) {
      throw AIException(message: 'Food analysis failed: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<String> _uploadImage(String imagePath) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('meals/$_userId/$fileName');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
    } catch (e) {
      // Image upload failure shouldn't block meal saving
      return '';
    }
  }

  /// Save meal to Firestore
  Future<String> saveMeal(MealModel meal) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.mealsCollection)
          .add(meal.toFirestore());

      // Update daily log
      await _updateDailyLog(meal);

      return docRef.id;
    } catch (e) {
      throw ServerException(message: 'Failed to save meal: $e');
    }
  }

  /// Delete meal from Firestore
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.mealsCollection)
          .doc(mealId)
          .delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete meal: $e');
    }
  }

  /// Get meals for a specific date
  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.mealsCollection)
          .where(
            'loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get meals: $e');
    }
  }

  /// Get meals for a date range
  Future<List<MealModel>> getMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.mealsCollection)
          .where(
            'loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get meals: $e');
    }
  }

  /// Get recent meals
  Future<List<MealModel>> getRecentMeals({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.mealsCollection)
          .orderBy('loggedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get recent meals: $e');
    }
  }

  /// Stream of today's meals
  Stream<List<MealModel>> watchTodayMeals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(_userId)
        .collection(AppConstants.mealsCollection)
        .where(
          'loggedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('loggedAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('loggedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MealModel.fromFirestore(doc)).toList(),
        );
  }

  /// Update daily log when a meal is added
  Future<void> _updateDailyLog(MealModel meal) async {
    try {
      final date = DateTime(
        meal.loggedAt.year,
        meal.loggedAt.month,
        meal.loggedAt.day,
      );
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final logRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(_userId)
          .collection(AppConstants.dailyLogsCollection)
          .doc(dateKey);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(logRef);

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          transaction.update(logRef, {
            'totalCalories':
                (data['totalCalories'] as num? ?? 0) + meal.calories,
            'totalProtein':
                (data['totalProtein'] as num? ?? 0) +
                meal.macronutrients.protein,
            'totalCarbs':
                (data['totalCarbs'] as num? ?? 0) +
                meal.macronutrients.carbohydrates,
            'totalFat':
                (data['totalFat'] as num? ?? 0) + meal.macronutrients.fat,
            'totalFiber':
                (data['totalFiber'] as num? ?? 0) + meal.macronutrients.fiber,
            'mealCount': (data['mealCount'] as num? ?? 0) + 1,
          });
        } else {
          transaction.set(logRef, {
            'userId': _userId,
            'date': Timestamp.fromDate(date),
            'totalCalories': meal.calories,
            'totalProtein': meal.macronutrients.protein,
            'totalCarbs': meal.macronutrients.carbohydrates,
            'totalFat': meal.macronutrients.fat,
            'totalFiber': meal.macronutrients.fiber,
            'mealCount': 1,
            'waterIntakeMl': 0,
          });
        }
      });
    } catch (_) {
      // Daily log update failure shouldn't block meal saving
    }
  }
}
