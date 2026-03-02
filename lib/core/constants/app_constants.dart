const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.68.51:8122/api/v1',
);

const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

// Firebase web config
const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const String firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const String firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');

// Google OAuth (web)
const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

const String langKey = 'lang';
const String defaultLang = 'he';

class AppRoles {
  static const String client = 'client';
  static const String serviceProvider = 'serviceProvider';
  static const String businessOwner = 'businessOwner';
  static const String companyOwner = 'companyOwner';
}

class AppointmentStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String canceled = 'canceled';
  static const String completed = 'completed';
}

class RegistrationStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class Days {
  static const List<String> all = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
}

const int connectTimeoutSeconds = 10;
const int receiveTimeoutSeconds = 15;
