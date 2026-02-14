/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'NutriVision';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered food nutrition tracker';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String mealsCollection = 'meals';
  static const String dailyLogsCollection = 'daily_logs';

  // AI Prompt
  static const String nutritionAnalysisPrompt = '''
Analyze this food image and provide detailed nutritional information.
Return the response as a valid JSON object with the following structure:
{
  "food_name": "Name of the food item",
  "serving_size": "Estimated serving size (e.g., '1 cup', '100g')",
  "calories": numeric_value,
  "macronutrients": {
    "protein": {"value": numeric_value, "unit": "g"},
    "carbohydrates": {"value": numeric_value, "unit": "g"},
    "fat": {"value": numeric_value, "unit": "g"},
    "fiber": {"value": numeric_value, "unit": "g"},
    "sugar": {"value": numeric_value, "unit": "g"}
  },
  "micronutrients": {
    "vitamin_a": {"value": numeric_value, "unit": "mcg"},
    "vitamin_c": {"value": numeric_value, "unit": "mg"},
    "calcium": {"value": numeric_value, "unit": "mg"},
    "iron": {"value": numeric_value, "unit": "mg"},
    "potassium": {"value": numeric_value, "unit": "mg"},
    "sodium": {"value": numeric_value, "unit": "mg"}
  },
  "confidence_score": numeric_value_between_0_and_1,
  "food_category": "Category (e.g., 'Fruit', 'Protein', 'Dairy')",
  "health_notes": ["list", "of", "brief", "health", "notes"]
}
Only return the JSON object, no additional text.
''';

  // Daily Goals (defaults)
  static const double defaultCalorieGoal = 2000;
  static const double defaultProteinGoal = 50; // grams
  static const double defaultCarbsGoal = 300; // grams
  static const double defaultFatGoal = 65; // grams
  static const double defaultFiberGoal = 25; // grams

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Cache Keys
  static const String themeModeCacheKey = 'theme_mode';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userGoalsCacheKey = 'user_goals';
}
