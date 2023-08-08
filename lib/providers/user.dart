import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';
import '../models/theme_model.dart';



class UserProvider {
  late SharedPreferences prefs;
  SettingsProvider settings;
  final DarkThemeProvider theme;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  UserProvider({required this.settings, required this.theme});

  fromJson(Map<String, dynamic> json) {
    theme.fromJson(json['theme']);
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings.toJson(),
      'theme': theme.toJson(),
    };
  }

  void saveToFirestore() async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set(toJson());

    } catch (e) {
      print(e);
    }
  }

  void loadFromFirestoreOrCreate() async {
    var result =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    if (result.exists) {
      fromJson(result.data()!);
    } else {
      saveToFirestore();
    }
  }
}
