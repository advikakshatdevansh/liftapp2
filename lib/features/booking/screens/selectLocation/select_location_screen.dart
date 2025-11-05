import 'package:flutter/material.dart';
import '../../../../../common/widgets/drawer/drawer.dart';
import 'widgets/location_form_widget.dart';
import 'widgets/appbar.dart';

class SelectLocation extends StatelessWidget {
  const SelectLocation({super.key});

  @override
  Widget build(BuildContext context) {
    //Variables
    final txtTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Scaffold(
        appBar: DashboardAppBar(),

        /// Create a new Header
        drawer: TDrawer(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const LocationFormWidget()],
          ),
        ),
      ),
    );
  }
}
