import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants/colors.dart';

class NotificationRadiusPage extends StatefulWidget {
  @override
  _NotificationRadiusPageState createState() => _NotificationRadiusPageState();
}

class _NotificationRadiusPageState extends State<NotificationRadiusPage> {
  double _radius = 5.0; // Default radius in kilometers
  bool _isLoading = true;
  bool _isSaving = false;
  String? _token;

  // Predefined radius options
  final List<double> _radiusOptions = [1.0, 2.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _loadCurrentRadius();
  }

  Future<void> _loadCurrentRadius() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      if (_token == null) throw Exception('No token found');

      final userService = UserService();
      final user = await userService.getUser(_token!);
      final currentRadius = user['user']?['requestNotificationRadius'];
      
      setState(() {
        if (currentRadius != null) {
          _radius = (currentRadius as num).toDouble();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading current radius: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRadius() async {
    setState(() {
      _isSaving = true;
    });

    try {
      var userService = UserService();
      await userService.updateUser(_token!, requestNotificationRadius: _radius);
      showToast('Notification radius updated to ${_radius.toInt()} km!');
      Navigator.pop(context);
    } catch (e) {
      showToast('Error updating notification radius: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  String _getRadiusDescription(double radius) {
    if (radius <= 2.0) {
      return 'Very close - Walking distance';
    } else if (radius <= 5.0) {
      return 'Close - Short bike ride or drive';
    } else if (radius <= 15.0) {
      return 'Moderate - Within your neighborhood';
    } else if (radius <= 25.0) {
      return 'Far - Across town';
    } else {
      return 'Very far - Citywide';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      appBar: AppBar(
        title: Text('Request Notification Radius'),
        backgroundColor: Color(0xFF4277B8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header section
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Update Your Request Radius',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'How far are you willing to travel to pick up books you request?',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Content section
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // Current radius display
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_radius.toInt()} km',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _getRadiusDescription(_radius),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Slider
                          Text(
                            'Adjust your radius:',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 20),
                          
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withOpacity(0.2),
                              valueIndicatorColor: Colors.white,
                              valueIndicatorTextStyle: TextStyle(color: Color(0xFF4277B8)),
                            ),
                            child: Slider(
                              value: _radius,
                              min: 1.0,
                              max: 50.0,
                              divisions: 49,
                              label: '${_radius.toInt()} km',
                              onChanged: (value) {
                                setState(() {
                                  _radius = value;
                                });
                              },
                            ),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Quick selection buttons
                          Text(
                            'Quick select:',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 12),
                          
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _radiusOptions.map((option) {
                              final isSelected = _radius == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _radius = option;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${option.toInt()} km',
                                    style: TextStyle(
                                      color: isSelected ? Color(0xFF4277B8) : Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Info box
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.white70, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'When you request a book, users following bookboxes within this radius will be notified.',
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom buttons section
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSaving ? null : _cancel,
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveRadius,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              backgroundColor: LinoColors.buttonPrimary,
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
