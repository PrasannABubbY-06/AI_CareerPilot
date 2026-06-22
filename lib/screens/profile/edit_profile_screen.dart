import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/primary_button.dart';

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

  bool loading = true;
  bool saving = false;

  String profileImage = "";

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

    skillsController.text = (data["skills"] ?? []).join(", ");

    profileImage = data["profileImage"] ?? "";

    setState(() => loading = false);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() => saving = true);

    try {
      final file = File(picked.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user!.uid}.jpg");

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        profileImage = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image upload failed: $e", style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => saving = false);
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
        backgroundColor: AppColors.scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
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
                    color: AppColors.primary.withOpacity(0.05),
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
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white12,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : null,
                          child: profileImage.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 55,
                                  color: Colors.white60,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
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
