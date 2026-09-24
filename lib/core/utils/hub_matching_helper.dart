import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class HubMatchingHelper {
  /// Matches an order to a location in [locations] by analyzing locationId, locationName, and address line
  static LocationModel? findBestMatchingLocation(
    OrderModel order,
    List<LocationModel> locations,
  ) {
    if (locations.isEmpty) return null;

    // 1. Direct locationId match
    if (order.locationId != null && order.locationId!.isNotEmpty) {
      final match = locations.where((l) => l.id == order.locationId);
      if (match.isNotEmpty) return match.first;
    }

    // 2. Direct locationName match
    if (order.locationName != null && order.locationName!.isNotEmpty) {
      final query = order.locationName!.trim().toLowerCase();
      final match = locations.where((l) =>
          l.name.toLowerCase() == query ||
          l.name.toLowerCase().contains(query) ||
          query.contains(l.name.toLowerCase()));
      if (match.isNotEmpty) return match.first;
    }

    // 3. Address text keywords match (e.g. "Madukkarai", "Gandhipuram", "Peelamedu", etc.)
    final addressText = '${order.address.addressLine} ${order.address.name}'.toLowerCase();

    for (final loc in locations) {
      final locName = loc.name.toLowerCase();

      if (locName.isNotEmpty && addressText.contains(locName)) {
        return loc;
      }
    }

    // 4. Token match for multi-word location names
    for (final loc in locations) {
      final tokens = loc.name.toLowerCase().split(' ');
      for (final t in tokens) {
        if (t.length > 3 && addressText.contains(t)) {
          return loc;
        }
      }
    }

    // 5. If only 1 location exists, match to it as default hub
    if (locations.length == 1) {
      return locations.first;
    }

    return null;
  }

  /// Automatically resolves and fills missing location details for an order
  static OrderModel resolveOrderLocation(
    OrderModel order,
    List<LocationModel> locations,
  ) {
    // If order already has both valid locationId and locationName matching known locations
    if (order.locationId != null &&
        order.locationId!.isNotEmpty &&
        order.locationName != null &&
        order.locationName!.isNotEmpty) {
      return order;
    }

    final matched = findBestMatchingLocation(order, locations);
    if (matched != null) {
      return order.copyWith(
        locationId: matched.id,
        locationName: matched.name,
      );
    }
    return order;
  }
}
