class ContactModel {
  final String name;
  final String phoneNumber;

  ContactModel({required this.name, required this.phoneNumber});

  // Método para converter de objeto para JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'phoneNumber': phoneNumber};
  }

  // Método para converter de JSON para objeto
  static ContactModel fromJson(Map<String, dynamic> json) {
    return ContactModel(name: json['name'], phoneNumber: json['phoneNumber']);
  }
}
