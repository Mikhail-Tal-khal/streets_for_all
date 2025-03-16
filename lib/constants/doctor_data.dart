import '../models/doctor.dart';

class DoctorData {
  static final List<Doctor> availableDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialty: 'Endocrinologist',
      isAvailable: true,
      imageUrl: 'assets/images/doctor1.jpeg',
      rating: 4.9,
      phoneNumber: '+1234567890',
    ),
    Doctor(
      id: '2',
      name: 'Dr. Robert Chen',
      specialty: 'Diabetologist',
      isAvailable: true,
      imageUrl: 'assets/images/doctor2.jpeg',
      rating: 4.7,
      phoneNumber: '+1987654321',
    ),
    Doctor(
      id: '3',
      name: 'Dr. Emily Wilson',
      specialty: 'General Practitioner',
      isAvailable: false,
      imageUrl: 'assets/images/doctor3.jpeg',
      rating: 4.5,
      phoneNumber: '+1567891234',
    ),
    Doctor(
      id: '4',
      name: 'Dr. Michael Lee',
      specialty: 'Endocrinologist',
      isAvailable: true,
      imageUrl: 'assets/images/doctor4.jpeg',
      rating: 4.8,
      phoneNumber: '+1654789321',
    ),
  ];
}
