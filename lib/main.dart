import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'data/repository/stock_repository_impl.dart';
import 'data/source/local/company_listing_entity.dart';
import 'data/source/local/stock_dao.dart';
import 'data/source/remote/stock_api.dart';
import 'domain/repository/stock_repository.dart';
import 'presentation/company_listings/company_listings_screen.dart';
import 'presentation/company_listings/company_listings_view_model.dart';
import 'util/color_schemes.g.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CompanyListingEntityAdapter());

  final repository = StockRepositoryImpl(
    StockApi(),
    StockDao(),
  );

  GetIt.instance.registerSingleton<StockRepository>(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CompanyListingsViewModel(
            repository,
          ),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      home: const CompanyListingsScreen(),
    );
  }
}
