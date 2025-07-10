import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRadiusSetupPage extends StatefulWidget {
  final String token;
  final SharedPreferences prefs;

  const NotificationRadiusSetupPage({required this.token, required this.prefs, super.key});

  @override
  _NotificationRadiusSetupPageState createState() => _NotificationRadiusSetupPageState();
}

class _NotificationRadiusSetupPageState extends State<NotificationRadiusSetupPage> {
  double _radius = 5.0; // Default radius in kilometers
  bool _isLoading = false;


  Future<void> _continue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var userService = UserService();
      await userService.updateUser(widget.token, requestNotificationRadius: _radius);
      showToast('Notification radius set to ${_radius.toInt()} km!');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showToast('Error setting notification radius: $e');
    } finally {
      setState(() {
        _isLoading = false;
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

  void _skip() {
    Navigator.pushReplacementNamed(context, '/home');
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
      body: SafeArea(
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
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Set Your Request Radius',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
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
                      padding: EdgeInsets.all(16),
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
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
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
                    
                    SizedBox(height: 20),
                    
                    // Slider
                    Text(
                      'Adjust your radius:',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    
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
                    
                    // Info box
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white70, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'When you request a book, users following bookboxes within this radius will be notified.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF4277B8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4277B8)),
                              ),
                            )
                          : Text(
                              'Continue',
                              style: TextStyle(
                                color: Color(0xFF4277B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
