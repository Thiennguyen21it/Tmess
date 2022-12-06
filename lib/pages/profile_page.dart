import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tmess_app/helper/helper_function.dart';
import 'package:tmess_app/service/auth_service.dart';
import 'package:tmess_app/service/database_service.dart';
import '../widgets/common_button.dart';
import '../widgets/select_photo_options_screen.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';
import 'home_page.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  String uid;

  ProfilePage({
    Key? key,
    required this.email,
    required this.userName,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profilePic; //image file pick from gallery and camera
  String? downloadUrl;
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();
  bool isLoading = false;
  String imageURL =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT73s9z2T_I9BOpGKQpuOL2s8ZCNLNwAnmiFb-5Rjky8-nhfNltVnKKKSdRfsmYQQIwkzQ&usqp=CAU";

  // pick image function
  Future _pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _profilePic = img;
        HelperFunctions.saveImageSF(_profilePic!.path);
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // crop image function
  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  // upload image function, then getting download url
  // and then saving the url to the storage
  Future uploadImage() async {
    final postID = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${widget.userName}/profilePic")
        .child("post_$postID");
    await ref.putFile(_profilePic!);
    downloadUrl =
        await ref.getDownloadURL(); // change image file into string url

    //  image file into string url and save at cloud firestore as profilePic
    await firebaseFirestore
        .collection("users")
        .doc(widget.uid)
        .update({"profilePic": downloadUrl});
  }

// get image from cloud firestore
  getImageFromFireStore(width, height) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return CachedNetworkImage(
            imageUrl: snapshot.data["profilePic"],
            imageBuilder: (context, imageProvider) => Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    uploadImage();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            //avatar
            isLoading == false
                ? CachedNetworkImage(
                    imageUrl: imageURL,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Container(
                    child: _profilePic == null
                        ? getImageFromFireStore(150.0, 150.0)
                        : CircleAvatar(
                            backgroundImage: FileImage(_profilePic!),
                            radius: 70,
                          ),
                  ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                nextScreen(context, const HomePage());
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _showSelectPhotoOptions(context);
                    },
                    child: Center(
                      child: Center(
                        child: _profilePic == null
                            ? getImageFromFireStore(300.0, 300.0)
                            : CircleAvatar(
                                backgroundImage: FileImage(_profilePic!),
                                radius: 150,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      _showSelectPhotoOptions(context);
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                    child: Row(
                      children: const [
                        Icon(Icons.get_app),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Pick image "),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {},
                    style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                    child: Row(
                      children: const [
                        Icon(Icons.refresh),
                        SizedBox(width: 10),
                        Text("Refresh"),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Full Name :", style: TextStyle(fontSize: 17)),
                  Text(widget.userName, style: const TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Email :", style: TextStyle(fontSize: 17)),
                  Text(widget.email, style: const TextStyle(fontSize: 17)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  CommonButtons(
                    onTap: () async {
                      await uploadImage().whenComplete(() => downloadUrl == null
                          ? showSnackbar(
                              context, Colors.red, "No image to upload")
                          : showSnackbar(context, Colors.green,
                              "Profile Picture Updated"));
                    },
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    textLabel: 'Upload Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }
}
