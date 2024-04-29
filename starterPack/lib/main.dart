import 'package:digit_components/digit_components.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inventory_management/blocs/facility.dart';
import 'package:inventory_management/blocs/inventory_listener.dart';
import 'package:inventory_management/blocs/product_variant.dart';
import 'package:isar/isar.dart';
import 'package:location/location.dart';
import 'package:referral_reconciliation/blocs/referral_recon_service.dart';
import 'package:referral_reconciliation/blocs/search_referral_reconciliations.dart';
import 'package:starterPack/blocs/app_init.dart';
import 'package:starterPack/blocs/app_localization.dart';
import 'package:starterPack/blocs/facilitiesComposite.dart';
import 'package:starterPack/blocs/localization.dart';
import 'package:starterPack/blocs/product_variants_composite.dart';
import 'package:starterPack/blocs/project.dart';
import 'package:starterPack/data/app_shared_preferences.dart';
import 'package:starterPack/data/nosql/localization.dart';
import 'package:starterPack/data/remote_client.dart';
import 'package:starterPack/model/data_model.init.dart';
import 'package:starterPack/routes/routes.dart';
import 'package:starterPack/utils/constants.dart';
import 'package:starterPack/utils/context_utility.dart';
import 'package:starterPack/utils/envConfig.dart';
import 'package:attendance_management/blocs/app_localization.dart'
    as attendance_localization;
import 'package:inventory_management/blocs/app_localization.dart'
    as inventory_localization;
import 'package:digit_scanner/blocs/app_localization.dart'
    as scanner_localization;
import 'package:referral_reconciliation/blocs/app_localization.dart'
    as referral_localization;
import 'blocs/authbloc.dart';

late Isar _isar; //new addition
late Dio _dio;

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  initializeMappers();

  // Initialize environment configurations, ISAR, dio
  await envConfig.initialize();
  _dio = DioClient().dio;
  _isar = await Constants().isar;

  // Initialize shared preferences
  await AppSharedPreferences().init();

  // Check if it's the first launch of the app
  if (AppSharedPreferences().isFirstLaunch) {
    // Log first launch
    AppLogger.instance.info('App Launched First Time', title: 'main');

    // Mark app as launched for the first time
    await AppSharedPreferences().appLaunchedFirstTime();
  }

  // Run the main app widget
  runApp(MainApp(
    isar: _isar,
  ));
}

class MainApp extends StatefulWidget {
  final Isar isar;
  const MainApp({super.key, required this.isar});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _approuter = AppRouter();
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  AppInitialization()..add(const InitEvent.onLaunch()),
            ),
            BlocProvider(
              create: (context) {
                //try to load credentials locally first to skip login page
                return AuthBloc()..add(const AuthEvent.attemptLoad());
              },
            ),
            BlocProvider<ProjectBloc>(
              create: (context) {
                return ProjectBloc();
              },
            ),
            BlocProvider(
              create: (_) {
                return DigitScannerBloc(
                  const DigitScannerState(),
                );
              },
              lazy: false,
            ),
            BlocProvider(
              create: (_) {
                return FacilityBloc(
                  const FacilityEmptyState(),
                  inventorySingleton: InventorySingleton(),
                );
              },
              lazy: false,
            ),
            BlocProvider(
              create: (_) {
                return ProductVariantBloc(
                  const ProductVariantEmptyState(),
                  inventorySingleton: InventorySingleton(),
                );
              },
              lazy: false,
            ),
            BlocProvider(
              create: (_) {
                return FacilityCompositeBloc();
              },
            ),
            BlocProvider(create: (_) {
              return ProductVariantCompositeBloc(
                  const ProductVariantCompositeEmptyState());
            }),
            BlocProvider(create: (_) {
              return LocationBloc(location: Location());
            }),
            BlocProvider(
              create: (_) {
                return SearchReferralsBloc();
              },
            ),
            BlocProvider(create: (_) {
              return ReferralReconServiceBloc(
                  const ReferralReconServiceEmptyState());
            })
          ],
          child: BlocBuilder<AppInitialization, InitState>(
            builder: (context, state) => state.maybeWhen(
                orElse: () => const Center(child: Text('error Initializing')),
                initialized: (appConfig, serviceRegistryModel) {
                  final initialModuleList =
                      appConfig.appConfig!.appConfig?[0].backendInterface;
                  final languages =
                      appConfig.appConfig!.appConfig?[0].languages;
                  var firstLanguage;
                  firstLanguage = languages?.last.value;

                  // Get the selected locale from shared preferences, or fallback to the default firstLanguage
                  return BlocProvider(
                      create: (context) => LocalizationBloc(widget.isar)
                        ..add(LocalizationEvent.onSelect(
                            locale: firstLanguage,
                            moduleList: initialModuleList)),
                      child: BlocBuilder<LocalizationBloc, LocalizationState>(
                          builder: (context, state) {
                        final selectedLocale =
                            AppSharedPreferences().getSelectedLocale ??
                                firstLanguage;
                        return MaterialApp.router(
                          scaffoldMessengerKey: scaffoldMessengerKey,
                          theme: DigitTheme.instance.mobileTheme,
                          routerDelegate: _approuter.delegate(),
                          routeInformationParser:
                              _approuter.defaultRouteParser(),
                          // Define supported locales based on available languages
                          supportedLocales: languages != null
                              ? languages.map((e) {
                                  final results = e.value.split('_');

                                  return results.isNotEmpty
                                      ? Locale(results.first, results.last)
                                      : firstLanguage;
                                })
                              : [firstLanguage],
                          // Define localizations delegates
                          localizationsDelegates: [
                            AppLocalizations.getDelegate(
                                appConfig.appConfig!, widget.isar),
                            GlobalWidgetsLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate,
                            GlobalMaterialLocalizations.delegate,
                            attendance_localization.AttendanceLocalization
                                .getDelegate(
                              // Fetch the localization string based on selected locale
                              getLocalizationString(
                                  widget.isar, selectedLocale),
                              // Pass available languages
                              languages!,
                            ),
                            inventory_localization.InventoryLocalization
                                .getDelegate(
                                    getLocalizationString(
                                        widget.isar, selectedLocale),
                                    languages),
                            scanner_localization.ScannerLocalization
                                .getDelegate(
                                    getLocalizationString(
                                        widget.isar, selectedLocale),
                                    languages),
                            referral_localization.ReferralReconLocalization
                                .getDelegate(
                                    getLocalizationString(
                                        widget.isar, selectedLocale),
                                    languages),
                          ],
                          // Set the locale for the app
                          locale: languages != null
                              ? Locale(
                                  selectedLocale!.split("_").first,
                                  selectedLocale.split("_").last,
                                )
                              : firstLanguage,
                        );
                      }));
                }),
          )),
    );
  }
}

// Function to fetch localization values for the selected locale from Isar database
Future<List<dynamic>> getLocalizationString(
    Isar isar, String selectedLocale) async {
  // Initialize an empty list to store localization values
  List<dynamic> localizationValues = [];

  // Query Isar database to fetch localization wrappers for the selected locale
  final List<LocalizationWrapper> localizationList =
      await isar.localizationWrappers
          .filter()
          .localeEqualTo(
            selectedLocale.toString(),
          )
          .findAll();

  // Check if localization wrappers are found for the selected locale
  if (localizationList.isNotEmpty) {
    // Add localization values to the list if found
    localizationValues.addAll(localizationList.first.localization!);
  }

  // Return the fetched localization values
  return localizationValues;
}
