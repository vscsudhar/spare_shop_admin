import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class SearchLocationResult {
  final String name;
  final double latitude;
  final double longitude;
  final String? placeName;

  const SearchLocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.placeName,
  });
}

/// Interactive OpenStreetMap Location Picker with dynamic pin,
/// Nominatim area search, coverage radius circle, and auto-synced coordinates.
class AdminLocationMapPicker extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double radiusKm;
  final void Function(double lat, double lng, {String? placeName})
      onLocationChanged;
  final double height;

  const AdminLocationMapPicker({
    Key? key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.radiusKm,
    required this.onLocationChanged,
    this.height = 420,
  }) : super(key: key);

  @override
  State<AdminLocationMapPicker> createState() => _AdminLocationMapPickerState();
}

class _AdminLocationMapPickerState extends State<AdminLocationMapPicker>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late double _currentLat;
  late double _currentLng;

  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  Timer? _searchDebounce;
  CancelToken? _searchCancelToken;
  List<SearchLocationResult> _searchResults = [];
  bool _isSearching = false;

  late AnimationController _pinAnimationController;
  late Animation<double> _pinTranslationY;
  late Animation<double> _shadowScale;

  Timer? _posChangeDebounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLat = widget.initialLatitude;
    _currentLng = widget.initialLongitude;

    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _pinTranslationY = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _shadowScale = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _pinAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AdminLocationMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.initialLatitude != widget.initialLatitude ||
            oldWidget.initialLongitude != widget.initialLongitude) &&
        (widget.initialLatitude != _currentLat ||
            widget.initialLongitude != _currentLng)) {
      _currentLat = widget.initialLatitude;
      _currentLng = widget.initialLongitude;
      _mapController.move(
          LatLng(_currentLat, _currentLng), _mapController.camera.zoom);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _posChangeDebounce?.cancel();
    _searchCancelToken?.cancel();
    _searchController.dispose();
    _pinAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _currentLat = point.latitude;
      _currentLng = point.longitude;
      _searchResults = [];
    });

    _mapController.move(point, _mapController.camera.zoom);
    widget.onLocationChanged(_currentLat, _currentLng);
    _bouncePin();
  }

  void _onCameraPositionChanged(LatLng center) {
    if (!_pinAnimationController.isAnimating &&
        _pinAnimationController.value == 0) {
      _pinAnimationController.forward();
    }

    _posChangeDebounce?.cancel();
    _posChangeDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _currentLat = center.latitude;
        _currentLng = center.longitude;
      });
      _pinAnimationController.reverse();
      widget.onLocationChanged(_currentLat, _currentLng);
    });
  }

  void _bouncePin() {
    _pinAnimationController.forward().then((_) {
      if (mounted) {
        _pinAnimationController.reverse();
      }
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      setState(() {
        _isSearching = true;
      });

      _searchCancelToken?.cancel();
      _searchCancelToken = CancelToken();

      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': query.trim(),
            'format': 'json',
            'addressdetails': '1',
            'limit': '5',
            'countrycodes': 'in',
          },
          options: Options(
            headers: {'User-Agent': 'VoltSpare_Admin/1.0'},
            receiveTimeout: const Duration(seconds: 6),
            sendTimeout: const Duration(seconds: 6),
          ),
          cancelToken: _searchCancelToken,
        );

        if (response.statusCode == 200 && response.data is List && mounted) {
          final list = response.data as List;
          setState(() {
            _searchResults = list.map((item) {
              final addr = (item['address'] as Map?) ?? {};
              final placeName = (addr['suburb'] ??
                      addr['neighbourhood'] ??
                      addr['village'] ??
                      addr['town'] ??
                      addr['city'] ??
                      addr['district'] ??
                      '')
                  .toString();

              return SearchLocationResult(
                name: (item['display_name'] ?? '').toString(),
                latitude: double.tryParse(item['lat']?.toString() ?? '') ??
                    _currentLat,
                longitude: double.tryParse(item['lon']?.toString() ?? '') ??
                    _currentLng,
                placeName: placeName.isNotEmpty ? placeName : null,
              );
            }).toList();
          });
        }
      } catch (_) {
      } finally {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
      }
    });
  }

  void _selectSearchResult(SearchLocationResult loc) {
    setState(() {
      _currentLat = loc.latitude;
      _currentLng = loc.longitude;
      _searchResults = [];
      _searchController.text = loc.name;
      FocusScope.of(context).unfocus();
    });

    _mapController.move(LatLng(loc.latitude, loc.longitude), 15.5);
    widget.onLocationChanged(loc.latitude, loc.longitude,
        placeName: loc.placeName);
    _bouncePin();
  }

  void _recenterMap() {
    setState(() {
      _currentLat = widget.initialLatitude;
      _currentLng = widget.initialLongitude;
      _searchController.clear();
      _searchResults = [];
    });
    _mapController.move(
        LatLng(widget.initialLatitude, widget.initialLongitude), 15.0);
    widget.onLocationChanged(_currentLat, _currentLng);
    _bouncePin();
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18.5) {
      _mapController.move(_mapController.camera.center, currentZoom + 1.0);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 4.5) {
      _mapController.move(_mapController.camera.center, currentZoom - 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValidRadius = widget.radiusKm > 0;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AdminColors.isDarkTheme
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // OpenStreetMap Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  LatLng(widget.initialLatitude, widget.initialLongitude),
              initialZoom: 14.5,
              minZoom: 4.0,
              maxZoom: 19.0,
              onTap: (tapPosition, point) => _onMapTapped(point),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  _onCameraPositionChanged(camera.center);
                }
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.voltspare.spare_shop_admin',
                maxZoom: 19,
              ),

              // Coverage Radius Circle Overlay
              if (hasValidRadius)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(_currentLat, _currentLng),
                      radius: widget.radiusKm * 1000,
                      useRadiusInMeter: true,
                      color: AdminColors.primaryGreen.withValues(alpha: 0.14),
                      borderColor: AdminColors.primaryGreen,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),

          // Center Animated Pin Teardrop with shadow
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _pinAnimationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ground Pin Shadow
                    Transform.translate(
                      offset: const Offset(0, 16),
                      child: Transform.scale(
                        scale: _shadowScale.value,
                        child: Container(
                          width: 16,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Animated Center Pin Icon
                    Transform.translate(
                      offset: Offset(0, -18 + _pinTranslationY.value),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 46,
                            color: AdminColors.primaryGreen,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0, -4),
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Search Bar in Top Corner
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText:
                          'Search city, town, street or landmark on OpenStreetMap...',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      prefixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : const Icon(Icons.search_rounded,
                              color: Colors.grey, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Search Suggestions Dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined,
                              size: 18, color: Colors.green),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Zoom & Recenter Controls in Bottom-Right
          Positioned(
            bottom: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'osm_location_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 4,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add_rounded, size: 20),
                ),
                const SizedBox(height: 6),
                FloatingActionButton.small(
                  heroTag: 'osm_location_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 4,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove_rounded, size: 20),
                ),
                const SizedBox(height: 6),
                FloatingActionButton.small(
                  heroTag: 'osm_location_recenter',
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _recenterMap,
                  tooltip: 'Recenter to initial location',
                  child: const Icon(Icons.my_location_rounded, size: 18),
                ),
              ],
            ),
          ),

          // Interactive Helper Hint Banner in Bottom-Left
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Tap map or drag to position location pin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
