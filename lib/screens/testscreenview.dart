import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/testscreencontroller.dart';

class Testscreenview extends StatefulWidget {
  const Testscreenview({super.key});

  @override
  State<Testscreenview> createState() => _TestscreenviewState();
}

class _TestscreenviewState extends State<Testscreenview> {
  late final Testscreencontroller controller;
  static const Color _primaryColor = Color(0xFFA10D52);
  static const Color _secondaryColor = Color(0xFFFFA000);
  static const Color _accentColor = Color(0xFF4CA1AF);
  static const Color _deepInk = Color(0xFF2B1A1F);

  @override
  void initState() {
    super.initState();
    controller = Get.put(Testscreencontroller());
  }

  void _openImagePreview(String imageUrl) {
    final screenSize = MediaQuery.of(context).size;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 6.0,
                    boundaryMargin: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: screenSize.width * 0.95,
                      height: screenSize.height * 0.82,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required Testscreencontroller controller,
    required Map<String, dynamic> question,
    required Map<String, dynamic> option,
    required bool isDarkMode,
    required double fs,
  }) {
    final qid = question['id'];
    final optionKey = option['key'];
    final optionValue = option['value'];
    final rawImg = option['img'];
    final optionImg = controller.hasValidImage(rawImg)
        ? controller.buildImgUrl(rawImg)
        : '';
    // Debug print to verify image URL
    // ignore: avoid_print
    print('Option $optionKey image URL: $optionImg');
    final questionType = (question['questionType'] ?? '')
        .toString()
        .toLowerCase();
    final isMultiSelect =
        questionType.contains('ismcq') ||
        questionType.contains('m.c.q') ||
        questionType.contains('mcq');
    return Obx(() {
      final selectedSet = controller.selectedAnswers[qid] ?? <String>{};
      final selected = selectedSet.contains(optionKey);
      return GestureDetector(
        onTap: () {
          controller.selectOption(qid, optionKey);
          if (questionType.contains('comprehension') &&
              !controller.visitedQuestions.contains(qid)) {
            controller.visitedQuestions.add(qid);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.symmetric(vertical: 3.h),
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected
                ? (isDarkMode ? Colors.grey[800] : const Color(0xFFF8E3EC))
                : (isDarkMode ? Colors.grey[850] : Colors.white),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected
                  ? (isDarkMode ? _secondaryColor : _primaryColor)
                  : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
              width: 1.1,
            ),
            boxShadow: [
              if (selected)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMultiSelect)
                Checkbox(
                  value: selected,
                  onChanged: (_) => controller.selectOption(qid, optionKey),
                  activeColor: isDarkMode ? _secondaryColor : _secondaryColor,
                )
              else
                Radio<String>(
                  value: optionKey,
                  groupValue: selectedSet.isNotEmpty ? selectedSet.first : null,
                  onChanged: (_) => controller.selectOption(qid, optionKey),
                  activeColor: isDarkMode ? Colors.grey[400] : _primaryColor,
                ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$optionKey.  $optionValue",
                      style: TextStyle(
                        fontSize: 7.sp * fs,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.grey[300] : Colors.black87,
                        height: 1.1,
                        fontFamily: null, // Use default font (same as question)
                      ),
                    ),
                    if (optionImg.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          // onTap: () => _openImagePreview(optionImg),
                          child: Image.network(
                            optionImg,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPaletteBox({
    required int i,
    required Map<String, dynamic> q,
    required Testscreencontroller controller,
    required double fs,
    required bool isDarkMode,
  }) {
    final id = q['id'];
    return Obx(() {
      final selectedAnswers = controller.selectedAnswers;
      final selectedIntegerAnswers = controller.selectedIntegerAnswers;
      final markedForReview = controller.markedForReview;
      final visitedQuestions = controller.visitedQuestions;
      // Determine if this is an integer type question
      final questionType = (q['questionType'] ?? '').toString().toLowerCase();
      final isIntegerType = questionType.contains('integer');
      // Consider answered if: normal answered, or integer type and a digit is selected
      final isNumericRange = questionType.contains('numeric range');
      final isComprehension = questionType.contains('comprehension');
      final isMatch = questionType.contains('match');
      final answered = isIntegerType
          ? (selectedIntegerAnswers.containsKey(id) &&
                selectedIntegerAnswers[id] != null &&
                selectedIntegerAnswers[id] != -1 &&
                selectedIntegerAnswers[id].toString().isNotEmpty)
          : isNumericRange
          ? controller.hasNumericRangeAnswer(
              id,
              subject: controller.selectedSubject.value,
            )
          : isComprehension || isMatch
          ? (selectedAnswers.containsKey(id) &&
                (selectedAnswers[id]?.isNotEmpty ?? false))
          : (selectedAnswers.containsKey(id) &&
                (selectedAnswers[id]?.isNotEmpty ?? false));
      final marked = markedForReview.contains(id);
      final visited = visitedQuestions.contains(id);
      final displayIndex = i + 1;
      Widget paletteBox;
      if (answered && marked) {
        paletteBox = Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: _secondaryColor, width: 2),
              ),
              child: Text(
                displayIndex.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 4.5.sp,
                ),
              ),
            ),
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        );
      } else if (marked) {
        paletteBox = Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _secondaryColor, width: 2),
          ),
          child: Text(
            displayIndex.toString().padLeft(2, '0'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 4.5.sp,
            ),
          ),
        );
      } else if (answered) {
        paletteBox = Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: Text(
            displayIndex.toString().padLeft(2, '0'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 4.5.sp,
            ),
          ),
        );
      } else if (visited && !answered) {
        paletteBox = Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _secondaryColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: _primaryColor, width: 2),
          ),
          child: Text(
            displayIndex.toString().padLeft(2, '0'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 4.5.sp,
            ),
          ),
        );
      } else {
        paletteBox = Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFF3E9C9),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: _primaryColor.withOpacity(0.55),
              width: 2,
            ),
          ),
          child: Text(
            displayIndex.toString().padLeft(2, '0'),
            style: TextStyle(
              color: isDarkMode ? Colors.white : _deepInk,
              fontWeight: FontWeight.bold,
              fontSize: 4.5.sp,
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          controller.discardUnsavedSelectionForCurrentQuestion();
          controller.currentIndex.value = i;
          controller.visitedQuestions.add(id);
        },
        child: paletteBox,
      );
    });
  }

  // Small square-like indicator + count inside (legend)
  Widget _legendBox({
    required int count,
    required Color color,
    bool outlined = false,
    bool circle = false,
    bool badge = false, // for Answered & Marked
  }) {
    final base = Container(
      width: 17.w,
      height: 25.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        shape: circle ? BoxShape.rectangle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(6.r),
        border: outlined ? Border.all(color: color, width: 2) : null,
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 4.sp,
          color: outlined ? color : Colors.white,
        ),
      ),
    );

    if (!badge) return base;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 17.w,
          height: 8.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6.r)),
            color: _primaryColor,
            shape: BoxShape.rectangle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 4.sp,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 5.w,
            height: 5.w,
            decoration: BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendRow({
    required Widget iconBox,
    required String label,
    required bool isDarkMode,
    double gap = 10,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconBox,
        SizedBox(width: gap.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 3.sp,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[200] : Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLegend({
    required Testscreencontroller controller,
    required bool isDarkMode,
    required double fs,
  }) {
    return Obx(() {
      final questions = controller.currentQuestions;
      if (questions.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
            ),
          ),
          child: Text(
            "No questions loaded.",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDarkMode ? Colors.grey[300] : Colors.grey.shade800,
            ),
          ),
        );
      }

      int notVisited = 0;
      int notAnswered = 0;
      int answered = 0;
      int markedOnly = 0;
      int answeredAndMarked = 0;

      final selectedAnswers = controller.selectedAnswers;
      final selectedIntegerAnswers = controller.selectedIntegerAnswers;
      final markedIds = controller.markedForReview;
      final visitedIds = controller.visitedQuestions;

      bool isAnsweredQ(Map<String, dynamic> q) {
        final int id = (q['id'] as num).toInt();
        final type = (q['questionType'] ?? '').toString().toLowerCase();

        if (type.contains('integer type')) {
          final v = selectedIntegerAnswers[id];
          return v != null && v != -1;
        }

        if (type.contains('numeric range')) {
          return controller.hasNumericRangeAnswer(
            id,
            subject: controller.selectedSubject.value,
          );
        }

        // numeric range, scq, mcq, match, comprehension all stored in selectedAnswers
        final set = selectedAnswers[id];
        return set != null && set.isNotEmpty;
      }

      for (final q in questions) {
        final int id = (q['id'] as num).toInt();

        final bool visited = visitedIds.contains(id);
        final bool marked = markedIds.contains(id);
        final bool answeredQ = isAnsweredQ(q);

        if (answeredQ && marked) {
          answeredAndMarked++;
        } else if (answeredQ && !marked) {
          answered++;
        } else if (!answeredQ && marked) {
          markedOnly++;
        } else if (!visited) {
          notVisited++;
        } else {
          notAnswered++;
        }
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 350;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmall ? 3.w : 6.w),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                _legendRow(
                  iconBox: _legendBox(
                    count: notVisited,
                    color: isDarkMode ? Colors.grey.shade400 : _deepInk,
                    outlined: true,
                  ),
                  label: "Not Visited",
                  isDarkMode: isDarkMode,
                  gap: isSmall ? 2 : 6,
                ),
                SizedBox(height: isSmall ? 2.h : 5.h),
                _legendRow(
                  iconBox: _legendBox(
                    count: notAnswered,
                    color: _secondaryColor,
                  ),
                  label: "Not Answered",
                  isDarkMode: isDarkMode,
                  gap: isSmall ? 2 : 6,
                ),
                SizedBox(height: isSmall ? 2.h : 5.h),
                _legendRow(
                  iconBox: _legendBox(count: answered, color: _primaryColor),
                  label: "Answered",
                  isDarkMode: isDarkMode,
                  gap: isSmall ? 2 : 6,
                ),
                SizedBox(height: isSmall ? 2.h : 5.h),
                _legendRow(
                  iconBox: _legendBox(count: markedOnly, color: _accentColor),
                  label: "Marked for Review",
                  isDarkMode: isDarkMode,
                  gap: isSmall ? 2 : 6,
                ),
                SizedBox(height: isSmall ? 2.h : 5.h),
                _legendRow(
                  iconBox: _legendBox(
                    count: answeredAndMarked,
                    color: _accentColor,
                    badge: true,
                  ),
                  label:
                      "Answered & Marked for Review (will be considered for evaluation)",
                  isDarkMode: isDarkMode,
                  gap: isSmall ? 2 : 6,
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.timerStarted.value) {
        controller.timerStarted.value = true;
        controller.startTimer(controller.viewsecond.value);
      }
    });

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final fs = controller.fontScale.value * 0.7;
      final currentQuestions = controller.currentQuestions;
      final currentIndex = controller.currentIndex.value;
      final question = currentQuestions.isNotEmpty
          ? currentQuestions[currentIndex]
          : <String, dynamic>{
              'question': '',
              'questionImg': '',
              'options': [],
              'id': '',
              'questionType': '',
            };
      final questionType = (question['questionType'] ?? '').toString();
      final isNumeric = questionType.toLowerCase().contains('numeric range');
      final isinteger = questionType.toLowerCase().contains('integer type');
      final iscomprehnsion = questionType.toLowerCase().contains(
        'comprehension',
      );
      final isscq = questionType.toLowerCase().contains('S.C.Q');
      final ismatch = questionType.toLowerCase().contains('match');

      return WillPopScope(
        onWillPop: () async {
          return false; // deny back button
        },
        child: Scaffold(
          backgroundColor: isDarkMode
              ? Colors.grey[900]
              : const Color(0xFFF2F5FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF3F1238), const Color(0xFF0F172A)]
                      : [_primaryColor, _accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Abhyasa",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: controller.decreaseFont,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "${(controller.fontScale.value * 100).round()}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: controller.increaseFont,
                      ),
                      SizedBox(width: 8.w),
                      Obx(
                        () => Text(
                          controller.formattedTime,
                          style: TextStyle(
                            color: controller.remainingSeconds.value < 600
                                ? Colors.red.shade200
                                : Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.only(right: 8.w, top: 7.h, bottom: 7.h),
              //   child: Material(
              //     color: Colors.white.withValues(alpha: 0.15),
              //     borderRadius: BorderRadius.circular(20.r),
              //     child: InkWell(
              //       borderRadius: BorderRadius.circular(20.r),
              //       onTap: () {
              //         // Get.toNamed(
              //         //   AdminRoutes.instruction,
              //         //   arguments: {
              //         //     'testId': controller.testId.value,
              //         //     'passcode': controller.passcode.value,
              //         //     'type': "Test Instructions",
              //         //   },
              //         // );
              //       },
              //       child: Padding(
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 8.w,
              //           vertical: 6.h,
              //         ),
              //         child: Row(
              //           children: [
              //             Icon(
              //               Icons.info_outline,
              //               color: Colors.white,
              //               size: 7.sp,
              //             ),
              //             SizedBox(width: 4.w),
              //             Text(
              //               "Instructions",
              //               style: TextStyle(
              //                 fontSize: 4.sp,
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam content (left)
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.fromLTRB(8.w, 8.h, 4.w, 8.h),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF111827) : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white12
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      if (!isDarkMode)
                        const BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Main scrollable content (question + options)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.03)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white12
                                        : const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Subject chips
                                    Obx(() {
                                      final subjects = List<String>.from(
                                        controller.subjects,
                                      );
                                      if (subjects.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      if (subjects.length == 1) {
                                        final subject = subjects.first;
                                        return Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? const Color(0xFF1F2937)
                                                : const Color(0xFFFDF2F8),
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.white12
                                                  : _primaryColor.withOpacity(
                                                      0.25,
                                                    ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.menu_book_rounded,
                                                size: 12.sp,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : _primaryColor,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                subject,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : _primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 5.sp,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Wrap(
                                        spacing: 5.w,
                                        runSpacing: 3.h,
                                        alignment: WrapAlignment.center,
                                        children: subjects.map((subject) {
                                          final isSelected =
                                              controller
                                                  .selectedSubject
                                                  .value ==
                                              subject;
                                          return ChoiceChip(
                                            checkmarkColor: Colors.white,
                                            label: Text(
                                              subject,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDarkMode
                                                          ? Colors.grey[300]
                                                          : Colors
                                                                .grey
                                                                .shade800),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 4.sp,
                                              ),
                                            ),
                                            selected: isSelected,
                                            selectedColor: isDarkMode
                                                ? Colors.grey[700]
                                                : _primaryColor,
                                            backgroundColor: isDarkMode
                                                ? Colors.grey[850]
                                                : Colors.white,
                                            elevation: 2,
                                            pressElevation: 4,
                                            side: BorderSide(
                                              color: isSelected
                                                  ? (isDarkMode
                                                        ? Colors.grey[600]!
                                                        : _primaryColor)
                                                  : (isDarkMode
                                                        ? Colors.grey[700]!
                                                        : Colors.grey.shade300),
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                controller
                                                    .discardUnsavedSelectionForCurrentQuestion();
                                                controller
                                                        .selectedSubject
                                                        .value =
                                                    subject;
                                                controller.currentIndex.value =
                                                    0;
                                                controller
                                                    .resetNumericController();
                                              }
                                            },
                                          );
                                        }).toList(),
                                      );
                                    }),
                                    SizedBox(height: 2.h),
                                    // Question type chips
                                    Obx(
                                      () => Wrap(
                                        spacing: 5.w,
                                        runSpacing: 3.h,
                                        alignment: WrapAlignment.center,
                                        children: controller.questionTypes.map((
                                          type,
                                        ) {
                                          final isSelected =
                                              controller
                                                  .selectedQuestionType
                                                  .value ==
                                              type;
                                          return ChoiceChip(
                                            checkmarkColor: Colors.white,
                                            label: Text(
                                              type.isNotEmpty
                                                  ? type
                                                  : 'No Type',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDarkMode
                                                          ? Colors.grey[300]
                                                          : Colors
                                                                .grey
                                                                .shade800),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 4.sp,
                                              ),
                                            ),
                                            selected: isSelected,
                                            selectedColor: isDarkMode
                                                ? Colors.amber[800]
                                                : _secondaryColor,
                                            backgroundColor: isDarkMode
                                                ? Colors.grey[850]
                                                : Colors.white,
                                            elevation: 2,
                                            pressElevation: 4,
                                            side: BorderSide(
                                              color: isSelected
                                                  ? (isDarkMode
                                                        ? Colors.amber[700]!
                                                        : _secondaryColor)
                                                  : (isDarkMode
                                                        ? Colors.grey[700]!
                                                        : Colors.grey.shade300),
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                controller
                                                    .discardUnsavedSelectionForCurrentQuestion();
                                                controller
                                                        .selectedQuestionType
                                                        .value =
                                                    type;
                                                controller.currentIndex.value =
                                                    0;
                                                controller
                                                    .resetNumericController();
                                              }
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Q${controller.currentIndex.value + 1} / ${currentQuestions.length}",
                                    style: TextStyle(
                                      fontSize: 6.sp * fs,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.grey[300]
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Divider(
                                color: isDarkMode
                                    ? Colors.grey[700]
                                    : Colors.grey.shade300,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: isDarkMode
                                      ? Colors.grey[850]
                                      : Colors.white,
                                  elevation: isDarkMode ? 0 : 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: isDarkMode
                                          ? Colors.white12
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4.h),
                                        if (iscomprehnsion) ...[
                                          if (controller.hasValidImage(
                                            question['questionImg'],
                                          ))
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 8.h,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                child: GestureDetector(
                                                  onTap: () => _openImagePreview(
                                                    controller.imgUrl(
                                                      question['questionImg']
                                                          .toString(),
                                                    ),
                                                  ),
                                                  child: Image.network(
                                                    controller.imgUrl(
                                                      question['questionImg']
                                                          .toString(),
                                                    ),
                                                    width: double.infinity,
                                                    fit: BoxFit
                                                        .fitWidth, // full width, no distortion
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Text(
                                            question['question'],
                                            style: TextStyle(
                                              fontSize: 7.sp * fs,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.grey[300]
                                                  : Colors.black87,
                                              height: 1.1,
                                              fontFamily:
                                                  null, // Use default font
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ] else ...[
                                          Text(
                                            question['question'],
                                            style: TextStyle(
                                              fontSize: 7.sp * fs,
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.grey[300]
                                                  : Colors.black87,
                                              height: 1.1,
                                              fontFamily:
                                                  null, // Use default font
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                          if (controller.hasValidImage(
                                            question['questionImg'],
                                          ))
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.h,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                child: GestureDetector(
                                                  onTap: () => _openImagePreview(
                                                    controller.imgUrl(
                                                      question['questionImg']
                                                          .toString(),
                                                    ),
                                                  ),
                                                  child: Image.network(
                                                    controller.imgUrl(
                                                      question['questionImg']
                                                          .toString(),
                                                    ),
                                                    width: double.infinity,
                                                    fit: BoxFit
                                                        .fitWidth, // full width, no distortion
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (isNumeric)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                    horizontal: 4.w,
                                  ),
                                  child: TextField(
                                    key: ValueKey(
                                      'numeric_${controller.selectedSubject.value}_${controller.selectedQuestionType.value}_${question['id']}',
                                    ),
                                    controller: controller.controllerText,
                                    keyboardType:
                                        TextInputType.text, // Γ£à full keyboard
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+\-*/().]'),
                                      ),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Enter your answer',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (val) {
                                      controller.setNumericAnswer(
                                        question['id'],
                                        val,
                                      );
                                    },
                                  ),
                                )
                              else if (isinteger)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                    horizontal: 4.w,
                                  ),
                                  child: Obx(() {
                                    final selected =
                                        controller
                                            .selectedIntegerAnswers[question['id']] ??
                                        -1;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(10, (index) {
                                        return Row(
                                          children: [
                                            Radio<int>(
                                              value: index,
                                              groupValue: selected,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller.setIntegerAnswer(
                                                    question['id'],
                                                    val,
                                                  );
                                                }
                                              },
                                            ),
                                            Text(
                                              index.toString(),
                                              style: TextStyle(fontSize: 7.sp),
                                            ),
                                          ],
                                        );
                                      }),
                                    );
                                  }),
                                ),
                              // Unified single choice for single correct, comprehension, and match
                              if (questionType.toLowerCase().contains(
                                    's.c.q',
                                  ) ||
                                  iscomprehnsion ||
                                  ismatch)
                                Column(
                                  children: [
                                    for (final option
                                        in question['options'] ?? [])
                                      Obx(() {
                                        final qid = question['id'];
                                        final selectedSet =
                                            controller.selectedAnswers[qid] ??
                                            <String>{};
                                        final isSelected = selectedSet.contains(
                                          option['key'],
                                        );
                                        final rawImg = option['img'];
                                        final optionImg =
                                            controller.hasValidImage(rawImg)
                                            ? controller.buildImgUrl(rawImg)
                                            : '';
                                        return ListTile(
                                          leading: Radio<String>(
                                            value: option['key'],
                                            groupValue: selectedSet.isNotEmpty
                                                ? selectedSet.first
                                                : null,
                                            onChanged: (_) =>
                                                controller.selectOption(
                                                  qid,
                                                  option['key'],
                                                ),
                                            activeColor: isDarkMode
                                                ? Colors.grey[400]
                                                : _primaryColor,
                                          ),
                                          title: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Builder(
                                              builder: (_) {
                                                final keyStr =
                                                    (option['key'] ?? '')
                                                        .toString()
                                                        .trim();
                                                final valueStr =
                                                    (option['value'] ?? '')
                                                        .toString()
                                                        .trim();
                                                final hasText =
                                                    valueStr.isNotEmpty &&
                                                    valueStr.toLowerCase() !=
                                                        'null';
                                                final hasImg =
                                                    optionImg.isNotEmpty;

                                                // ≡ƒö╣ CASE 1: Text exists ΓåÆ Column layout
                                                if (hasText) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15.0,
                                                            ),
                                                        child: Text(
                                                          "$keyStr. $valueStr",
                                                          style: TextStyle(
                                                            color: isDarkMode
                                                                ? Colors
                                                                      .grey[300]
                                                                : Colors
                                                                      .black87,
                                                            fontSize: 6.sp * fs,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .w500,
                                                            height: 1.2,
                                                          ),
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                      if (hasImg) ...[
                                                        SizedBox(height: 8.h),
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.r,
                                                              ),
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                  maxHeight:
                                                                      110.h,
                                                                ),
                                                            child: GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .opaque,
                                                              // onTap: () =>
                                                              //     _openImagePreview(
                                                              //       optionImg,
                                                              //     ),
                                                              child: Image.network(
                                                                optionImg,
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .contain,
                                                                errorBuilder:
                                                                    (
                                                                      _,
                                                                      __,
                                                                      ___,
                                                                    ) =>
                                                                        const SizedBox.shrink(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  );
                                                }

                                                // ≡ƒö╣ CASE 2: No text ΓåÆ key + image in Row
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "$keyStr.",
                                                      style: TextStyle(
                                                        fontSize: 7.sp * fs,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDarkMode
                                                            ? Colors.grey[300]
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    if (hasImg)
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.r,
                                                              ),
                                                          child: ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                  maxHeight:
                                                                      90.h,
                                                                ),
                                                            child: GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .opaque,
                                                              // onTap: () =>
                                                              //     _openImagePreview(
                                                              //       optionImg,
                                                              //     ),
                                                              child: Image.network(
                                                                optionImg,
                                                                fit: BoxFit
                                                                    .contain,
                                                                errorBuilder:
                                                                    (
                                                                      _,
                                                                      __,
                                                                      ___,
                                                                    ) =>
                                                                        const SizedBox.shrink(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          onTap: () => controller.selectOption(
                                            qid,
                                            option['key'],
                                          ),
                                        );
                                      }),
                                  ],
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: question['options'] != null
                                      ? question['options'].length
                                      : 0,
                                  itemBuilder: (context, index) {
                                    final option = question['options'][index];
                                    return Obx(() {
                                      final qid = question['id'];
                                      final selectedSet =
                                          controller.selectedAnswers[qid] ??
                                          <String>{};
                                      final isSelected = selectedSet.contains(
                                        option['key'],
                                      );
                                      final rawImg = option['img'];
                                      final optionImg =
                                          controller.hasValidImage(rawImg)
                                          ? controller.buildImgUrl(rawImg)
                                          : '';
                                      return ListTile(
                                        leading: Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => controller
                                              .selectOption(qid, option['key']),
                                          activeColor: isDarkMode
                                              ? _secondaryColor
                                              : _secondaryColor,
                                        ),
                                        title: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Colors.grey[800]
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Builder(
                                            builder: (_) {
                                              final keyStr =
                                                  (option['key'] ?? '')
                                                      .toString()
                                                      .trim();
                                              final valueStr =
                                                  (option['value'] ?? '')
                                                      .toString()
                                                      .trim();
                                              final hasText =
                                                  valueStr.isNotEmpty &&
                                                  valueStr.toLowerCase() !=
                                                      'null';
                                              final hasImg =
                                                  optionImg.isNotEmpty;

                                              // ≡ƒö╣ CASE 1: Text exists ΓåÆ Column layout
                                              if (hasText) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 15.0,
                                                          ),
                                                      child: Text(
                                                        "$keyStr. $valueStr",
                                                        style: TextStyle(
                                                          color: isDarkMode
                                                              ? Colors.grey[300]
                                                              : Colors.black87,
                                                          fontSize: 7.sp * fs,
                                                          fontWeight: isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.w500,
                                                          height: 1.2,
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                    if (hasImg) ...[
                                                      SizedBox(height: 8.h),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                maxHeight:
                                                                    110.h,
                                                              ),
                                                          child: GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            // onTap: () =>
                                                            //     _openImagePreview(
                                                            //       optionImg,
                                                            //     ),
                                                            child: Image.network(
                                                              optionImg,
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit
                                                                  .contain,
                                                              errorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                    ___,
                                                                  ) =>
                                                                      const SizedBox.shrink(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                );
                                              }

                                              // ≡ƒö╣ CASE 2: No text ΓåÆ key + image in Row
                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "$keyStr.",
                                                    style: TextStyle(
                                                      fontSize: 7.sp * fs,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkMode
                                                          ? Colors.grey[300]
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  if (hasImg)
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.r,
                                                            ),
                                                        child: ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                maxHeight: 90.h,
                                                              ),
                                                          child: GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            // onTap: () =>
                                                            //     _openImagePreview(
                                                            //       optionImg,
                                                            //     ),
                                                            child: Image.network(
                                                              optionImg,
                                                              fit: BoxFit
                                                                  .contain,
                                                              errorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                    ___,
                                                                  ) =>
                                                                      const SizedBox.shrink(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        onTap: () => controller.selectOption(
                                          qid,
                                          option['key'],
                                        ),
                                      );
                                    });
                                  },
                                ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                      // Fixed action buttons at the bottom
                      Container(
                        width: 260.w,
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(
                              color: isDarkMode
                                  ? Colors.white12
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Previous",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 4.sp,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? Colors.grey[800]
                                        : _accentColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                  onPressed: controller.previousQuestion,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Save & Next",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 4.sp,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _secondaryColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                  onPressed: () =>
                                      controller.nextQuestion(context),
                                ),
                                // --- Clear Button ---
                                ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Clear",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 4.sp,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                  onPressed: () => controller
                                      .clearQuestionWithWarning(question['id']),
                                ),
                                Obx(() {
                                  final marked = controller.markedForReview
                                      .contains(question['id']);
                                  return ElevatedButton.icon(
                                    icon: Icon(
                                      marked ? Icons.flag : Icons.outlined_flag,
                                      size: 15,
                                      color: marked
                                          ? Colors.white
                                          : (isDarkMode
                                                ? Colors.grey[300]
                                                : Colors.yellow),
                                    ),
                                    label: Text(
                                      marked ? "Unmark" : "Save & Mark Review",
                                      style: TextStyle(
                                        fontSize: 4.sp,
                                        color: marked
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: marked
                                          ? _accentColor
                                          : _primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          7.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 10.h,
                                      ),
                                      //  elevation: 0,
                                    ),
                                    onPressed:
                                        controller.markForReviewWithWarning,
                                  );
                                }),
                                Obx(() {
                                  final isTimeOver =
                                      controller.remainingSeconds.value <= 0;
                                  return ElevatedButton(
                                    onPressed: () => controller
                                        .showSubmitWarningLikeJeeMain(context),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 10.h,
                                      ),
                                      backgroundColor: _primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          isTimeOver
                                              ? "Time Up!"
                                              : "Submit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 4.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Question palette (right, grid style)
              Container(
                width: 100.w,
                margin: EdgeInsets.fromLTRB(4.w, 8.h, 8.w, 8.h),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white12
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: [
                    if (!isDarkMode)
                      const BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusLegend(
                      controller: controller,
                      isDarkMode: isDarkMode,
                      fs: fs,
                    ),
                    SizedBox(height: 16.h),
                    Divider(
                      thickness: 1,
                      color: isDarkMode
                          ? Colors.white12
                          : const Color(0xFFE5E7EB),
                    ),
                    Text(
                      "Question Palette",
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.grey[300] : _deepInk,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Obx(() {
                      final questions = controller.currentQuestions;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 2.1,
                        ),
                        itemCount: questions.length,
                        itemBuilder: (context, i) {
                          final q = questions[i];
                          return _buildPaletteBox(
                            i: i,
                            q: q,
                            controller: controller,
                            fs: fs,
                            isDarkMode: isDarkMode,
                          );
                        },
                      );
                    }),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
