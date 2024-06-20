class UserProfile {
  String imageUrl;
  String name;
  String surname;
  String mobileNumber;

  UserProfile(
      {this.imageUrl = '',
      this.name = '',
      this.surname = '',
      this.mobileNumber = ''});

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'surname': surname,
      'mobileNumber': mobileNumber,
    };
  }
}
