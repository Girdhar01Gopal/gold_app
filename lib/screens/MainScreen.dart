// screens/MainScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/MainScreenController.dart';
import '../infrastructure/app_drawer/admin_drawer2.dart';

class MainScreen extends StatelessWidget {
  final MainScreenController controller = Get.put(MainScreenController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true);

    return Scaffold(
      drawer: AdminDrawer2(),
      appBar: AppBar(
        title: Text('NITO', style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.notes, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Image.asset('assets/images/FIITJEE_Logo.png', width: 45.w, height: 45.h),
          ),
        ],
      ),

      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buckets Row
                SizedBox(
                  height: 60.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.buckets.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, i) {
                      final bucket = controller.buckets[i];
                      final isSelected = controller.selectedBucket.value == bucket.title;

                      return GestureDetector(
                        onTap: () => controller.selectBucket(bucket.title),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade400, width: 2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.folder_open, color: Colors.blue[900], size: 18.sp),
                              SizedBox(width: 6.w),
                              Text(bucket.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 700;
                    return isNarrow
                        ? Column(children: [_buildLeftSide(), SizedBox(height: 20.h), _buildRightSide()])
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: _buildLeftSide()),
                        SizedBox(width: 30.w),
                        Expanded(flex: 1, child: _buildRightSide()),
                      ],
                    );
                  },
                ),

                SizedBox(height: 20.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(10.r)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Version 7.0', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                      Text('FIITJEE', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // LEFT SIDE
  Widget _buildLeftSide() {
    final controller = Get.find<MainScreenController>();

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.blueAccent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Tests', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blue[900])),
          SizedBox(height: 10.h),
          SizedBox(
            height: 170.h,
            child: Obx(() => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.filteredItems.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final item = controller.filteredItems[index];
                return GestureDetector(
                  onTap: () => controller.onTestCardSelected(item),
                  child: Container(
                    width: 180.w,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Test ID: ${item.testId}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900], fontSize: 16.sp)),
                        Text(item.details, style: TextStyle(fontSize: 14.sp)),
                        Text("Status: ${item.status}", style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(item.status))),
                        Text("From: ${item.openFrom}", style: TextStyle(fontSize: 12.sp)),
                        Text("Till: ${item.openTill}", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  // RIGHT SIDE
  Widget _buildRightSide() {
    final controller = Get.find<MainScreenController>();
    return Obx(() => Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.black),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Download Test", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 18.sp)),
          SizedBox(height: 10.h),

          _colorRow("Open Test", Colors.green),
          _colorRow("Closed Test", Colors.red),
          _colorRow("Analysis", Colors.purple),
          _colorRow("Yet to Open", Colors.orange),

          SizedBox(height: 10.h),
          const Text("Enter Details", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),

          TextField(
            controller: TextEditingController(text: controller.selectedTestId.value),
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Test ID",
              filled: true,
              fillColor: Colors.yellow[300],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),

          SizedBox(height: 8.h),
          TextField(
            decoration: InputDecoration(
              hintText: "Passcode",
              filled: true,
              fillColor: Colors.yellow[300],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isDownloadEnabled.value ? controller.onDownloadPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.downloadButtonColor.value,
                disabledBackgroundColor: controller.downloadButtonColor.value.withOpacity(0.6),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text(controller.downloadButtonText.value,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // 🟢 New: Details Below Button
          if (controller.selectedTestId.value.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade400),
            Text("Details: ${controller.selectedDetails.value}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            Text("Maximum Marks: ${controller.selectedMarks.value}", style: TextStyle(fontSize: 14.sp)),
            Text("Duration: ${controller.selectedDuration.value} mins", style: TextStyle(fontSize: 14.sp)),
          ],
        ],
      ),
    ));
  }

  Widget _colorRow(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(width: 12.w, height: 12.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open test':
        return Colors.green;
      case 'closed test':
        return Colors.red;
      case 'analysis':
        return Colors.purple;
      case 'yet to open':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
