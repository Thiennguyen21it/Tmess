import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // saving the data to SF

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  // getting the data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
}

//setting provider upload avatar image to firebase storage
 
// class SettingProvider {
//   final SharedPreferences prefs;
//   final FirebaseFirestore firebaseFirestore;
//   final FirebaseStorage firebaseStorage;

//   SettingProvider({
//     required this.prefs,
//     required this.firebaseFirestore,
//     required this.firebaseStorage,
//   });

//   String? getPref(String key) {
//     return prefs.getString(key);
//   }

//   Future<bool> setPref(String key, String value) async {
//     return await prefs.setString(key, value);
//   }

//   UploadTask uploadFile(File image, String fileName) {
//     Reference reference = firebaseStorage.ref().child(fileName);
//     UploadTask uploadTask = reference.putFile(image);
//     return uploadTask;
//   }

//   Future<void> updateDataFirestore(
//       String collectionPath, String path, Map<String, String> dataNeedUpdate) {
//     return firebaseFirestore
//         .collection(collectionPath)
//         .doc(path)
//         .update(dataNeedUpdate);
//   }
// }
