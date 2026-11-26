class UserModel {
  final int id;
  final String nim;
  final String nama;
  final String email;
  final String? token;

  const UserModel({
    required this.id,
    required this.nim,
    required this.nama,
    required this.email,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nim: json['nim']?.toString() ?? '-',
      nama: json['nama']?.toString() ?? 'Mahasiswa',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'nama': nama,
      'email': email,
      'token': token,
    };
  }
}
