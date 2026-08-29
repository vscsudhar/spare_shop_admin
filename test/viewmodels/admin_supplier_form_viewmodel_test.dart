import 'package:flutter_test/flutter_test.dart';
import 'package:spare_shop_admin/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AdminSupplierFormViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
