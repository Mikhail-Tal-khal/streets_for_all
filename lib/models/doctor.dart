class Doctor {
  final String id;
  final String name;
  final String specialty;
  final bool isAvailable;
  final String imageUrl;
  final double rating;
  final String phoneNumber;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.isAvailable,
    required this.imageUrl,
    required this.rating,
    required this.phoneNumber,
  });
}