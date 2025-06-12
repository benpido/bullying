bool isPhoneValid(String phone) {
  return RegExp(r'^\+?\d{7,15}$').hasMatch(phone);
}
