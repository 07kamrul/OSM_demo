import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_location/user_location_bloc.dart';
import '../data/models/user_location.dart';


class UserLocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Locations')),
      body: BlocBuilder<UserLocationBloc, UserLocationState>(
        builder: (context, state) {
          if (state is UserLocationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserLocationLoaded) {
            return ListView.builder(
              itemCount: state.locations.length,
              itemBuilder: (context, index) {
                final location = state.locations[index];
                return ListTile(
                  title: Text('Latitude: ${location.latitude}, Longitude: ${location.longitude}'),
                  subtitle: Text('Sharing: ${location.issharinglocation}'),
                );
              },
            );
          } else if (state is UserLocationError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newLocation = UserLocation(
            userid: 1,
            latitude: 40.7128,
            longitude: -74.0060,
            issharinglocation: true,
          );
          context.read<UserLocationBloc>().add(AddUserLocationEvent(newLocation));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}