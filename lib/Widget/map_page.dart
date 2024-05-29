import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};// Set để lưu trữ các đường đi (polyline)

  static const LatLng _postHouse = LatLng(10.7069207, 106.6768502);
  static const LatLng _testCurrent= LatLng(10.732639899999999,106.69976390000001);
  static const LatLng _postHouse2 = LatLng(21.030701, 105.8010413);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.732639899999999,106.69976390000001 ),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId("_postHouse"),
        icon: BitmapDescriptor.defaultMarker,
        position: _postHouse,
        onTap: () {
          _showInfoWindow("500,000 VND", "100 m2", "https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2Fuser.jpg?alt=media&token=0238633c-16cc-431e-9a18-987b26e95697");
        },
      ),

    );
    _markers.add(
      Marker(
        markerId: const MarkerId("_testCurrent"),
        icon: BitmapDescriptor.defaultMarker,
        position: _testCurrent,
        onTap: () {
          _showInfoWindow("500,000 VND", "100 m2", "https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2Fuser.jpg?alt=media&token=0238633c-16cc-431e-9a18-987b26e95697");
        },
      ),

    );
    _markers.add(
        Marker(
          markerId: const MarkerId("_testCurrent"),
          icon: BitmapDescriptor.defaultMarker,
          position: _postHouse2,
          onTap: () {
            _showInfoWindow("500,000 VND", "100 m2", "https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/images%2Fuser.jpg?alt=media&token=0238633c-16cc-431e-9a18-987b26e95697");
          },
        ),
        );
  }

  // Hiển thị info window

// Lay vi tri hien taij
  Future<void> _addCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: currentLatLng,
        ),
      );
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
  }
// Hiển thị info window
  void _showInfoWindow( String price, String area, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: 320,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(imageUrl),
                  SizedBox(height: 10),
                  Text("Giá: $price"),
                  Text("Diện tích: $area"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
        children: [
          GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
      Positioned(
        bottom: 16,
        left: 16,
        child: FloatingActionButton(
          onPressed: _addCurrentLocation,
          child: const Icon(Icons.location_searching),
          tooltip: 'Get Current Location',
        ),
      ),
      ]

    ),
    );

  }
}
