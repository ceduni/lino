// lib/screens/onboarding_page.dart
import 'package:flutter/material.dart';

// TODO: change OnboardingPage to a stateful widget to go away auto

// The OnboardingPage class is a stateless widget which defines the structure of the onboarding screen
class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides the structure for the visual interface
      body: SafeArea(
        // SafeArea ensures that the UI does not overlap with system interfaces like notches, status bars, etc.
        child: Column(
          // Column widget arranges its children in a vertical layout
          children: <Widget>[
            // Expanded widget allows the child to take all the available space
            Expanded(
              child: Center(
                // Center widget centers its child both vertically and horizontally
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Column widget arranges its children in a vertical layout
                  children: <Widget>[
                    // Logo
                    Image.asset(
                      'assets/logo_without_bird.png', // Path to the logo image in the assets directory
                      width: MediaQuery.of(context).size.width *
                          0.5, // Adjust the width dynamically based on the screen width
                      height: MediaQuery.of(context).size.width *
                          0.5, // Adjust the height dynamically based on the screen width
                    ),
                    SizedBox(
                        height:
                            20), // Spacer widget to add space between logo and text
                    // Title
                    Text(
                      "Welcome to Lino, world's best community library platform!",
                      // Text widget displays a string of text with specified style
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            10), // Spacer widget to add space between title and subtitle
                    // Subtitle
                    Text(
                      'Made with a lot of Red Bull by Team Lino',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Padding widget adds padding around the child widget
          ],
        ),
      ),
    );
  }
}
