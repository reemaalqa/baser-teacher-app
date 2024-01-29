import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:logger/logger.dart';

//database urls
//Please add your admin panel url here and make sure you do not add '/' at the end of the url
// const String baseUrl = "https://eschool.wrteam.me"; //https://eschool.wrteam.me
const String baseUrl = "https://e-system.labs2030.com"; //https://eschool.wrteam.me

//please do not change the below 2 values it's for convience of usage in code
const String databaseUrl = "$baseUrl/api/";
const String storageUrl = "$baseUrl/storage/";

//error message display duration
const Duration errorMessageDisplayDuration = Duration(milliseconds: 3000);

//the limit used in pagination APIs where offset and limit logic is used, change to fetch items accordingly
const int offsetLimitPaginationAPIDefaultItemFetchLimit = 15;

//chat message sending related controls
const int maxFilesOrImagesInOneMessage = 30;
const int maxFileSizeInBytesCanBeSent =
10000000; //1000000 = 1 MB (default is 10000000 = 10 MB)
const int maxCharactersInATextMessage = 500;

//notification channel keys
const String notificationChannelKey = "basic_channel";
const String chatNotificationChannelKey = "chat_notifications_channel";

//demo mode to disable a few features
const bool isDemoVersion = false;

//to enable and disable default credentials in login page
const bool showDefaultCredentials = false;
//default credentials of teacher
const String defaultTeacherEmail = "teacher@gmail.com";
const String defaultTeacherPassword = "teacher123";

//animations configuration
//if this is false all item appearance animations will be turned off
const bool isApplicationItemAnimationOn = true;
//note: do not add Milliseconds values less then 10 as it'll result in errors
const int listItemAnimationDelayInMilliseconds = 100;
const int itemFadeAnimationDurationInMilliseconds = 250;
const int itemZoomAnimationDurationInMilliseconds = 200;
const int itemBouncScaleAnimationDurationInMilliseconds = 200;

String getExamStatusTypeKey(String examStatus) {
  if (examStatus == "0") {
    return upComingKey;
  }
  if (examStatus == "1") {
    return onGoingKey;
  }
  return completedKey;
}

List<String> examFilters = [allExamsKey, upComingKey, onGoingKey, completedKey];

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: false // Should each log logger.i contain a timestamp
  ),
);