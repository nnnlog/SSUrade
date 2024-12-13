import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:ssurade/firebase_options_env.dart';
import 'package:ssurade/views/absent_page.dart';
import 'package:ssurade/views/chapel_page.dart';
import 'package:ssurade/views/grade_page.dart';
import 'package:ssurade/views/grade_statistics_by_category_page.dart';
import 'package:ssurade/views/grade_statistics_page.dart';
import 'package:ssurade/views/information_page.dart';
import 'package:ssurade/views/login.dart';
import 'package:ssurade/views/main_page.dart';
import 'package:ssurade/views/scholarship_page.dart';
import 'package:ssurade/views/setting_page.dart';
import 'package:ssurade_adaptor/di/di.dart';
import 'package:ssurade_application/ssurade_application.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = String.fromEnvironment("SENTRY_DSN");
      options.tracesSampleRate = double.tryParse(String.fromEnvironment("SENTRY_TRACES_SAMPLE_RATE")) ?? 0.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureDependencies();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(const SsuradeEntryPoint());
    },
  );
}

class SsuradeEntryPoint extends StatelessWidget {
  const SsuradeEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => getIt<LoginViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<SubjectViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<ChapelViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<ScholarshipViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<AbsentViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<AppVersionViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<SettingViewModelUseCase>()),
        RepositoryProvider(create: (context) => getIt<MainViewModelUseCase>()),
      ],
      child: MaterialApp(
        title: 'SSUrade',
        theme: ThemeData(
          primaryColor: const MaterialColor(0xFF00A4CA, {
            50: Color.fromRGBO(0, 164, 202, .1),
            100: Color.fromRGBO(0, 164, 202, .2),
            200: Color.fromRGBO(0, 164, 202, .3),
            300: Color.fromRGBO(0, 164, 202, .4),
            400: Color.fromRGBO(0, 164, 202, .5),
            500: Color.fromRGBO(0, 164, 202, .6),
            600: Color.fromRGBO(0, 164, 202, .7),
            700: Color.fromRGBO(0, 164, 202, .8),
            800: Color.fromRGBO(0, 164, 202, .9),
            900: Color.fromRGBO(0, 164, 202, 1),
          }),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Pretendard",
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainPage(),
          '/login': (context) => const LoginPage(),
          '/grade': (context) => const GradePage(),
          '/grade_statistics': (context) => const GradeStatisticsPage(),
          '/grade_statistics_category': (context) => const GradeStatisticsByCategoryPage(),
          '/chapel': (context) => const ChapelPage(),
          '/scholarship': (context) => const ScholarshipPage(),
          '/absent': (context) => const AbsentPage(),
          '/setting': (context) => const SettingPage(),
          '/information': (context) => const InformationPage(),
        },
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          SentryNavigatorObserver(),
        ],
      ),
    );
  }
}
