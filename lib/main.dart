import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'models/location.dart';
import 'models/search.dart';
import 'widgets/location_map.dart';
import 'widgets/location_search_delegate.dart';
import 'widgets/searchbar.dart';
import 'widgets/search_results_drawer.dart';

const apiKey = '<YOUR API KEY HERE>'; // https://developer.tomtom.com

void main() {
  runApp(
    const App(),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final BottomDrawerController _bottomDrawerController =
      BottomDrawerController();
  LatLng _mapCenter = const LatLng(0.0, 0.0);
  Location? _selected;
  Search? _search;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Autocomplete',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
      ),
      home: Stack(
        children: <Widget>[
          LocationMap(
            apiKey: apiKey,
            locations: _search?.results,
            selected: _selected,
            onMapCenterChange: _onMapCenterChange,
          ),
          Positioned(
            top: 0,
            right: 8,
            left: 8,
            child: SafeArea(
              child: SearchBar(
                query: _search?.query,
                onTap: (context) async {
                  await showSearch(
                    context: context,
                    delegate: LoctationSearchDelegate(
                      apiKey: apiKey,
                      mapCenter: _mapCenter,
                      onSearchResults: _onSearchResults,
                      onClear: _onClear,
                    ),
                  );
                },
              ),
            ),
          ),
          if (_search != null)
            SearchResultsDrawer(
              controller: _bottomDrawerController,
              search: _search!,
              selectedId: _selected?.id,
              onItemTap: _onLocationSelected,
              onClear: _onClear,
            ),
        ],
      ),
    );
  }

  void _onMapCenterChange(LatLng mapCenter) {
    setState(() {
      _mapCenter = mapCenter;
    });
  }

  void _onSearchResults(Search search) {
    setState(() {
      _search = search;
    });

    // Delay opening the drawer until it's been rendered.
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _bottomDrawerController.open(),
    );
  }

  void _onLocationSelected(Location location) {
    setState(() {
      _selected = location;
    });
  }

  void _onClear() {
    setState(() {
      _selected = null;
      _search = null;
    });
  }
}
