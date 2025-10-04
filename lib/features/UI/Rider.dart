import 'package:flutter/material.dart';

// [RIDE CLASS and RIDECARD CLASS are omitted for brevity,
// assuming the previous version is used]

class Ride {
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final String driverName;
  final double rating;
  final bool isFull;

  Ride({
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.driverName,
    required this.rating,
    this.isFull = false,
  });
}

// --- New RideCard Widget (omitted for brevity, assume the previous implementation) ---
class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    // Helper function to get a visually distinct icon for the avatar
    Widget getDriverAvatar(Ride ride) {
      if (ride.driverName == "Tanmay") {
        return const CircleAvatar(
          radius: 16,
          // Placeholder for a specific image, like in the screenshot
          backgroundImage: AssetImage('assets/tanmay_profile.jpg'),
          backgroundColor: Colors.blueGrey,
        );
      } else if (ride.isFull) {
        // No avatar/placeholder for 'Full' ride
        return const SizedBox(width: 32, height: 32);
      } else {
        // Use the initial for others
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueGrey,
          child: Text(
            ride.driverName[0],
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }
    }

    // A placeholder for the duration to match the screenshot data
    String getDurationText(String from) {
      if (from == "Jonk") return "4h20";
      if (from == "Paonta Sahib") return "5h40";
      if (from == "Dehradun") return "4h20";
      if (from == "Haridwar") return "4h30";
      return "0h00";
    }

    // Text style for the light grey text in the timeline
    const TextStyle greyTextStyle = TextStyle(color: Colors.grey, fontSize: 13);
    // Text style for the main time and location
    const TextStyle whiteTextStyle = TextStyle(color: Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // -----------------
          // 1. Time, Location & Price Row
          // -----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Time and Timeline
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ride.departureTime,
                      style: whiteTextStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(getDurationText(ride.from), style: greyTextStyle),
                  const SizedBox(height: 2),
                  Text(ride.arrivalTime,
                      style: whiteTextStyle.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 12),
              // Center Column: Timeline Dots and Lines
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 8),
                  Container(
                    width: 1.5,
                    height: 48, // Adjust height to fit the content
                    color: Colors.white,
                  ),
                  const Icon(Icons.circle, color: Colors.blue, size: 8),
                ],
              ),
              const SizedBox(width: 12),
              // Right Column: Location and Price/Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ride.from,
                          style: whiteTextStyle.copyWith(
                              fontWeight: FontWeight.w500),
                        ),
                        // PRICE / FULL Status
                        Text(
                          ride.isFull
                              ? "Full"
                              : "₹${ride.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: ride.isFull ? Colors.red : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48), // Space to align with timeline
                    Text(
                      ride.to,
                      style: whiteTextStyle.copyWith(
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(color: Colors.grey, height: 32),

          // -----------------
          // 2. Driver Info Row
          // -----------------
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              getDriverAvatar(ride),
              const SizedBox(width: 8),
              Text(
                ride.driverName,
                style: whiteTextStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 4),
              // Show Rating only if not 'Full'
              if (!ride.isFull) ...[
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(
                  ride.rating.toString(),
                  style: whiteTextStyle.copyWith(fontSize: 14),
                ),
              ],
              const Spacer(),
              // Passenger Icon (can represent available seats)
              const Icon(Icons.people_alt, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// --- RideListPage with updated AppBar and Header ---
class RideListPage extends StatelessWidget {
  RideListPage({super.key});

  final List<Ride> rides = [
    Ride(
      from: "Jonk",
      to: "Delhi",
      departureTime: "01:00",
      arrivalTime: "05:20",
      price: 670,
      driverName: "Mohan",
      rating: 5,
    ),
    Ride(
      from: "Paonta Sahib",
      to: "Gurugram",
      departureTime: "01:00",
      arrivalTime: "06:40",
      price: 750,
      driverName: "Tanmay",
      rating: 4.6,
    ),
    Ride(
      from: "Dehradun",
      to: "New Delhi",
      departureTime: "02:00",
      arrivalTime: "06:20",
      price: 0,
      driverName: "Abhishek",
      rating: 0,
      isFull: true,
    ),
    Ride(
      from: "Haridwar",
      to: "Gurugram",
      departureTime: "04:00",
      arrivalTime: "08:30",
      price: 640,
      driverName: "Rohit",
      rating: 4.8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deeper black/dark grey background
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "115, near Gandhi School... → New Del...",
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Tomorrow, 1 passenger",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement filter functionality
            },
            child: const Text(
              "Filter",
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Tomorrow" Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Tomorrow",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // List of Ride Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return RideCard(ride: ride);
              },
            ),
          ),
        ],
      ),
    );
  }
}