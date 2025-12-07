import 'package:flutter/material.dart';

// --- 1. Quick Select Widget Definition (Modern Card UI with Add Functionality) ---

class QuickSelectWidget extends StatefulWidget {
  const QuickSelectWidget({super.key});

  @override
  State<QuickSelectWidget> createState() => _QuickSelectWidgetState();
}

class _QuickSelectWidgetState extends State<QuickSelectWidget> {
  // Example list of user-saved quick locations (Now mutable, managed by state)
  List<Map<String, dynamic>> quickLocations = [
    {'label': 'Home', 'icon': Icons.home_filled, 'address': '456 Oak St, City Center'},
    {'label': 'Work', 'icon': Icons.work, 'address': '123 Tech Park, Silicon Valley'},
    {'label': 'Gym', 'icon': Icons.fitness_center, 'address': 'Active Fitness Club, Downtown'},
  ];

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  // --- New: Function to handle adding a new quick location ---
  Future<void> _addQuickLocation(BuildContext context) async {
    _labelController.text = '';
    _addressController.text = '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Add New Quick Location',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _labelController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Label (e.g., School, Friend's House)",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Full Address",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () {
                if (_labelController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop({
                    'label': _labelController.text,
                    'address': _addressController.text,
                  });
                }
              },
            ),
          ],
        );
      },
    );

    // If new data was returned, add it to the list
    if (result != null) {
      setState(() {
        quickLocations.add({
          'label': result['label'],
          'address': result['address'],
          // For simplicity, assign a default icon for new entries
          'icon': Icons.favorite_border,
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['label']} added to Quick Destinations!', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  // Function to handle the address editing dialog (existing)
  Future<void> _editAddress(BuildContext context, int index) async {
    final location = quickLocations[index];
    _addressController.text = location['address'] as String;

    final newAddress = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Edit ${location['label']} Address',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _addressController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Enter new address",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
            ),
            autofocus: true,
            maxLines: 2,
            minLines: 1,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(dialogContext).pop(_addressController.text);
              },
            ),
          ],
        );
      },
    );

    if (newAddress != null && newAddress.isNotEmpty) {
      setState(() {
        quickLocations[index]['address'] = newAddress;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${location['label']} address saved!', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  // New function to handle deletion (existing)
  void _deleteAddress(int index) {
    setState(() {
      final label = quickLocations[index]['label'];
      quickLocations.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label deleted.', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade800,
        ),
      );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Destinations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              // ⭐️ ADD BUTTON: IconButton for adding new location
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 34),
                onPressed: () => _addQuickLocation(context),
                tooltip: 'Add New Location',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List View of Quick Locations
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quickLocations.length,
            itemBuilder: (context, index) {
              final location = quickLocations[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Destination set to ${location['label']}!', style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        // 1. Icon (Leading)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            location['icon'] as IconData, // Uses the actual icon from the map
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 2. Location Info (Expanded to fill space)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location['label'] as String,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location['address'] as String,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // 3. Trailing Action Buttons (Horizontal Group)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Button
                            IconButton(
                              icon: const Icon(Icons.edit, size: 25, color: Colors.black),
                              onPressed: () => _editAddress(context, index),
                              tooltip: 'Edit',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 8),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 25, color: Colors.black),
                              onPressed: () => _deleteAddress(index),
                              tooltip: 'Delete',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}