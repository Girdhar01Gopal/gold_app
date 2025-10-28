import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Item {
  final String testId;
  final String details;
  final String openFrom;
  final String openTill;
  final String status;
  final int maxMarks;
  final int duration; // in minutes

  Item({
    required this.testId,
    required this.details,
    required this.openFrom,
    required this.openTill,
    required this.status,
    this.maxMarks = 180,
    this.duration = 180,
  });

  DateTime? get openFromDate => _parseDate(openFrom);
  DateTime? get openTillDate => _parseDate(openTill);

  static DateTime? _parseDate(String s) {
    if (s.trim().isEmpty) return null;
    try {
      return DateFormat('dd MMM yyyy').parseStrict(s);
    } catch (_) {
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }
  }
}

class Bucket {
  final String title;
  final List<Item> items;
  Bucket(this.title, this.items);
}

class MainScreenController extends GetxController {
  final RxList<Item> items = <Item>[
    Item(testId: '677232', details: 'Special exam', openFrom: '08 Oct 2025', openTill: '30 Oct 2025', status: 'Open Test'),
    Item(testId: '669636', details: 'Kinematics', openFrom: '07 Oct 2025', openTill: '30 Oct 2025', status: 'Open Test'),
    Item(testId: '670885', details: 'Laws of Motion', openFrom: '02 Jul 2025', openTill: '25 Jun 2025', status: 'Closed Test'),
    Item(testId: '668148', details: 'Goal Settings BEGINNER ENGINEERING', openFrom: '16 Apr 2025', openTill: '21 Apr 2025', status: 'Yet to Open'),
    Item(testId: '669482', details: 'Stoichiometry', openFrom: '06 Jun 2025', openTill: '06 Jun 2025', status: 'Analysis'),
  ].obs;

  final RxList<Bucket> buckets = <Bucket>[].obs;
  final RxList<Item> filteredItems = <Item>[].obs;
  final RxString selectedBucket = ''.obs;

  // 🟢 Added reactive fields for “Download Test” box
  final RxString selectedTestId = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString selectedDetails = ''.obs;
  final RxInt selectedMarks = 0.obs;
  final RxInt selectedDuration = 0.obs;

  final RxBool isDownloadEnabled = false.obs;
  final RxString downloadButtonText = 'Download'.obs;
  final Rx<Color> downloadButtonColor = (Colors.blue[900]!).obs;

  @override
  void onInit() {
    super.onInit();
    _recompute();
  }

  void _recompute() {
    final now = DateTime.now();
    final recent = <Item>[];
    final sixMonthOld = <Item>[];
    final oneYearOld = <Item>[];
    final twoYearOld = <Item>[];

    for (var item in items) {
      final date = item.openFromDate;
      if (date == null) continue;
      final diff = now.difference(date).inDays;
      if (diff <= 30) {
        recent.add(item);
      } else if (diff <= 180) {
        sixMonthOld.add(item);
      } else if (diff <= 365) {
        oneYearOld.add(item);
      } else {
        twoYearOld.add(item);
      }
    }

    buckets.assignAll([
      Bucket('Most Recent', recent),
      Bucket('Six Months Old', sixMonthOld),
      Bucket('One Year Old', oneYearOld),
      Bucket('Two Years Old', twoYearOld),
    ]);

    filteredItems.assignAll(items);
  }

  void selectBucket(String bucketTitle) {
    selectedBucket.value = bucketTitle;
    final selected = buckets.firstWhereOrNull((b) => b.title == bucketTitle);
    filteredItems.assignAll(selected?.items ?? items);
  }

  // 🟢 When a test card is clicked
  void onTestCardSelected(Item item) {
    selectedTestId.value = item.testId;
    selectedStatus.value = item.status;
    selectedDetails.value = item.details;
    selectedMarks.value = item.maxMarks;
    selectedDuration.value = item.duration;

    switch (item.status.toLowerCase()) {
      case 'open test':
        isDownloadEnabled.value = true;
        downloadButtonText.value = 'Download Test';
        downloadButtonColor.value = Colors.green;
        break;
      case 'closed test':
        isDownloadEnabled.value = false;
        downloadButtonText.value = 'Test Closed';
        downloadButtonColor.value = Colors.red;
        break;
      case 'analysis':
        isDownloadEnabled.value = true;
        downloadButtonText.value = 'View Analysis';
        downloadButtonColor.value = Colors.purple;
        break;
      case 'yet to open':
        isDownloadEnabled.value = false;
        downloadButtonText.value = 'Yet to Open';
        downloadButtonColor.value = Colors.orange;
        break;
      default:
        isDownloadEnabled.value = false;
        downloadButtonText.value = 'Unavailable';
        downloadButtonColor.value = Colors.grey;
    }
  }

  void onDownloadPressed() {
    print("Download pressed for Test ID: ${selectedTestId.value}");
  }
}
