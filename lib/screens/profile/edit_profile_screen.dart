import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';
import 'package:ai_careerpilot/config/app_theme_extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();
  final skillsController = TextEditingController();
  final careerGoalController = TextEditingController();

  bool loading = true;
  bool saving = false;

  String profileImage = "";
  Uint8List? _localImageBytes;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data() ?? {};

    nameController.text = data["name"] ?? "";
    phoneController.text = data["phone"] ?? "";
    locationController.text = data["location"] ?? "";
    educationController.text = data["education"] ?? "";
    experienceController.text = data["experience"] ?? "";
    careerGoalController.text = data["careerGoal"] ?? "";

    skillsController.text = (data["skills"] ?? []).join(", ");

    profileImage = data["profileImage"] ?? "";

    setState(() => loading = false);
  }

  bool imageUploading = false;
  double uploadProgress = 0.0;

  Future<void> pickImage() async {
    try {
      debugPrint(">>> [PROFILE IMAGE] Starting image selection...");
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Built-in picker compression
      );

      if (picked == null) {
        debugPrint(">>> [PROFILE IMAGE] Image selection cancelled by user.");
        return;
      }

      if (user == null) {
        throw Exception("Authentication error: User is not logged in.");
      }

      setState(() {
        imageUploading = true;
        uploadProgress = 0.0;
      });

      debugPrint(">>> [PROFILE IMAGE] Reading file into bytes...");
      final bytes = await picked.readAsBytes();
      
      setState(() {
        _localImageBytes = bytes;
      });

      debugPrint(">>> [PROFILE IMAGE] Image read into memory. Size: ${bytes.length} bytes (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB).");
      debugPrint(">>> [PROFILE IMAGE] Starting Firebase Storage upload...");

      final ref = FirebaseStorage.instance
          .ref()
          .child("users")
          .child(user!.uid)
          .child("profile.jpg");

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      
      Future<void> attemptUpload() async {
        UploadTask uploadTask = ref.putData(bytes, metadata);
        
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          debugPrint(">>> [PROFILE IMAGE] Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
          if (mounted) {
            setState(() {
              uploadProgress = progress;
            });
          }
        });

        await uploadTask;
      }

      try {
        await attemptUpload();
      } catch (e) {
        debugPrint(">>> [PROFILE IMAGE] First upload attempt failed: $e. Retrying...");
        await attemptUpload();
      }

      debugPrint(">>> [PROFILE IMAGE] Firebase Storage upload completed successfully.");
      debugPrint(">>> [PROFILE IMAGE] Fetching download URL...");

      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint(">>> [PROFILE IMAGE] Download URL retrieved: $downloadUrl");
      debugPrint(">>> [PROFILE IMAGE] Saving URL to Firestore...");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .set({"profileImage": downloadUrl}, SetOptions(merge: true));

      debugPrint(">>> [PROFILE IMAGE] Firestore updated with new profile image URL.");

      setState(() {
        profileImage = downloadUrl;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile image updated successfully!", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Theme.of(context).extension<AppThemeExtension>()!.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      debugPrint(">>> [PROFILE IMAGE] FAILED! Exact Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image upload failed: $e", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          imageUploading = false;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    setState(() => saving = true);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({
      "name": nameController.text.trim(),
      "profileImage": profileImage,
      "phone": phoneController.text.trim(),
      "location": locationController.text.trim(),
      "education": educationController.text.trim(),
      "experience": experienceController.text.trim(),
      "careerGoal": careerGoalController.text.trim(),
      "skills": skillsController.text
          .split(",")
          .map((e) => e.trim())
          .toList(),
    }, SetOptions(merge: true));

    setState(() => saving = false);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 20,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Profile image editable circle
                GestureDetector(
                  onTap: imageUploading ? null : pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white12,
                          backgroundImage: _localImageBytes != null
                              ? MemoryImage(_localImageBytes!) as ImageProvider
                              : (profileImage.isNotEmpty
                                  ? CachedNetworkImageProvider(profileImage)
                                  : null),
                          child: _localImageBytes == null && profileImage.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 55,
                                  color: Colors.white60,
                                )
                              : null,
                        ),
                      ),
                      if (imageUploading)
                        Container(
                          width: 108,
                          height: 108,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: uploadProgress > 0 ? uploadProgress : null,
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(uploadProgress * 100).toInt()}%",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      if (!imageUploading)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form fields
                CustomTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: locationController,
                  hintText: "Location",
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: educationController,
                  hintText: "Education",
                  prefixIcon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: experienceController,
                  hintText: "Experience",
                  prefixIcon: Icons.work_outline_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: skillsController,
                  hintText: "Skills (comma separated, Ex: Dart, Python)",
                  prefixIcon: Icons.code_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: careerGoalController,
                  hintText: "Career Goal (Ex: Senior Flutter Developer)",
                  prefixIcon: Icons.track_changes_rounded,
                ),

                const SizedBox(height: 36),

                // Save button
                PrimaryButton(
                  text: "Save Profile Changes",
                  isLoading: saving,
                  onPressed: saveProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
