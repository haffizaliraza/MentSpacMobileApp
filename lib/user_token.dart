class UserToken {
  final int id;
  final String email;
  final bool showAddress;
  final String? address;
  final String? city;
  final String authToken;
  final String firstName;
  final String lastName;
  final String postUsername;
  final String imageUrl;

  UserToken({
    required this.id,
    required this.email,
    required this.showAddress,
    this.address,
    this.city,
    required this.authToken,
    required this.firstName,
    required this.lastName,
    required this.postUsername,
    required this.imageUrl,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    return UserToken(
      id: json['id'],
      email: json['email'],
      showAddress: json['show_address'],
      address: json['address'],
      city: json['city'],
      authToken: json['auth_token'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      postUsername: json['post_username'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'show_address': showAddress,
      'address': address,
      'city': city,
      'auth_token': authToken,
      'first_name': firstName,
      'last_name': lastName,
      'post_username': postUsername,
      'image_url': imageUrl,
    };
  }
}
