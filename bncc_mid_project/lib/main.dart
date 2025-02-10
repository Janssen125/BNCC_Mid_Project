// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

// Global variables to store steps, water, and step records
int steps = 0;
double water = 0.0;
Map<String, int> stepRecords = {}; // Store step data persistently
Map<String, double> waterRecords = {}; // Store step data persistently

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _updateSteps(int newSteps) {
    setState(() {
      steps = newSteps;
    });
  }

  void _updateWater(double newWater) {
    setState(() {
      water = newWater;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Fitness Tracker - Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Steps: $steps'),
            Text('Water: $water L'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StepsScreen(updateSteps: _updateSteps)),
                );
              },
              child: const Text('Go to Steps Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WaterScreen(updateWater: _updateWater)),
                );
              },
              child: const Text('Go to Water Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class StepsScreen extends StatefulWidget {
  final Function updateSteps;
  const StepsScreen({super.key, required this.updateSteps});

  @override
  _StepsScreenState createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final TextEditingController _stepsController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addSteps() {
    final int tsteps = int.tryParse(_stepsController.text) ?? 0;
    String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    if (tsteps > 0) {
      if (stepRecords.containsKey(formattedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Date is already inputted, please edit instead')),
        );
      } else {
        setState(() {
          stepRecords[formattedDate] = tsteps;
          steps += tsteps;
        });
        _stepsController.clear();
        widget.updateSteps(steps);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$tsteps steps added for $formattedDate')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  void _editSteps(String date) {
    _stepsController.text = stepRecords[date].toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Steps for $date"),
          content: TextField(
            controller: _stepsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Enter new steps"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final int newSteps = int.tryParse(_stepsController.text) ?? 0;
                if (newSteps > 0) {
                  setState(() {
                    steps +=
                        newSteps - stepRecords[date]!; // Adjust total steps
                    stepRecords[date] = newSteps;
                  });
                  widget.updateSteps(steps);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid step count")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSteps(String date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Steps for $date?"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  steps -= stepRecords[date]!;
                  stepRecords.remove(date);
                });
                widget.updateSteps(steps);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Fitness Tracker - Steps"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select a date:'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            ),
            const SizedBox(height: 10),
            const Text('Enter your steps:'),
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Steps',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSteps,
              child: const Text('Add Steps'),
            ),
            const SizedBox(height: 20),
            const Text("Steps Record:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: stepRecords.length,
                itemBuilder: (context, index) {
                  String date = stepRecords.keys.elementAt(index);
                  return Card(
                    child: ListTile(
                      title: Text("Date: $date"),
                      subtitle: Text("Steps: ${stepRecords[date]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stepRecords[date]! < 4000
                              ? 'Bad'
                              : stepRecords[date]! <= 8000
                                  ? 'Average'
                                  : 'Good'),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editSteps(date),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSteps(date),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterScreen extends StatefulWidget {
  final Function updateWater;
  const WaterScreen({super.key, required this.updateWater});

  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final TextEditingController _waterController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addWater() {
    final double twater = double.tryParse(_waterController.text) ?? 0;
    String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    if (twater > 0) {
      if (waterRecords.containsKey(formattedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Date is already inputted, please edit instead')),
        );
      } else {
        setState(() {
          waterRecords[formattedDate] = twater;
          water += twater;
        });
        _waterController.clear();
        widget.updateWater(water);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$twater L water added for $formattedDate')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Fitness Tracker - Water"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select a date:'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            ),
            const SizedBox(height: 10),
            const Text('Enter your water:'),
            TextField(
              controller: _waterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Water',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addWater,
              child: const Text('Add Water'),
            ),
            const SizedBox(height: 20),
            const Text("Water Record:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: waterRecords.length,
                itemBuilder: (context, index) {
                  String date = waterRecords.keys.elementAt(index);
                  return Card(
                    child: ListTile(
                      title: Text("Date: $date"),
                      subtitle: Text("Water: ${waterRecords[date]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(waterRecords[date]! < 1.5
                              ? 'Bad'
                              : waterRecords[date]! <= 2
                                  ? 'Average'
                                  : 'Good'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
