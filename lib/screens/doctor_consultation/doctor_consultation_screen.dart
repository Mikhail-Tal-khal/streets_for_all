
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/providers/connectivity_provider.dart';
import 'package:diabetes_test/widgets/offline_banner.dart';
import 'package:diabetes_test/constants/doctor_data.dart';
import 'package:diabetes_test/models/doctor.dart';
import 'package:diabetes_test/widgets/doctor_card.dart';
import 'package:diabetes_test/widgets/emergency_section.dart';
import 'package:diabetes_test/widgets/message_dialog.dart';
import 'package:diabetes_test/services/doctor_consultation_service.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key});

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleCallDoctor(Doctor doctor) async {
    final success = await DoctorConsultationService.initiateCall(doctor.phoneNumber);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch the phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSendMessage(Doctor doctor) async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userAuth = Provider.of<UserAuthProvider>(context, listen: false);
      final userId = userAuth.userId ?? '';
      
      final success = await DoctorConsultationService.sendMessage(
        doctorId: doctor.id,
        userId: userId,
        message: _messageController.text.trim(),
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _messageController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmergencyAlert() async {
    setState(() => _isLoading = true);

    try {
      final userAuth = Provider.of<UserAuthProvider>(context, listen: false);
      final userId = userAuth.userId ?? '';
      
      final success = await DoctorConsultationService.sendEmergencyAlert(
        userId: userId,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency alert sent to all available doctors'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send emergency alert'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending emergency alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCallEmergencyServices() async {
    final success = await DoctorConsultationService.initiateCall('911');
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch emergency call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMessageDialog(Doctor doctor) {
    MessageDialog.show(
      context: context,
      doctor: doctor,
      messageController: _messageController,
      onSendPressed: () => _handleSendMessage(doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ConnectivityProvider>(context);
    final doctors = DoctorData.availableDoctors;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Consultation'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to consultation history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Consultation history coming soon'),
                ),
              );
            },
            tooltip: 'Consultation History',
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: EmergencySection(
                          onSendAlertPressed: _handleEmergencyAlert,
                          onCallEmergencyPressed: _handleCallEmergencyServices,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Available Doctors',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => DoctorCard(
                            doctor: doctors[index],
                            onMessagePressed: () => _showMessageDialog(doctors[index]),
                            onCallPressed: () => _handleCallDoctor(doctors[index]),
                          ),
                          childCount: doctors.length,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}