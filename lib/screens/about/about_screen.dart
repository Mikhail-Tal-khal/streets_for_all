import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Diabetes Detection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Our Mission',
              content: 'To provide accessible and early detection of diabetes through innovative technology, helping people maintain better health through preventive care.',
            ),
            _buildSection(
              title: 'How It Works',
              content: 'Our app uses advanced computer vision technology to analyze eye patterns and detect potential signs of diabetes. This non-invasive method is based on scientific research linking eye characteristics to blood glucose levels.',
            ),
            _buildSection(
              title: 'Important Notice',
              content: 'This app is designed as a screening tool and should not replace professional medical diagnosis. Always consult with healthcare professionals for proper medical advice and treatment.',
            ),
            _buildSection(
              title: 'Research Background',
              content: 'Our technology is based on peer-reviewed research studying the relationship between ocular characteristics and diabetes. The app uses machine learning models trained on extensive clinical data.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}