
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/profile.dart';
import '../../repositories/interfaces/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _universityController;
  late final TextEditingController _majorController;
  late final TextEditingController _bioController;

  File? _selectedImage;
  int? _selectedSemester;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _nameController = TextEditingController(
      text: profile.fullName,
    );
    _phoneController = TextEditingController(
      text: profile.phone ?? '',
    );
    _universityController = TextEditingController(
      text: profile.university ?? '',
    );
    _majorController = TextEditingController(
      text: profile.major ?? '',
    );
    _bioController = TextEditingController(
      text: profile.bio ?? '',
    );

    _selectedSemester = profile.semester;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $error'),
        ),
      );
    }
  }

  Widget _buildAvatarPreview() {
    ImageProvider? imageProvider;

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else {
      final avatarUrl = widget.profile.avatarUrl;

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        if (avatarUrl.startsWith('http://') ||
            avatarUrl.startsWith('https://')) {
          imageProvider = NetworkImage(avatarUrl);
        } else if (!avatarUrl.startsWith('mock/')) {
          imageProvider = FileImage(File(avatarUrl));
        }
      }
    }

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.background,
            backgroundImage: imageProvider,
            onBackgroundImageError:
            imageProvider == null ? null : (_, _) {},
            child: imageProvider == null
                ? const Icon(
              Icons.person,
              size: 55,
              color: AppColors.primary,
            )
                : null,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _isSaving ? null : _pickAvatar,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Ubah Foto Profil'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ambil repository sebelum proses async dimulai.
    final profileRepository = context.read<ProfileRepository>();

    setState(() {
      _isSaving = true;
    });

    try {
      String? avatarUrl = widget.profile.avatarUrl;

      if (_selectedImage != null) {
        final uploadedPath = await profileRepository.uploadAvatar(
          _selectedImage!,
        );

        // Mock mengembalikan path simulasi.
        // Untuk preview, gunakan path file lokal yang asli.
        avatarUrl = uploadedPath.startsWith('mock/')
            ? _selectedImage!.path
            : uploadedPath;
      }

      final updatedProfile = Profile(
        id: widget.profile.id,
        role: widget.profile.role,
        fullName: _nameController.text.trim(),
        email: widget.profile.email,
        phone: _phoneController.text.trim(),
        avatarUrl: avatarUrl,
        university: _universityController.text.trim(),
        major: _majorController.text.trim(),
        semester: _selectedSemester,
        bio: _bioController.text.trim(),
        verificationStatus: widget.profile.verificationStatus,
        verificationNote: widget.profile.verificationNote,
      );

      final result = await profileRepository.updateProfile(
        updatedProfile,
      );

      if (!mounted) return;

      Navigator.pop(context, result);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.button,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semester',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _selectedSemester,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
          hint: const Text('Pilih semester'),
          items: List.generate(14, (index) => index + 1)
              .map(
                (semester) => DropdownMenuItem<int>(
              value: semester,
              child: Text('Semester $semester'),
            ),
          )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSemester = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            _buildAvatarPreview(),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Nama Lengkap',
              controller: _nameController,
              hint: 'Masukkan nama lengkap',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama lengkap wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            _buildTextField(
              label: 'Nomor Telepon',
              controller: _phoneController,
              hint: 'Masukkan nomor telepon',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),

            _buildTextField(
              label: 'Universitas',
              controller: _universityController,
              hint: 'Masukkan nama universitas',
            ),
            const SizedBox(height: 18),

            _buildTextField(
              label: 'Jurusan',
              controller: _majorController,
              hint: 'Masukkan jurusan',
            ),
            const SizedBox(height: 18),

            _buildSemesterDropdown(),
            const SizedBox(height: 18),

            _buildTextField(
              label: 'Bio',
              controller: _bioController,
              hint: 'Ceritakan sedikit tentang dirimu',
              maxLines: 4,
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
