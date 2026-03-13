import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gold_app/controllers/resultcontroller.dart';

class Resultview extends GetView<ResultController> {
  int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F8F8);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Assignment Result Sheet', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade800,
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final result = controller.resultModel.value;
        final dataList = result?.data ?? [];
        if (dataList.isEmpty) {
          return Center(
            child: Text(
              'No result data available',
              style: TextStyle(color: textColor),
            ),
          );
        }
        final student = dataList.first;
        final totalMarks = _asInt(student.totalQueMarks);
        final obtainedMarks = _asInt(student.totalCorrectMarks);
        final incorrectMarks = (totalMarks - obtainedMarks).clamp(0, totalMarks);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Name: ${controller.name.value.replaceAll('"', '').trim() ?? "-"}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subject: ${student.subjectName ?? "-"}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Exam/Test ID: ${student.testId ?? "-"}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${student.examDate ?? "-"}',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AssignmentStat(
                        title: 'Total Marks',
                        value: totalMarks.toString(),
                        isDark: isDark,
                      ),
                      _AssignmentStat(
                        title: 'Obtained',
                        value: obtainedMarks.toString(),
                        isDark: isDark,
                      ),
                      _AssignmentStat(
                        title: 'Incorrect',
                        value: incorrectMarks.toString(),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(isDark ? 0.2 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      isDark ? Colors.blueGrey.shade900 : Colors.blueGrey.shade100,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) =>
                          isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Q#',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Question',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Your Answer',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Correct',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Marks',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                    rows: [
                      for (int i = 0; i < dataList.length; i++)
                        DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) =>
                                i % 2 == 0
                                    ? (isDark ? Colors.grey.shade800 : Colors.grey.shade50)
                                    : cardColor,
                          ),
                          cells: [
                            DataCell(
                              Text(
                                '${i + 1}',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            DataCell(
                              Text(
                                dataList[i].questions ?? '-',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            DataCell(
                              Text(
                                dataList[i].choiceOptionText ?? '-',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            DataCell(
                              Icon(
                                (dataList[i].optionStatus == 'Correct')
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: (dataList[i].optionStatus == 'Correct')
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                            ),
                            DataCell(
                              Text(
                                '${dataList[i].questionMarks ?? '-'}',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _AssignmentStat extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;
  const _AssignmentStat({
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Color.fromARGB(255, 182, 201, 210) : Color.fromARGB(255, 182, 201, 210)
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String title;
  final String value;
  const _ResultStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}

class _ResultDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}