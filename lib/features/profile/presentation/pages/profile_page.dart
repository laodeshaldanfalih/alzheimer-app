import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/core/providers/auth_provider.dart';
import 'package:project/core/providers/user_profile_provider.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isEditing = false;
  File? _profileImage;
  final _picker = ImagePicker();

  // Controllers for editing fields
  late TextEditingController nameController;
  late TextEditingController ageController;
  String genderValue = '';
  DateTime? birthdate;

  // State variables for display mode
  String _displayName = '';
  String _displayAge = '';
  String _displayGender = '';
  String _displayBirthdate = '';

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource src) async {
    if (src == ImageSource.camera && !await _ensureCameraPermission()) {
      return _showSnack('Izin kamera ditolak');
    }
    try {
      final picked = await _picker.pickImage(
        source: src,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
          _validateForm();
        });
        // Save the image path to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', picked.path);
      }
    } catch (e) {
      _showSnack('Gagal memilih gambar: $e');
    }
  }

  Future<void> _removeProfilePicture() async {
    setState(() {
      _profileImage = null;
      _validateForm();
    });
    // Remove the saved image path from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
  }

  void _showProfilePictureOptions() => showModalBottomSheet(
    context: context,
    builder:
        (_) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfilePicture();
                  },
                ),
            ],
          ),
        ),
  );

  void _showSnack(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    nameController = TextEditingController();
    ageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authProvider);
      final userProfile = ref.read(userProfileProvider);

      if (user != null && userProfile == null && user.email != null) {
        ref.read(userProfileProvider.notifier).updateProfile(user.email!);
      }

      await _loadProfileData();
      // Load saved profile image
      final prefs = await SharedPreferences.getInstance();
      final savedImagePath = prefs.getString('profile_image_path');
      if (savedImagePath != null) {
        setState(() {
          _profileImage = File(savedImagePath);
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileData() async {
    if (_profileImage == null) {
      _showSnack('Foto profil harus diisi');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_profile', true);

    // Save all profile data
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_age', ageController.text);
    await prefs.setString('profile_gender', genderValue);
    if (birthdate != null) {
      await prefs.setString('profile_birthdate', birthdate!.toIso8601String());
    }

    // Update the UserProfile provider
    final user = ref.read(authProvider);
    if (user != null && user.email != null) {
      ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            user.email!,
            name: nameController.text,
            age: int.tryParse(ageController.text),
            gender: genderValue,
            birthdate: birthdate,
          );
    }

    // Update display values
    setState(() {
      _displayName = nameController.text;
      _displayAge = ageController.text;
      _displayGender = genderValue;
      _displayBirthdate =
          birthdate != null
              ? '${birthdate!.day.toString().padLeft(2, '0')} / ${birthdate!.month.toString().padLeft(2, '0')} / ${birthdate!.year}'
              : '';
      _isEditing = false;
    });
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasProfile = prefs.getBool('has_profile') ?? false;

    if (hasProfile) {
      // Load saved profile data
      final savedName = prefs.getString('profile_name') ?? '';
      final savedAge = prefs.getString('profile_age') ?? '';
      final savedGender = prefs.getString('profile_gender') ?? '';
      final birthdateStr = prefs.getString('profile_birthdate');

      nameController.text = savedName;
      ageController.text = savedAge;
      genderValue = savedGender;
      if (birthdateStr != null) {
        birthdate = DateTime.parse(birthdateStr);
      }

      // Update display values
      setState(() {
        _displayName = savedName;
        _displayAge = savedAge;
        _displayGender = savedGender;
        _displayBirthdate =
            birthdate != null
                ? '${birthdate!.day.toString().padLeft(2, '0')} / ${birthdate!.month.toString().padLeft(2, '0')} / ${birthdate!.year}'
                : '';
      });
    }

    if (mounted) {
      setState(() {
        _isEditing = !hasProfile;
      });
    }
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          nameController.text.isNotEmpty &&
          ageController.text.isNotEmpty &&
          genderValue.isNotEmpty &&
          birthdate != null &&
          _profileImage != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final userProfile = ref.watch(userProfileProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await authNotifier.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile picture with edit button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _isEditing && _profileImage == null
                                  ? Colors.red
                                  : Colors.black12,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: _isEditing ? _showProfilePictureOptions : null,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                          child:
                              _profileImage == null
                                  ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.grey[400],
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _showProfilePictureOptions,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_isEditing && _profileImage == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Foto profil harus diisi',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  _displayName.isEmpty ? '-' : _displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isEditing) ...[
                  // Info Profil Pasien Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE0E6ED), width: 1.4),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Info Profil Pasien',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Name
                          TextFormField(
                            controller: nameController,
                            onChanged: (_) => _validateForm(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama harus diisi';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nama',
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E6ED),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Age
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _validateForm(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Umur harus diisi';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Umur harus berupa angka';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Umur',
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E6ED),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2563EB),
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Gender
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField2<String>(
                              hint: const Text(
                                'Pilih Gender',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              isExpanded: true,
                              value: genderValue.isEmpty ? null : genderValue,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Gender harus dipilih';
                                }
                                return null;
                              },
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    genderValue = val;
                                    _validateForm();
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B8C1),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE0E6ED),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF8A94A6),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text(
                                    'Laki-laki',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1F2937),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text(
                                    'Perempuan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1F2937),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Birthdate
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: birthdate ?? DateTime(1950, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  birthdate = picked;
                                  _validateForm();
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                validator: (value) {
                                  if (birthdate == null) {
                                    return 'Tanggal lahir harus dipilih';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Lahir',
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 26,
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE0E6ED),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2563EB),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                                controller: TextEditingController(
                                  text:
                                      birthdate != null
                                          ? '${birthdate!.day.toString().padLeft(2, '0')} / ${birthdate!.month.toString().padLeft(2, '0')} / ${birthdate!.year}'
                                          : '',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFormValid
                                  ? const Color(0xff3866E6)
                                  : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            _isFormValid
                                ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_profileImage == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Foto profil harus diisi',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    // Save all changes
                                    await _saveProfileData();
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Perubahan disimpan!'),
                                        ),
                                      );
                                    }
                                  }
                                }
                                : null,
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Display profile info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE0E6ED), width: 1.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Info Profil Pasien',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildInfoRow('Nama', _displayName),
                        const SizedBox(height: 14),
                        _buildInfoRow('Umur', _displayAge),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          'Gender',
                          _displayGender == 'Male' ? 'Laki-laki' : 'Perempuan',
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow('Tanggal Lahir', _displayBirthdate),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Login info
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE0E6ED)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
