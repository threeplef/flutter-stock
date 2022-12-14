import '../../data/mapper/company_mapper.dart';
import '../../domain/model/company_info.dart';
import '../../domain/model/company_listing.dart';
import '../../domain/model/intraday_info.dart';
import '../../domain/repository/stock_repository.dart';
import '../../util/result.dart';
import '../csv/company_listings_parser.dart';
import '../csv/intraday_info_parser.dart';
import '../source/local/stock_dao.dart';
import '../source/remote/stock_api.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApi _api;
  final StockDao _dao;
  final _companyListingsParser = CompanyListingsParser();
  final _intradayInfoParser = IntradayInfoParser();

  StockRepositoryImpl(this._api, this._dao);

  @override
  Future<Result<List<CompanyListing>>> getCompanyListings(
      bool fetchFromRemote, String query) async {
    final localListings = await _dao.searchCompanyListing(query);

    final isDbEmpty = localListings.isEmpty && query.isEmpty;
    final shouldJustLoadFromCache = !isDbEmpty && !fetchFromRemote;

    if (shouldJustLoadFromCache) {
      return Result.success(localListings
          .where((element) =>
              element.symbol != null &&
              element.name != null &&
              element.exchange != null)
          .map((e) => e.toCompanyListing())
          .toList());
    }

    try {
      final response = await _api.getListings();
      final remoteListings = await _companyListingsParser.parse(response.body);

      await _dao.clearCompanyListings();

      await _dao.insertCompanyListings(
          remoteListings.map((e) => e.toCompanyListingEntity()).toList());

      return Result.success(remoteListings);
    } catch (e) {
      return Result.error(Exception('데이터 로드 실패!!'));
    }
  }

  @override
  Future<Result<CompanyInfo>> getCompanyInfo(String symbol) async {
    try {
      final dto = await _api.getCompanyInfo(symbol: symbol);
      return Result.success(dto.toCompanyInfo());
    } catch (e) {
      return Result.error(Exception('회사 정보 로드 실패!! : ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<IntradayInfo>>> getIntradayInfo(String symbol) async {
    try {
      final response = await _api.getIntradayInfo(symbol: symbol);
      final results = await _intradayInfoParser.parse(response.body);
      return Result.success(results);
    } catch (e) {
      return Result.error(Exception('intraday 정보 로드 실패 !! : ${e.toString()}'));
    }
  }
}