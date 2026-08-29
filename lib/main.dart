import 'package:flutter/material.dart';
import 'package:spare_shop_admin/app/app.bottomsheets.dart';
import 'package:spare_shop_admin/app/app.dialogs.dart';
import 'package:spare_shop_admin/app/app.locator.dart';
import 'package:spare_shop_admin/app/app.router.dart';
import 'package:spare_shop_admin/core/theme/app_theme.dart';
import 'package:spare_shop_admin/core/theme/theme_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainAppViewModel>.reactive(
      viewModelBuilder: () => MainAppViewModel(),
      builder: (context, viewModel, child) {
        return MaterialApp(
          title: 'VoltSpare Admin Console',
          initialRoute: Routes.startupView,
          onGenerateRoute: StackedRouter().onGenerateRoute,
          navigatorKey: StackedService.navigatorKey,
          navigatorObservers: [StackedService.routeObserver],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: viewModel.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainAppViewModel extends ReactiveViewModel {
  final _themeService = locator<ThemeService>();

  ThemeMode get themeMode => _themeService.themeMode;

  @override
  List<ListenableServiceMixin> get listenableServices => [_themeService];
}
