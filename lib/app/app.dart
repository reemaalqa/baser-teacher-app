import 'dart:io';

import 'package:eschool_teacher/app/appLocalization.dart';
import 'package:eschool_teacher/app/routes.dart';
import 'package:eschool_teacher/cubits/appConfigurationCubit.dart';
import 'package:eschool_teacher/cubits/appLocalizationCubit.dart';
import 'package:eschool_teacher/cubits/authCubit.dart';
import 'package:eschool_teacher/cubits/internetConnectivityCubit.dart';
import 'package:eschool_teacher/cubits/myClassesCubit.dart';

import 'package:eschool_teacher/data/repositories/authRepository.dart';
import 'package:eschool_teacher/data/repositories/settingsRepository.dart';
import 'package:eschool_teacher/data/repositories/systemInfoRepository.dart';
import 'package:eschool_teacher/data/repositories/teacherRepository.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/utils/appLanguages.dart';
import 'package:eschool_teacher/utils/hiveBoxKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:eschool_teacher/utils/notificationUtility.dart';

import '../cubits/chat/chatUsersCubit.dart';
import '../data/repositories/chatRepository.dart';
import '../utils/notificationUtils/generalNotificationUtility.dart';

//to avoide handshake error on some devices
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  //Register the licence of font
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp();
  await NotificationUtility.initializeAwesomeNotification();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox(authBoxKey);
  await Hive.openBox(settingsBoxKey);
  runApp(const MyApp());
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //preloading some of the imaegs
    precacheImage(
      AssetImage(UiUtils.getImagePath("upper_pattern.png")),
      context,
    );

    precacheImage(
      AssetImage(UiUtils.getImagePath("lower_pattern.png")),
      context,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppConfigurationCubit>(
          create: (_) => AppConfigurationCubit(SystemRepository()),
        ),
        BlocProvider<AppLocalizationCubit>(
          create: (_) => AppLocalizationCubit(SettingsRepository()),
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<MyClassesCubit>(
          create: (_) => MyClassesCubit(TeacherRepository()),
        ),
        BlocProvider<InternetConnectivityCubit>(
          create: (_) => InternetConnectivityCubit(),
        ),
        BlocProvider<StudentChatUsersCubit>(
          create: (_) => StudentChatUsersCubit(ChatRepository()),
        ),
        BlocProvider<ParentChatUserCubit>(
          create: (_) => ParentChatUserCubit(ChatRepository()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final currentLanguage =
              context.watch<AppLocalizationCubit>().state.language;
          return MaterialApp(
            navigatorKey: UiUtils.rootNavigatorKey,
            theme: Theme.of(context).copyWith(
              textTheme:
                  GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              scaffoldBackgroundColor: pageBackgroundColor,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                    onPrimary: onPrimaryColor,
                    secondary: secondaryColor,
                    background: backgroundColor,
                    error: errorColor,
                    onSecondary: onSecondaryColor,
                    onBackground: onBackgroundColor,
                  ),
            ),
            builder: (context, widget) {
              return ScrollConfiguration(
                behavior: GlobalScrollBehavior(),
                child: widget!,
              );
            },
            locale: currentLanguage,
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((language) {
              return UiUtils.getLocaleFromLanguageCode(language.languageCode);
            }).toList(),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}
