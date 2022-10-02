import '../../data/mapper/company_mapper.dart';
import '../../domain/model/company_listing.dart';
import '../../domain/repository/stock_repository.dart';
import '../../util/result.dart';
import '../csv/company_listings_parser.dart';
import '../source/local/stock_dao.dart';
import '../source/remote/stock_api.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApi _api;
  final StockDao _dao;
  final _parser = CompanyListingsParser();

  StockRepositoryImpl(this._api, this._dao);

  @override
  Future<Result<List<CompanyListing>>> getCompanyListings(
      bool fetchFromRemote, String query) async {
    final localListings = await _dao.searchCompanyListing(query);
    final isDbEmpty = localListings.isEmpty && query.isEmpty;
    final shouldJustLoadFromCache = !isDbEmpty && !fetchFromRemote;

    if (shouldJustLoadFromCache) {
      return Result.success(
          localListings.map((e) => e.toCompanyListing()).toList());
    }

    try {
      final response = await _api.getListings();
      final remoteListings = await _parser.parse(response.body);

      await _dao.clearCompanyListings();

      await _dao.insertCompanyListings(
          remoteListings.map((e) => e.toCompanyListingEntity()).toList()
      );

      return Result.success(remoteListings);
    } catch (e) {
      return Result.error(Exception('데이터 로드 실패!!'));
    }
  }
}