import 'package:intl/intl.dart';

import '../../domain/model/intraday_info.dart';
import '../source/remote/dto/intraday_info_dto.dart';

extension ToIntradayInfo on IntradayInfoDto {
  IntradayInfo toIntradayInfo() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return IntradayInfo(
      date: formatter.parse(timestamp),
      close: close,
    );
  }
}