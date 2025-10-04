import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import 'package:intl/intl.dart';

class RideDashboardPage extends StatefulWidget {
  const RideDashboardPage({super.key});

  @override
  State<RideDashboardPage> createState() => _RideDashboardPageState();
}

class _RideDashboardPageState extends State<RideDashboardPage> {
  final leavingController = TextEditingController();
  final goingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int passengers = 1;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header color

            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _pickPassengers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // modal overlay transparent
      isScrollControlled: true,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900], // background color of the modal
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Passengers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 36,
                    onPressed: () {
                      if (passengers > 1) setState(() => passengers--);
                    },
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      "$passengers",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 36,
                    onPressed: () {
                      setState(() => passengers++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your pick of rides at low prices",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body:
         Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Leaving from
              Row(
                children: [
                  const Icon(Icons.radio_button_unchecked),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: leavingController,
                      decoration: const InputDecoration(
                        hintText: "Leaving from",
                        hintStyle: TextStyle(),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.toNamed(TRoutes.map, arguments: {"lat": 0.0, "lng": 0.0});
                    },
                    icon: const Icon(Icons.map,),
                  ),
                ],
              ),
              Divider(),

              // Going to
              Row(
                children: [
                  const Icon(Icons.radio_button_unchecked,),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: goingController,
                      decoration: const InputDecoration(
                        hintText: "Going to",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.toNamed(TRoutes.map, arguments: {"lat": 0.0, "lng": 0.0});
                    },
                    icon: const Icon(Icons.map,),
                  ),
                ],
              ),
              Divider(),

              // Date row
              Row(
                children: [
                  const Icon(Icons.calendar_today,),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle( fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.keyboard_arrow_down, ),
                  ),
                ],
              ),
              Divider(),

// Passengers row
              Row(
                children: [
                  const Icon(Icons.person,),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickPassengers,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "$passengers",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _pickPassengers,
                    icon: const Icon(Icons.keyboard_arrow_down,),
                  ),
                ],
              ),
              Divider(),


              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                  Get.toNamed(TRoutes.riders);
                     },
                  child: const Text(
                    "Search",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Publish"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Your rides"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
