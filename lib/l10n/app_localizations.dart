import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// No description provided for @appName.
  ///
  /// In he, this message translates to:
  /// **'תורי'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In he, this message translates to:
  /// **'התחברות'**
  String get login;

  /// No description provided for @loginWithGoogle.
  ///
  /// In he, this message translates to:
  /// **'התחבר עם Google'**
  String get loginWithGoogle;

  /// No description provided for @continueAsClient.
  ///
  /// In he, this message translates to:
  /// **'המשך כלקוח'**
  String get continueAsClient;

  /// No description provided for @continueAsBusiness.
  ///
  /// In he, this message translates to:
  /// **'המשך כבעל עסק'**
  String get continueAsBusiness;

  /// No description provided for @phoneVerification.
  ///
  /// In he, this message translates to:
  /// **'אימות מספר טלפון'**
  String get phoneVerification;

  /// No description provided for @enterPhone.
  ///
  /// In he, this message translates to:
  /// **'הכנס מספר טלפון'**
  String get enterPhone;

  /// No description provided for @sendOtp.
  ///
  /// In he, this message translates to:
  /// **'שלח קוד אימות'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In he, this message translates to:
  /// **'הכנס קוד אימות'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In he, this message translates to:
  /// **'אמת קוד'**
  String get verifyOtp;

  /// No description provided for @home.
  ///
  /// In he, this message translates to:
  /// **'ראשי'**
  String get home;

  /// No description provided for @appointments.
  ///
  /// In he, this message translates to:
  /// **'תורים'**
  String get appointments;

  /// No description provided for @myAppointments.
  ///
  /// In he, this message translates to:
  /// **'התורים שלי'**
  String get myAppointments;

  /// No description provided for @bookAppointment.
  ///
  /// In he, this message translates to:
  /// **'קבע תור'**
  String get bookAppointment;

  /// No description provided for @cancelAppointment.
  ///
  /// In he, this message translates to:
  /// **'בטל תור'**
  String get cancelAppointment;

  /// No description provided for @appointmentDetails.
  ///
  /// In he, this message translates to:
  /// **'פרטי תור'**
  String get appointmentDetails;

  /// No description provided for @services.
  ///
  /// In he, this message translates to:
  /// **'שירותים'**
  String get services;

  /// No description provided for @myServices.
  ///
  /// In he, this message translates to:
  /// **'השירותים שלי'**
  String get myServices;

  /// No description provided for @addService.
  ///
  /// In he, this message translates to:
  /// **'הוסף שירות'**
  String get addService;

  /// No description provided for @editService.
  ///
  /// In he, this message translates to:
  /// **'ערוך שירות'**
  String get editService;

  /// No description provided for @profile.
  ///
  /// In he, this message translates to:
  /// **'פרופיל'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In he, this message translates to:
  /// **'הגדרות'**
  String get settings;

  /// No description provided for @business.
  ///
  /// In he, this message translates to:
  /// **'עסק'**
  String get business;

  /// No description provided for @businessSettings.
  ///
  /// In he, this message translates to:
  /// **'הגדרות עסק'**
  String get businessSettings;

  /// No description provided for @clients.
  ///
  /// In he, this message translates to:
  /// **'לקוחות'**
  String get clients;

  /// No description provided for @serviceProviders.
  ///
  /// In he, this message translates to:
  /// **'נותני שירות'**
  String get serviceProviders;

  /// No description provided for @stats.
  ///
  /// In he, this message translates to:
  /// **'סטטיסטיקות'**
  String get stats;

  /// No description provided for @daily.
  ///
  /// In he, this message translates to:
  /// **'יומי'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In he, this message translates to:
  /// **'חודשי'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In he, this message translates to:
  /// **'שנתי'**
  String get yearly;

  /// No description provided for @notifications.
  ///
  /// In he, this message translates to:
  /// **'התראות'**
  String get notifications;

  /// No description provided for @sendNotification.
  ///
  /// In he, this message translates to:
  /// **'שלח התראה'**
  String get sendNotification;

  /// No description provided for @admin.
  ///
  /// In he, this message translates to:
  /// **'ניהול'**
  String get admin;

  /// No description provided for @allBusinesses.
  ///
  /// In he, this message translates to:
  /// **'כל העסקים'**
  String get allBusinesses;

  /// No description provided for @allUsers.
  ///
  /// In he, this message translates to:
  /// **'כל המשתמשים'**
  String get allUsers;

  /// No description provided for @cancel.
  ///
  /// In he, this message translates to:
  /// **'ביטול'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In he, this message translates to:
  /// **'אישור'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In he, this message translates to:
  /// **'שמור'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In he, this message translates to:
  /// **'מחק'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In he, this message translates to:
  /// **'ערוך'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In he, this message translates to:
  /// **'טוען...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In he, this message translates to:
  /// **'נסה שוב'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In he, this message translates to:
  /// **'אין נתונים להצגה'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In he, this message translates to:
  /// **'שגיאה'**
  String get error;

  /// No description provided for @success.
  ///
  /// In he, this message translates to:
  /// **'הצלחה'**
  String get success;

  /// No description provided for @logout.
  ///
  /// In he, this message translates to:
  /// **'התנתקות'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In he, this message translates to:
  /// **'שם'**
  String get name;

  /// No description provided for @firstName.
  ///
  /// In he, this message translates to:
  /// **'שם פרטי'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In he, this message translates to:
  /// **'שם משפחה'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In he, this message translates to:
  /// **'אימייל'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In he, this message translates to:
  /// **'טלפון'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In he, this message translates to:
  /// **'כתובת'**
  String get address;

  /// No description provided for @price.
  ///
  /// In he, this message translates to:
  /// **'מחיר'**
  String get price;

  /// No description provided for @duration.
  ///
  /// In he, this message translates to:
  /// **'משך'**
  String get duration;

  /// No description provided for @minutes.
  ///
  /// In he, this message translates to:
  /// **'דקות'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get hours;

  /// No description provided for @date.
  ///
  /// In he, this message translates to:
  /// **'תאריך'**
  String get date;

  /// No description provided for @time.
  ///
  /// In he, this message translates to:
  /// **'שעה'**
  String get time;

  /// No description provided for @status.
  ///
  /// In he, this message translates to:
  /// **'סטטוס'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In he, this message translates to:
  /// **'ממתין'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In he, this message translates to:
  /// **'מאושר'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In he, this message translates to:
  /// **'נדחה'**
  String get rejected;

  /// No description provided for @confirmed.
  ///
  /// In he, this message translates to:
  /// **'מאושר'**
  String get confirmed;

  /// No description provided for @canceled.
  ///
  /// In he, this message translates to:
  /// **'בוטל'**
  String get canceled;

  /// No description provided for @completed.
  ///
  /// In he, this message translates to:
  /// **'הושלם'**
  String get completed;

  /// No description provided for @waitingApproval.
  ///
  /// In he, this message translates to:
  /// **'ממתין לאישור'**
  String get waitingApproval;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In he, this message translates to:
  /// **'נדרשת הרשאת התראות'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionBody.
  ///
  /// In he, this message translates to:
  /// **'אפליקציה זו דורשת הרשאת התראות על מנת להזכיר לך את התורים שלך.'**
  String get notificationPermissionBody;

  /// No description provided for @openSettings.
  ///
  /// In he, this message translates to:
  /// **'פתח הגדרות'**
  String get openSettings;

  /// No description provided for @addToCalendar.
  ///
  /// In he, this message translates to:
  /// **'הוסף ליומן'**
  String get addToCalendar;

  /// No description provided for @addToCalendarQuestion.
  ///
  /// In he, this message translates to:
  /// **'להוסיף את התור ליומן?'**
  String get addToCalendarQuestion;

  /// No description provided for @yes.
  ///
  /// In he, this message translates to:
  /// **'כן'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In he, this message translates to:
  /// **'לא'**
  String get no;

  /// No description provided for @totalRevenue.
  ///
  /// In he, this message translates to:
  /// **'סך הכנסות'**
  String get totalRevenue;

  /// No description provided for @workingHours.
  ///
  /// In he, this message translates to:
  /// **'שעות עבודה'**
  String get workingHours;

  /// No description provided for @newClients.
  ///
  /// In he, this message translates to:
  /// **'לקוחות חדשים'**
  String get newClients;

  /// No description provided for @cancellationRate.
  ///
  /// In he, this message translates to:
  /// **'אחוז ביטולים'**
  String get cancellationRate;

  /// No description provided for @totalAppointments.
  ///
  /// In he, this message translates to:
  /// **'סך תורים'**
  String get totalAppointments;

  /// No description provided for @joinBusiness.
  ///
  /// In he, this message translates to:
  /// **'הצטרף לעסק'**
  String get joinBusiness;

  /// No description provided for @selectBusiness.
  ///
  /// In he, this message translates to:
  /// **'בחר עסק'**
  String get selectBusiness;

  /// No description provided for @inviteServiceProvider.
  ///
  /// In he, this message translates to:
  /// **'הזמן נותן שירות'**
  String get inviteServiceProvider;

  /// No description provided for @businessName.
  ///
  /// In he, this message translates to:
  /// **'שם העסק'**
  String get businessName;

  /// No description provided for @uploadLogo.
  ///
  /// In he, this message translates to:
  /// **'העלה לוגו'**
  String get uploadLogo;

  /// No description provided for @searchAddress.
  ///
  /// In he, this message translates to:
  /// **'חפש כתובת'**
  String get searchAddress;

  /// No description provided for @language.
  ///
  /// In he, this message translates to:
  /// **'שפה'**
  String get language;

  /// No description provided for @hebrew.
  ///
  /// In he, this message translates to:
  /// **'עברית'**
  String get hebrew;

  /// No description provided for @english.
  ///
  /// In he, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @deleteConfirm.
  ///
  /// In he, this message translates to:
  /// **'אישור מחיקה'**
  String get deleteConfirm;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק? פעולה זו אינה ניתנת לביטול.'**
  String get deleteConfirmBody;

  /// No description provided for @cancelAppointmentConfirm.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לבטל את התור?'**
  String get cancelAppointmentConfirm;

  /// No description provided for @notificationTitle.
  ///
  /// In he, this message translates to:
  /// **'כותרת ההתראה'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In he, this message translates to:
  /// **'תוכן ההתראה'**
  String get notificationBody;

  /// No description provided for @sendToAll.
  ///
  /// In he, this message translates to:
  /// **'שלח לכולם'**
  String get sendToAll;

  /// No description provided for @sendToMyClients.
  ///
  /// In he, this message translates to:
  /// **'שלח ללקוחות שלי'**
  String get sendToMyClients;

  /// No description provided for @disableBusiness.
  ///
  /// In he, this message translates to:
  /// **'השבת עסק'**
  String get disableBusiness;

  /// No description provided for @disableUsers.
  ///
  /// In he, this message translates to:
  /// **'השבת לקוחות'**
  String get disableUsers;

  /// No description provided for @enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In he, this message translates to:
  /// **'השבת'**
  String get disable;

  /// No description provided for @validationRequired.
  ///
  /// In he, this message translates to:
  /// **'שדה חובה'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In he, this message translates to:
  /// **'אימייל לא תקין'**
  String get validationEmail;

  /// No description provided for @validationPhone.
  ///
  /// In he, this message translates to:
  /// **'מספר טלפון לא תקין'**
  String get validationPhone;

  /// No description provided for @validationMinLength.
  ///
  /// In he, this message translates to:
  /// **'מינימום {min} תווים'**
  String validationMinLength(int min);

  /// No description provided for @selectDate.
  ///
  /// In he, this message translates to:
  /// **'בחר תאריך'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In he, this message translates to:
  /// **'בחר שעה'**
  String get selectTime;

  /// No description provided for @availableDays.
  ///
  /// In he, this message translates to:
  /// **'ימי פעילות'**
  String get availableDays;

  /// No description provided for @workingHoursTitle.
  ///
  /// In he, this message translates to:
  /// **'שעות עבודה'**
  String get workingHoursTitle;

  /// No description provided for @notes.
  ///
  /// In he, this message translates to:
  /// **'הערות'**
  String get notes;

  /// No description provided for @serviceImage.
  ///
  /// In he, this message translates to:
  /// **'תמונת שירות'**
  String get serviceImage;

  /// No description provided for @sun.
  ///
  /// In he, this message translates to:
  /// **'ראשון'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In he, this message translates to:
  /// **'שני'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In he, this message translates to:
  /// **'שלישי'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In he, this message translates to:
  /// **'רביעי'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In he, this message translates to:
  /// **'חמישי'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In he, this message translates to:
  /// **'שישי'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In he, this message translates to:
  /// **'שבת'**
  String get sat;

  /// No description provided for @currencySymbol.
  ///
  /// In he, this message translates to:
  /// **'₪'**
  String get currencySymbol;

  /// No description provided for @inviteClient.
  ///
  /// In he, this message translates to:
  /// **'הזמן לקוח'**
  String get inviteClient;

  /// No description provided for @inviteMembers.
  ///
  /// In he, this message translates to:
  /// **'הזמן חברים'**
  String get inviteMembers;

  /// No description provided for @about.
  ///
  /// In he, this message translates to:
  /// **'אודות'**
  String get about;

  /// No description provided for @roleClient.
  ///
  /// In he, this message translates to:
  /// **'לקוח'**
  String get roleClient;

  /// No description provided for @roleServiceProvider.
  ///
  /// In he, this message translates to:
  /// **'נותן שירות'**
  String get roleServiceProvider;

  /// No description provided for @roleBusinessOwner.
  ///
  /// In he, this message translates to:
  /// **'בעל עסק'**
  String get roleBusinessOwner;

  /// No description provided for @roleCompanyOwner.
  ///
  /// In he, this message translates to:
  /// **'בעל חברה'**
  String get roleCompanyOwner;

  /// No description provided for @selectServiceProvider.
  ///
  /// In he, this message translates to:
  /// **'בחר נותן שירות'**
  String get selectServiceProvider;

  /// No description provided for @anyServiceProvider.
  ///
  /// In he, this message translates to:
  /// **'כל נותן שירות'**
  String get anyServiceProvider;

  /// No description provided for @confirmBooking.
  ///
  /// In he, this message translates to:
  /// **'אשר הזמנה'**
  String get confirmBooking;

  /// No description provided for @upcoming.
  ///
  /// In he, this message translates to:
  /// **'קרובים'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In he, this message translates to:
  /// **'עבר'**
  String get past;

  /// No description provided for @active.
  ///
  /// In he, this message translates to:
  /// **'פעיל'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In he, this message translates to:
  /// **'לא פעיל'**
  String get inactive;

  /// No description provided for @remindersEnabled.
  ///
  /// In he, this message translates to:
  /// **'תזכורות מופעלות'**
  String get remindersEnabled;

  /// No description provided for @approve.
  ///
  /// In he, this message translates to:
  /// **'אשר'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In he, this message translates to:
  /// **'דחה'**
  String get reject;

  /// No description provided for @shareLink.
  ///
  /// In he, this message translates to:
  /// **'שתף קישור'**
  String get shareLink;

  /// No description provided for @scanQrToJoin.
  ///
  /// In he, this message translates to:
  /// **'סרוק QR להצטרפות'**
  String get scanQrToJoin;

  /// No description provided for @inviteClientQr.
  ///
  /// In he, this message translates to:
  /// **'הזמן לקוח באמצעות QR'**
  String get inviteClientQr;

  /// No description provided for @inviteProviderQr.
  ///
  /// In he, this message translates to:
  /// **'הזמן נותן שירות באמצעות QR'**
  String get inviteProviderQr;

  /// No description provided for @inviteAs.
  ///
  /// In he, this message translates to:
  /// **'הזמן בתור'**
  String get inviteAs;

  /// No description provided for @spName.
  ///
  /// In he, this message translates to:
  /// **'שם נותן השירות'**
  String get spName;

  /// No description provided for @spEmail.
  ///
  /// In he, this message translates to:
  /// **'אימייל נותן השירות'**
  String get spEmail;

  /// No description provided for @inviteSent.
  ///
  /// In he, this message translates to:
  /// **'ההזמנה נשלחה!'**
  String get inviteSent;

  /// No description provided for @serviceName.
  ///
  /// In he, this message translates to:
  /// **'שם השירות'**
  String get serviceName;

  /// No description provided for @serviceDuration.
  ///
  /// In he, this message translates to:
  /// **'משך (דקות)'**
  String get serviceDuration;

  /// No description provided for @servicePrice.
  ///
  /// In he, this message translates to:
  /// **'מחיר (₪)'**
  String get servicePrice;

  /// No description provided for @createService.
  ///
  /// In he, this message translates to:
  /// **'צור שירות'**
  String get createService;

  /// No description provided for @step.
  ///
  /// In he, this message translates to:
  /// **'שלב {step} מתוך {total}'**
  String step(int step, int total);

  /// No description provided for @chooseService.
  ///
  /// In he, this message translates to:
  /// **'בחר שירות'**
  String get chooseService;

  /// No description provided for @chooseProvider.
  ///
  /// In he, this message translates to:
  /// **'בחר נותן שירות'**
  String get chooseProvider;

  /// No description provided for @chooseDateTime.
  ///
  /// In he, this message translates to:
  /// **'בחר תאריך ושעה'**
  String get chooseDateTime;

  /// No description provided for @bookingSummary.
  ///
  /// In he, this message translates to:
  /// **'סיכום הזמנה'**
  String get bookingSummary;

  /// No description provided for @service.
  ///
  /// In he, this message translates to:
  /// **'שירות'**
  String get service;

  /// No description provided for @provider.
  ///
  /// In he, this message translates to:
  /// **'נותן שירות'**
  String get provider;

  /// No description provided for @pendingApproval.
  ///
  /// In he, this message translates to:
  /// **'ממתין לאישור'**
  String get pendingApproval;

  /// No description provided for @businessLogo.
  ///
  /// In he, this message translates to:
  /// **'לוגו העסק'**
  String get businessLogo;

  /// No description provided for @toggleReminders.
  ///
  /// In he, this message translates to:
  /// **'שנה מצב תזכורות'**
  String get toggleReminders;

  /// No description provided for @noServiceProviders.
  ///
  /// In he, this message translates to:
  /// **'אין נותני שירות עדיין'**
  String get noServiceProviders;

  /// No description provided for @noClients.
  ///
  /// In he, this message translates to:
  /// **'אין לקוחות עדיין'**
  String get noClients;

  /// No description provided for @spSpecialty.
  ///
  /// In he, this message translates to:
  /// **'התמחות'**
  String get spSpecialty;

  /// No description provided for @anyProvider.
  ///
  /// In he, this message translates to:
  /// **'כל נותן שירות פנוי'**
  String get anyProvider;

  /// No description provided for @logoutConfirm.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך להתנתק?'**
  String get logoutConfirm;

  /// No description provided for @manageClients.
  ///
  /// In he, this message translates to:
  /// **'נהל את הלקוחות שלך'**
  String get manageClients;

  /// No description provided for @manageProviders.
  ///
  /// In he, this message translates to:
  /// **'צפה ונהל את הצוות שלך'**
  String get manageProviders;

  /// No description provided for @manageBusinessSettings.
  ///
  /// In he, this message translates to:
  /// **'ערוך שם, לוגו ותזכורות'**
  String get manageBusinessSettings;

  /// No description provided for @completedLabel.
  ///
  /// In he, this message translates to:
  /// **'הושלם'**
  String get completedLabel;

  /// No description provided for @canceledLabel.
  ///
  /// In he, this message translates to:
  /// **'בוטל'**
  String get canceledLabel;

  /// No description provided for @editProfile.
  ///
  /// In he, this message translates to:
  /// **'ערוך פרופיל'**
  String get editProfile;

  /// No description provided for @deactivate.
  ///
  /// In he, this message translates to:
  /// **'השבת'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In he, this message translates to:
  /// **'הפעל'**
  String get activate;

  /// No description provided for @businessInfo.
  ///
  /// In he, this message translates to:
  /// **'פרטי עסק'**
  String get businessInfo;

  /// No description provided for @adminActions.
  ///
  /// In he, this message translates to:
  /// **'פעולות ניהול'**
  String get adminActions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
