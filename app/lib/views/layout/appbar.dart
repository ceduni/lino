// app/lib/pages/appbar/appbar_view_model.dart
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/layout/appbar_view_model.dart';

import '../../widgets/language_selector.dart';

class LinoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int sourcePage;

  const LinoAppBar({super.key, required this.sourcePage});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  _LinoAppBarState createState() => _LinoAppBarState();
}

class _LinoAppBarState extends State<LinoAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBarViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppBarViewModel>(
      builder: (context, viewModel, child) {
        return AppBar(
          // TODO: Fix to put it actually at the center
          title: Center(
            child: Image.asset(
              'assets/logos/logo_without_bird.png',
              height: 40,
            ),
          ),
          actions: [
            LanguageSelector()
          ],
          //backgroundColor: LinoColors.accent,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            //child: _buildAppBarContent(viewModel),
          ),
        );

      },
    );
  }

  Widget _buildAppBarContent(AppBarViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(LinoColors.accent),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitleSection(viewModel),
        if (viewModel.isLoggedIn) _buildNotificationSection(viewModel),
      ],
    );
  }

  Widget _buildTitleSection(AppBarViewModel viewModel) {
    return Expanded(
      child: SizedBox(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              widget.sourcePage == 0 ? 'Home' : 
              widget.sourcePage == 1 ? 'Search' : 
              widget.sourcePage == 2 ? 'Requests' : 
              widget.sourcePage == 3 ? 'My Profile' : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection(AppBarViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: viewModel.navigateToNotifications,
        child: Stack(
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications, color: Colors.white),
                
              ],
            ),
            if (viewModel.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    viewModel.unreadCount > 99 ? '99+' : viewModel.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
