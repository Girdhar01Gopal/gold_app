import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controllers/dashboard_controller.dart';
import '../infrastructure/routes/admin_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isWideLayout = size.width >= 900;
    final s = (size.width / 1200).clamp(0.85, 1.2);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F1115)
          : const Color(0xFFF2F5FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(128 * s),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFA10D52), const Color(0xFF2B6CB0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: 22 * s,
              left: 18 * s,
              right: 18 * s,
              bottom: 12 * s,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48 * s,
                      height: 48 * s,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24 * s,
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              controller.studentname.value
                                  .replaceAll('"', '')
                                  .trim(),
                              style: TextStyle(
                                fontSize: 18 * s,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 2 * s),
                          Obx(
                            () => Text(
                              '${controller.className.value.replaceAll('"', '').trim()} • ${controller.session.value.replaceAll('"', '').replaceAll('-', '-').trim()}',
                              style: TextStyle(
                                fontSize: 12 * s,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * s),
                Text(
                  'Select your subject',
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -80,
            child: _circle(const Color(0xFFA10D52).withOpacity(0.12), 260),
          ),
          Positioned(
            bottom: -70,
            left: -70,
            child: _circle(const Color(0xFF4CA1AF).withOpacity(0.10), 220),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
            child: Obx(() {
              if (controller.subjects.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: ColorPainter.primaryColor,
                  ),
                );
              }

              if (isWideLayout) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14 * s,
                    mainAxisSpacing: 14 * s,
                    childAspectRatio: 3.8,
                  ),
                  itemCount: controller.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = controller.subjects[index];
                    return _buildSubjectCard(
                      subject.subjectName ?? 'No Name',
                      () {
                        Get.offAllNamed(
                          AdminRoutes.CONTINUE_SCREEN,
                          arguments: {
                            'subjectId': subject.subjectId.toString(),
                            'subjectName': subject.subjectName.toString(),
                          },
                        );
                      },
                      context,
                      index,
                      isDarkMode,
                    );
                  },
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.subjects.length,
                itemBuilder: (context, index) {
                  final subject = controller.subjects[index];
                  return _buildSubjectCard(
                    subject.subjectName ?? 'No Name',
                    () {
                      Get.offAllNamed(
                        AdminRoutes.CONTINUE_SCREEN,
                        arguments: {
                          'subjectId': subject.subjectId.toString(),
                          'subjectName': subject.subjectName.toString(),
                        },
                      );
                    },
                    context,
                    index,
                    isDarkMode,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSubjectCard(
    String subject,
    VoidCallback onPressed,
    BuildContext context,
    int index,
    bool isDarkMode,
  ) {
    final s = (MediaQuery.of(context).size.width / 1200).clamp(0.85, 1.2);

    IconData getSubjectIcon(String subjectName) {
      final name = subjectName.toLowerCase();
      if (name.contains('math')) return Icons.calculate_rounded;
      if (name.contains('physics')) return Icons.science_rounded;
      if (name.contains('chemistry')) return Icons.biotech_rounded;
      if (name.contains('biology')) return Icons.eco_rounded;
      if (name.contains('english')) return Icons.menu_book_rounded;
      return Icons.school_rounded;
    }

    List<Color> getGradientColors(int idx) {
      final colorSets = [
        [const Color(0xFFA10D52), const Color(0xFF1976D2)],
        [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)],
        [const Color(0xFFD84315), const Color(0xFFFF6F00)],
        [const Color(0xFF2E7D32), const Color(0xFF43A047)],
        [const Color(0xFFC62828), const Color(0xFFE53935)],
      ];
      return colorSets[idx % colorSets.length];
    }

    final gradientColors = getGradientColors(index);
    final initials = subject
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word.characters.first.toUpperCase())
        .join();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.only(bottom: 12 * s),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1A1D23)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showLoadingDialog(context);
            Future.delayed(const Duration(milliseconds: 900), () {
              if (!mounted) return;
              Navigator.of(context).pop();
              onPressed();
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
            child: Row(
              children: [
                Container(
                  width: 52 * s,
                  height: 52 * s,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.33),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    getSubjectIcon(subject),
                    color: Colors.white,
                    size: 24 * s,
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        'Open assignments and continue learning',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11 * s,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * s),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * s,
                        vertical: 6 * s,
                      ),
                      decoration: BoxDecoration(
                        color: gradientColors.first.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        initials.isEmpty ? 'SB' : initials,
                        style: TextStyle(
                          color: gradientColors.first,
                          fontWeight: FontWeight.w700,
                          fontSize: 10 * s,
                        ),
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: gradientColors.first,
                      size: 20 * s,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    final s = (MediaQuery.of(context).size.width / 1200).clamp(0.85, 1.2);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24 * s),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24 * s),
              boxShadow: [
                BoxShadow(
                  color: ColorPainter.primaryColor.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: ColorPainter.secondaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(18 * s),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPainter.primaryColor,
                        ColorPainter.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColorPainter.secondaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.white,
                    size: 28 * s,
                  ),
                ),
                SizedBox(height: 20 * s),
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: ColorPainter.primaryColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8 * s),
                Text(
                  'Loading your content',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ColorPainter {
  static const Color primaryColor = Color(0xFF9B1313);
  static const Color secondaryColor = Color(0xFFD69B08);
  static const Color accentColor = Color(0xFF4CA1AF);

  static LinearGradient get gradientBackground => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get buttonGradient => LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get boxDecoration => BoxDecoration(
    gradient: gradientBackground,
    borderRadius: BorderRadius.circular(25),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 12,
        color: Colors.black.withOpacity(0.15),
      ),
    ],
    borderRadius: BorderRadius.circular(20),
  );

  static BoxDecoration get buttonBoxDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(30),
  );
}
