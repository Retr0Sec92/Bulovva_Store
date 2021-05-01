import 'package:bulovva_store/Providers/store_provider.dart';
import 'package:bulovva_store/Services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  List<Marker> picker = [];
  StoreProvider _storeProvider;
  LatLng position;

  pick(LatLng point) {
    setState(() {
      picker = [];
      picker.add(Marker(markerId: MarkerId(point.toString()), position: point));
      position = point;
    });
  }

  savePick() {
    if (position != null) {
      _storeProvider.changeStoreLocLat(position.latitude);
      _storeProvider.changeStoreLocLong(position.longitude);
      ToastService()
          .showSuccess('Konumunuz başarıyla kaydedilmiştir !', context);
    } else {
      _storeProvider.changeStoreLocLat(_storeProvider.curLocLat);
      _storeProvider.changeStoreLocLong(_storeProvider.curLocLong);
      ToastService()
          .showSuccess('Konumunuz başarıyla kaydedilmiştir !', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _storeProvider = Provider.of<StoreProvider>(context, listen: false);
    if (_storeProvider.storeLocLat != null &&
        _storeProvider.storeLocLong != null) {
      picker.add(Marker(
          markerId: MarkerId('1'),
          position:
              LatLng(_storeProvider.storeLocLat, _storeProvider.storeLocLong)));
    }
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('Konum Seçimi',
              style: TextStyle(
                  fontSize: 25.0, fontFamily: 'Bebas', color: Colors.white))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text(
          'Konumu Kaydet',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        onPressed: () {
          savePick();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _storeProvider.curLocLat, _storeProvider.curLocLong),
                  zoom: 17.0),
              markers: Set.from(picker),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onTap: pick,
            ),
          )
        ],
      ),
    );
  }
}
