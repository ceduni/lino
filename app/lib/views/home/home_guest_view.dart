// app/lib/pages/home/home_guest_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lino_app/vm/home/home_view_model.dart';
import 'package:lino_app/views/home/widgets/news_section.dart';
import 'package:lino_app/views/home/widgets/community_stats.dart';
import 'package:lino_app/views/home/widgets/map_section.dart';
import 'package:lino_app/utils/constants/routes.dart';
import 'package:lino_app/utils/constants/colors.dart';
import 'package:lino_app/l10n/app_localizations.dart';
import 'package:lino_app/controllers/locale_controller.dart';

class HomeGuestView extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeGuestView({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeGuestView> createState() => _HomeGuestViewState();
}

class _HomeGuestViewState extends State<HomeGuestView> {
  final ScrollController _scrollController = ScrollController();
  double _logoHeight = 190.0;
  double _logoTop = 42.0;
  final double _minLogoHeight = 120.0;
  final double _maxLogoHeight = 190.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Calculate logo height based on scroll position
    final scrollOffset = _scrollController.offset;
    final newHeight = (_maxLogoHeight - (scrollOffset * 0.5))
        .clamp(_minLogoHeight, _maxLogoHeight);
    final newTop = (42.0 - (scrollOffset * 0.2)).clamp(6.0, 42.0);

    if (_logoHeight != newHeight) {
      setState(() {
        _logoHeight = newHeight;
      });
    }

    if (_logoTop != newTop) {
      setState(() {
        _logoTop = newTop;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: _logoHeight - 40),

                _buildGuestMessage(localizations),
                const SizedBox(height: 18),

                // Community Stats Widget
                const CommunityStatsWidget(),
                const SizedBox(height: 18),

                // Register BookBox Button
                _buildRegisterBookBoxButton(localizations),
                const SizedBox(height: 24),

                // Map Section Title
                Text(
                  'Bookbox near you',
                  style: const TextStyle(
                    fontFamily: 'UVNDzungDakao',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(31, 73, 125, 1),
                  ),
                ),
                const SizedBox(height: 12),

                // Map Widget
                SizedBox(
                  height: 400,
                  child: MapSectionWidget(
                    viewModel: widget.viewModel,
                    localizations: localizations,
                  ),
                ),
                const SizedBox(height: 24),

                // News Section Widget
                NewsSectionWidget(
                  viewModel: widget.viewModel,
                  localizations: localizations,
                ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),

          // Logo on top
          Positioned(
            top: -_logoTop,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Transform.translate(
                offset: const Offset(10, 0),
                child: Image.asset(
                  'assets/logos/logo_without_bird.png',
                  height: _logoHeight,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.scan.qrScanner),
        backgroundColor: const Color.fromRGBO(31, 73, 125, 1),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.qr_code_scanner,
          size: 32,
        ),
        label: Text(
          localizations.scan,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGuestMessage(AppLocalizations localizations) {
    final localeController = Get.find<LocaleController>();

    return Container(
      padding: const EdgeInsets.only(left: 18.0, right: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 24,
                color: Color.fromRGBO(85, 142, 213, 1),
                fontFamily: 'UVNDzungDakao',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Don\'t forget to '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.auth.login),
                    child: const Text(
                      'log in',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromRGBO(66, 119, 184, 1),
                        fontFamily: 'UVNDzungDakao',
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromRGBO(66, 119, 184, 1),
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: ' to start sharing and make requests to the community.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Language selector
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GetX<LocaleController>(
                builder: (controller) => Row(
                  children: [
                    _buildLanguageOption(
                      text: 'Hello!',
                      flag: '🇺🇸',
                      languageCode: 'en',
                      isSelected: controller.locale.value.languageCode == 'en',
                      onTap: () =>
                          localeController.changeLocale(const Locale('en')),
                    ),
                    const SizedBox(width: 10),
                    _buildLanguageOption(
                      text: 'Salut!',
                      flag: '🇫🇷',
                      languageCode: 'fr',
                      isSelected: controller.locale.value.languageCode == 'fr',
                      onTap: () =>
                          localeController.changeLocale(const Locale('fr')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String text,
    required String flag,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(66, 119, 184, 1)
                : const Color.fromRGBO(225, 225, 225, 1),
            borderRadius: BorderRadius.circular(180),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Kanit-Bold',
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterBookBoxButton(AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to register bookbox page
          // Get.toNamed(AppRoutes.bookbox.register);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: LinoColors.accent,
          foregroundColor: LinoColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.add_box_rounded, size: 24),
        label: const Text(
          'Register a BookBox',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Kanit-Bold',
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}