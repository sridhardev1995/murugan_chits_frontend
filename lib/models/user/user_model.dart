class UserModel {
  bool? success;
  String? message;
  String? token;
  Admin? admin;

  UserModel({this.success, this.message, this.token, this.admin});

  UserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    token = json['token'];
    admin = json['admin'] != null ? Admin.fromJson(json['admin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['token'] = token;
    if (admin != null) {
      data['admin'] = admin!.toJson();
    }
    return data;
  }
}

class Admin {
  int? id;
  String? username;

  Admin({this.id, this.username});

  Admin.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    return data;
  }
}
