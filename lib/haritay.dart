import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Haritay extends StatefulWidget {
  @override
  _HaritayState createState() => _HaritayState();
}

class _HaritayState extends State<Haritay> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng _initialposition = LatLng(32, 40);
  GoogleMapController _controller;
  Future<LocationData> _locationData = Location().getLocation();
  Location _location = Location();
  Geoflutterfire geo = Geoflutterfire();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.green[600],
          title: Text(
            "Eventy",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_auth.currentUser.displayName),
                accountEmail: Text(_auth.currentUser.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.blue
                          : Colors.white,
                  child: Text(
                    _auth.currentUser.displayName.characters.first,
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.group),
                title: Text(
                  'Arkadaşlar',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/arkadaslar');
                  },
                ),
              ),
              FutureBuilder(
                future: _firestore
                    .collection('users')
                    .doc(_auth.currentUser.email)
                    .get(),
                builder: (BuildContext content, snapyshot) {
                  try {
                    return Expanded(
                      child: snapyshot.data['arkadaslar'].toString() == "[]"
                          ? Text(
                              "Henüz Bir Arkadaşınız Yok.",
                              style: TextStyle(fontSize: 20),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: snapyshot.data['arkadaslar'].length,
                              itemBuilder: (BuildContext context, int index) {
                                return FutureBuilder(
                                  future: _firestore
                                      .collection('users')
                                      .doc(snapyshot.data['arkadaslar'][index])
                                      .get(),
                                  builder: (BuildContext context, snap) {
                                    try {
                                      return Column(
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              final MarkerId markerId =
                                                  MarkerId(snap.data['ad']);

                                              final Marker marker = Marker(
                                                markerId: markerId,
                                                flat: false,
                                                position: LatLng(
                                                    snap.data['konum'].latitude,
                                                    snap.data['konum']
                                                        .longitude),
                                                infoWindow: InfoWindow(
                                                    title: snap.data['ad'],
                                                    snippet:
                                                        snap.data['email']),
                                              );

                                              setState(() {
                                                markers[markerId] = marker;
                                              });
                                            },
                                            title: Text(
                                              snap.data['ad'],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            trailing: InkWell(
                                              child: Icon(
                                                Icons.person_remove,
                                                size: 25,
                                              ),
                                              onTap: () {
                                                _firestore
                                                    .collection('users')
                                                    .doc(
                                                        _auth.currentUser.email)
                                                    .update({
                                                  'arkadaslar':
                                                      FieldValue.arrayRemove(
                                                          [snap.data['email']])
                                                });
                                                _firestore
                                                    .collection('users')
                                                    .doc(snap.data['email'])
                                                    .update({
                                                  'arkadaslar':
                                                      FieldValue.arrayRemove([
                                                    _auth.currentUser.email
                                                  ])
                                                });
                                                setState(() {});
                                              },
                                            ),
                                            subtitle: Text(
                                              snap.data['email'],
                                            ),
                                            tileColor: Colors.black12,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      );
                                    } catch (e) {
                                      return Container();
                                    }
                                  },
                                );
                              },
                            ),
                    );
                  } catch (e) {
                    debugPrint(e.toString());
                    return Text("Veri Getirmede Hata");
                  }
                },
              ),
              Icon(
                Icons.six_ft_apart_rounded,
                size: 50,
              ),
              Text(
                "Lütfen Sosyal Mesafeyi Koruyalım.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              markers: Set<Marker>.of(markers.values),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _initialposition,
                zoom: 0,
              ),
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.my_location),
          backgroundColor: Colors.blue,
          onPressed: _currentLocation,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController _cntrl) async {
    LatLng heh = LatLng(41, 28);
    _controller = _cntrl;

    await _location.getLocation().then((value) => {
          setState(() {
            heh = LatLng(value.latitude, value.longitude);
          })
        });

    _location.onLocationChanged.listen((l) {
      _firestore
          .collection("users")
          .doc(_auth.currentUser.email)
          .update({"konum": GeoPoint(l.latitude, l.longitude)});
      GeoFirePoint point =
          geo.point(latitude: l.latitude, longitude: l.longitude);
      _firestore.collection('users').doc(_auth.currentUser.email).update({
        'position': [point.data]
      });
      setState(() {});
    });

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: heh, zoom: 15),
      ),
    );
  }

  void _currentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } on Exception {
      currentLocation = null;
    }

    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.0,
      ),
    ));
  }
}
