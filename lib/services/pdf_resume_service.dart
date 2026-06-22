import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PDFResumeService {

  Future<Uint8List> generateResumePDF({

    required String name,
    required String email,
    required String phone,
    required String summary,
    required List<String> skills,
    required List<String> projects,

  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.MultiPage(

        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
        ),

        build: (context) => [

          pw.Text(
            name,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(email),
          pw.Text(phone),

          pw.SizedBox(height: 25),

          pw.Text(
            "Professional Summary",
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(summary),

          pw.SizedBox(height: 25),

          pw.Text(
            "Skills",
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children:
                skills.map(
                  (skill) => pw.Bullet(
                    text: skill.trim(),
                  ),
                ).toList(),
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Projects",
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children:
                projects.map(
                  (project) => pw.Bullet(
                    text: project.trim(),
                  ),
                ).toList(),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}