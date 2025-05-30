import 'package:finance_management/data/model/user/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) return true;
    if (await Permission.photos.isGranted) return true;
    if (await Permission.mediaLibrary.isGranted) return true;
    if (await Permission.storage.request().isGranted) return true;
    if (await Permission.photos.request().isGranted) return true;
    if (await Permission.mediaLibrary.request().isGranted) return true;
    return false;
  }
  return true; // iOS không cần
}

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  // Only for demo/offline
  final List<UserModel> userData = [];

  // Get user by ID (Firestore only)
  Future<UserModel?> getUserById(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserModel(
        id: id,
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        mobile: data['mobile'] ?? '',
        dob: data['dob'] ?? '',
        password: data['password'] ?? '',
        avatarPath: data['avatarPath'],
        helper: data['helper'] ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by email and password (Firestore only)
  Future<UserModel?> getUserByCredentials(String email, String password) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .where('password', isEqualTo: password)
              .limit(1)
              .get();
      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      final data = doc.data();
      return UserModel(
        id: doc.id,
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        mobile: data['mobile'] ?? '',
        dob: data['dob'] ?? '',
        password: data['password'] ?? '',
        avatarPath: data['avatarPath'],
        helper: data['helper'] ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  // Add new user (Firestore only)
  Future<UserModel> addUser(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set({
      'fullName': user.fullName,
      'email': user.email,
      'mobile': user.mobile,
      'dob': user.dob,
      'password': user.password,
      'avatarPath': user.avatarPath,
      'helper': user.helper,
    });
    return user;
  }

  // Edit user (Firestore only)
  Future<UserModel?> editUser(String id, UserModel updatedUser) async {
    // Request storage permission (support Android 13+)
    bool granted = await requestStoragePermission();
    if (!granted) {
      return null;
    }
    // Upload avatar to Firebase Storage if needed
    if (updatedUser.avatarPath != null &&
        !updatedUser.avatarPath!.startsWith('http')) {
      try {
        final file = File(updatedUser.avatarPath!);
        final fileExists = await file.exists();
        if (!fileExists) {
          return null;
        }
        final ref = FirebaseStorage.instance.ref().child('avatars/$id.jpg');
        // Upload file with metadata
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': id},
        );
        await ref.putFile(file, metadata);
        final url = await ref.getDownloadURL();
        updatedUser = updatedUser.copyWith(avatarPath: url);
      } catch (e) {
        return null;
      }
    }
    // Update Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'fullName': updatedUser.fullName,
        'email': updatedUser.email,
        'mobile': updatedUser.mobile,
        'dob': updatedUser.dob,
        'password': updatedUser.password,
        'avatarPath': updatedUser.avatarPath,
        'helper': updatedUser.helper,
      });
      return updatedUser;
    } catch (e) {
      return null;
    }
  }

  // Delete user (Firestore only)
  Future<bool> deleteUser(String id) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if email exists (Firestore only)
  Future<bool> isEmailExists(String email) async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }
}
