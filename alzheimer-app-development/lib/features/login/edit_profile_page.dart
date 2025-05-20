import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Import provider Anda
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/features/login/auth_provider.dart';
import 'package:project/features/login/user_profile_provider.dart';
// Hapus import signin_page.dart jika tidak digunakan di sini

class EditProfilePage extends ConsumerStatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  bool _isUpdatingEmail = false;
  bool _isNewEmailFieldValid = false;

  File? _profileImageFile;
  String? _profileImageUrlFromNetwork;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _patientPhoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _newEmailController;

  String _genderValue = '';
  DateTime? _birthDate;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  String? _linkingVerificationId;
  bool _isLinkingPhone = false; // State untuk loading khusus phone linking
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text:
          widget.userProfile.name ??
          _firebaseAuth.currentUser?.displayName ??
          '',
    );
    _ageController = TextEditingController();
    _phoneNumberController = TextEditingController(
      text:
          widget.userProfile.phone ??
          _firebaseAuth.currentUser?.phoneNumber ??
          '',
    );
    _patientPhoneNumberController = TextEditingController(
      text: widget.userProfile.patientPhone ?? '',
    );

    // _emailController untuk menampilkan email akun saat ini yang tersimpan di Firestore/Auth
    // Jika userProfile.email kosong (misal baru daftar via telepon), fallback ke authUser.email
    _emailController = TextEditingController(
      text:
          widget.userProfile.email.isNotEmpty
              ? widget.userProfile.email
              : (_firebaseAuth.currentUser?.email ?? ''),
    );
    _newEmailController = TextEditingController();

    _genderValue = widget.userProfile.gender ?? '';
    _birthDate = widget.userProfile.birthDate;
    _profileImageUrlFromNetwork =
        widget.userProfile.photoUrl ?? _firebaseAuth.currentUser?.photoURL;

    _updateAgeDisplay();

    _newEmailController.addListener(_validateNewEmailField);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
      _newEmailController.addListener(() {
        // Listener untuk field email baru
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    _patientPhoneNumberController.dispose();
    _emailController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();

    _newEmailController.removeListener(
      _validateNewEmailField,
    ); // Hapus listener
    super.dispose();
  }

  void _showSnackBar(
    String message, {
    bool isError = true,
    Color? backgroundColor,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              backgroundColor ?? (isError ? Colors.red : Colors.green),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateAgeDisplay() {
    if (_birthDate != null) {
      final now = DateTime.now();
      int age = now.year - _birthDate!.year;
      if (now.month < _birthDate!.month ||
          (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
        age--;
      }
      _ageController.text = age.toString();
    } else {
      _ageController.text = '';
    }
  }

  void _validateForm() {
    // Nomor telepon tidak lagi wajib di sini
    final isValid =
        _nameController.text.isNotEmpty &&
        _birthDate != null &&
        _genderValue.isNotEmpty;
    // Validasi email akan ditangani oleh TextFormField jika diisi

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _validateNewEmailField() {
    final newEmail = _newEmailController.text.trim();
    final bool isValidNow =
        newEmail.isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail);
    if (_isNewEmailFieldValid != isValidNow) {
      if (mounted) {
        // Pastikan widget masih ada di tree
        setState(() {
          _isNewEmailFieldValid = isValidNow;
        });
      }
    }
  }

  // Fungsi _pickImage, _uploadProfileImage, _removeProfilePicture, _showProfilePictureOptions
  // tetap sama seperti yang sudah Anda miliki dan telah diperbaiki sebelumnya.
  // Pastikan fungsi-fungsi tersebut ada di sini.
  Future<void> _pickImage(ImageSource source) async {
    // (Pastikan ada)
    try {
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted && mounted) {
          _showSnackBar('Izin kamera diperlukan.');
          if (cameraStatus.isPermanentlyDenied) openAppSettings();
          return;
        }
      }
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    // (Pastikan ada)
    if (!mounted) return null;
    // Global loading provider TIDAK diubah di sini, karena ini bagian dari _saveChanges
    try {
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'profile_images/$userId/$fileName';
      final storageRef = _storage.ref().child(storagePath);
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showSnackBar('Gagal mengunggah foto profil: ${e.toString()}');
      return null;
    }
  }

  Future<void> _removeProfilePicture() async {
    // (Pastikan ada)
    Navigator.of(context).pop(); // Tutup bottom sheet
    // Global loading provider TIDAK diubah di sini
    try {
      if (_profileImageUrlFromNetwork != null &&
          _profileImageUrlFromNetwork!.isNotEmpty) {
        try {
          await _storage.refFromURL(_profileImageUrlFromNetwork!).delete();
        } catch (e) {
          print('Gagal menghapus foto lama: $e');
        }
      }
      setState(() {
        _profileImageFile = null;
        _profileImageUrlFromNetwork = null;
      });
      _showSnackBar(
        'Foto profil telah dihapus dari tampilan. Simpan perubahan untuk konfirmasi.',
        isError: false,
      );
    } catch (e) {
      _showSnackBar('Gagal menghapus foto: ${e.toString()}');
    }
  }

  void _showProfilePictureOptions() {
    // (Pastikan ada)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profileImageFile != null ||
                  (_profileImageUrlFromNetwork?.isNotEmpty ?? false))
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Hapus Foto',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: _removeProfilePicture,
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleUpdateAuthEmail() async {
    final newEmail = _emailController.text.trim();
    final currentUser = _firebaseAuth.currentUser;

    if (newEmail.isEmpty) {
      _showSnackBar('Email tidak boleh kosong untuk diperbarui.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail)) {
      _showSnackBar('Format email tidak valid.');
      return;
    }
    if (currentUser == null) {
      _showSnackBar('User tidak terautentikasi.');
      return;
    }
    if (currentUser.email == newEmail && currentUser.emailVerified == true) {
      _showSnackBar(
        'Email akun sudah sama dan terverifikasi.',
        isError: false,
        backgroundColor: Colors.blueAccent,
      );
      return;
    }
    // Cek apakah email berasal dari Google
    bool isGoogleLinked = currentUser.providerData.any(
      (provider) =>
          provider.providerId == fb_auth.GoogleAuthProvider.PROVIDER_ID,
    );
    if (isGoogleLinked && currentUser.email == newEmail) {
      _showSnackBar(
        'Email akun Google tidak dapat diubah atau diverifikasi ulang dari sini.',
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    setState(() {
      _isUpdatingEmail = true;
    });
    try {
      await ref.read(authProvider.notifier).updateAuthUserEmail(newEmail);
      _showSnackBar(
        'Email akun berhasil diperbarui. Email verifikasi telah dikirim ke $newEmail.',
        isError: false,
      );
      // Muat ulang profil untuk mendapatkan status emailVerified terbaru jika perlu
      await ref.read(userProfileProvider.notifier).loadProfile();
      // Update juga _emailController jika ada normalisasi dari backend (jarang terjadi untuk email)
      // Jika proses di atas berhasil, userProfileProvider.state.email akan update via loadProfile
      // dan authUser.email juga akan update, jadi setState mungkin tidak perlu di sini jika UI sudah listen ke provider.
      // Namun, untuk memastikan _emailController sinkron dengan authUser.email yang baru:
      if (mounted) {
        _emailController.text = _firebaseAuth.currentUser?.email ?? newEmail;
      }
    } on Exception catch (e) {
      // Menangkap Exception umum dari AuthNotifier
      _showSnackBar(
        'Gagal memperbarui email akun: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingEmail = false;
        });
      }
    }
  }

  Future<void> _startPhoneLinkingVerification(String phoneNumber) async {
    if (!mounted) return;
    // JANGAN set isLoadingProvider global di sini. Gunakan _isLinkingPhone.
    setState(() {
      _isLinkingPhone = true;
    });
    _showSnackBar(
      'Mengirim kode OTP ke $phoneNumber...',
      isError: false,
      backgroundColor: Colors.orangeAccent,
    );

    final fbAuthInstance = ref.read(firebaseAuthProvider);
    await fbAuthInstance.verifyPhoneNumber(
      phoneNumber:
          phoneNumber, // Nomor sudah diformat oleh pemanggil (_handleLinkPhoneNumber)
      verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
        if (!mounted) return;
        _showSnackBar('Nomor terverifikasi otomatis.', isError: false);
        await _completePhoneLinking(credential);
        // setState untuk _isLinkingPhone sudah ada di _completePhoneLinking
      },
      verificationFailed: (fb_auth.FirebaseAuthException e) {
        if (!mounted) return;
        _showSnackBar('Gagal mengirim OTP: ${e.message}');
        setState(() {
          _isLinkingPhone = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        _showSnackBar('Kode OTP telah dikirim.', isError: false);
        setState(() {
          _linkingVerificationId = verificationId;
          // _isLinkingPhone sudah true
        });
        _showOtpDialogForLinking();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!mounted && _isLinkingPhone) {
          setState(() {
            _linkingVerificationId = verificationId;
          });
        }
        print("OTP auto retrieval timeout. Verification ID: $verificationId");
      },
    );
  }

  void _showOtpDialogForLinking() {
    if (!mounted) return;
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextDialog) {
        return AlertDialog(
          title: Text('Masukkan Kode OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Kode OTP telah dikirim ke nomor yang Anda masukkan."),
              SizedBox(height: 10),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  counterText: "",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
                setState(() {
                  _isLinkingPhone = false;
                  _linkingVerificationId = null;
                });
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_linkingVerificationId != null &&
                    _otpController.text.trim().length == 6) {
                  final credential = fb_auth.PhoneAuthProvider.credential(
                    verificationId: _linkingVerificationId!,
                    smsCode: _otpController.text.trim(),
                  );
                  Navigator.of(contextDialog).pop();
                  await _completePhoneLinking(credential);
                } else {
                  _showSnackBar(
                    "Harap masukkan kode OTP 6 digit.",
                    isError: true,
                  );
                }
              },
              child: Text('Verifikasi & Tautkan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completePhoneLinking(
    fb_auth.PhoneAuthCredential credential,
  ) async {
    if (!mounted) return;
    // JANGAN set isLoadingProvider global. _isLinkingPhone sudah true.
    try {
      await ref
          .read(authProvider.notifier)
          .linkPhoneNumberToCurrentUser(credential);
      _showSnackBar(
        'Nomor telepon berhasil ditautkan sebagai metode login!',
        isError: false,
      );
      await ref.read(userProfileProvider.notifier).loadProfile();
    } on Exception catch (e) {
      _showSnackBar(
        'Gagal menautkan nomor telepon: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLinkingPhone = false;
          _linkingVerificationId = null;
          _otpController.clear();
        });
      }
    }
  }

  // FUNGSI BARU untuk tombol verifikasi telepon
  Future<void> _handleLinkPhoneNumber() async {
    final newPhoneRaw = _phoneNumberController.text.trim();
    if (newPhoneRaw.isEmpty) {
      _showSnackBar('Masukkan nomor telepon untuk diverifikasi dan ditautkan.');
      return;
    }

    String formattedPhoneNumber = newPhoneRaw;
    if (formattedPhoneNumber.startsWith('0')) {
      formattedPhoneNumber = '+62${formattedPhoneNumber.substring(1)}';
    } else if (!formattedPhoneNumber.startsWith('+')) {
      _showSnackBar(
        'Format nomor telepon tidak valid. Gunakan 08xx atau +628xx.',
      );
      return;
    }

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      _showSnackBar('User tidak terautentikasi.');
      return;
    }

    final isAlreadyLinkedWithThisNumber = currentUser.providerData.any(
      (userInfo) =>
          userInfo.providerId == fb_auth.PhoneAuthProvider.PROVIDER_ID &&
          userInfo.phoneNumber == formattedPhoneNumber,
    );

    if (isAlreadyLinkedWithThisNumber) {
      _showSnackBar(
        'Nomor telepon ini sudah terverifikasi dan tertaut ke akun Anda.',
        isError: false,
        backgroundColor: Colors.blueAccent,
      );
      return;
    }
    // Tidak perlu set _isLinkingPhone di sini, akan di-set oleh _startPhoneLinkingVerification
    await _startPhoneLinkingVerification(formattedPhoneNumber);
  }

  // --- MODIFIKASI _saveChanges ---
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Harap perbaiki error pada form.');
      return;
    }
    if (!mounted) return;

    ref.read(isLoadingProvider.notifier).state = true;
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      _showSnackBar('User tidak terautentikasi.');
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    String? finalPhotoUrl = _profileImageUrlFromNetwork;
    bool photoUploadAttempted = false;
    bool photoUploadSuccess = true;

    if (_profileImageFile != null) {
      photoUploadAttempted = true;
      _showSnackBar(
        'Mengunggah foto profil...',
        isError: false,
        backgroundColor: Colors.orangeAccent,
      );
      finalPhotoUrl = await _uploadProfileImage(
        _profileImageFile!,
        currentUser.uid,
      );
      if (finalPhotoUrl == null) {
        photoUploadSuccess = false;
        // JANGAN hentikan proses, biarkan data lain tersimpan. Foto gagal diupdate.
        _showSnackBar(
          'Foto profil gagal diunggah, data lain tetap akan disimpan.',
        );
        finalPhotoUrl =
            _profileImageUrlFromNetwork; // Kembalikan ke URL lama jika upload gagal
      } else {
        _showSnackBar('Foto profil berhasil diunggah!', isError: false);
      }
    } else if (_profileImageUrlFromNetwork == null &&
        _profileImageFile == null) {
      finalPhotoUrl = null; // Foto dihapus dan tidak ada yang baru
    }

    final newName = _nameController.text.trim();
    final newPhone = _phoneNumberController.text.trim();
    final newEmail = _emailController.text.trim();
    final newpatientPhone = _patientPhoneNumberController.text.trim();

    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            // .isNotEmpty ? {var} : null berarti Simpan null jika kosong
            email: newEmail,
            name: newName,
            phone: newPhone.isNotEmpty ? newPhone : null,
            patientPhone: newpatientPhone.isNotEmpty ? newpatientPhone : null,
            birthDate: _birthDate,
            gender: _genderValue.isNotEmpty ? _genderValue : null,
            photoUrl: finalPhotoUrl,
          );

      if (photoUploadAttempted && !photoUploadSuccess) {
        _showSnackBar(
          'Data profil berhasil diperbarui, namun foto gagal diunggah.',
          isError: false,
          backgroundColor: Colors.orangeAccent,
        );
      } else {
        _showSnackBar('Profil berhasil diperbarui!', isError: false);
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pop(true); // Kembali dan trigger refresh di ViewProfilePage
      }
    } catch (e) {
      _showSnackBar(
        'Gagal memperbarui profil: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _saveChangesEmail() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Harap perbaiki error pada form.');
      return;
    }
    if (!mounted) return;

    ref.read(isLoadingProvider.notifier).state =
        true; // Loading utama untuk simpan profil
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      _showSnackBar('User tidak terautentikasi.');
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    final newEmail = _emailController.text.trim();

    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(email: newEmail);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar(
        'Gagal memperbarui profil: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    // Loading utama untuk simpan profil
    final bool isGoogleEmail =
        _firebaseAuth.currentUser?.providerData.any(
          (p) =>
              p.providerId == fb_auth.GoogleAuthProvider.PROVIDER_ID &&
              p.email == _emailController.text,
        ) ??
        false;

    ImageProvider? displayImage;
    if (_profileImageFile != null) {
      displayImage = FileImage(_profileImageFile!);
    } else if (_profileImageUrlFromNetwork != null &&
        _profileImageUrlFromNetwork!.isNotEmpty) {
      displayImage = NetworkImage(_profileImageUrlFromNetwork!);
    }

    final currentUser = _firebaseAuth.currentUser;

    bool canActivateUpdateButton =
        _isNewEmailFieldValid &&
        !isGoogleEmail &&
        _newEmailController.text.trim() != (currentUser?.email ?? '');

    bool isCurrentPhoneLinked = false;
    if (currentUser != null && _phoneNumberController.text.isNotEmpty) {
      String currentFormattedPhone = _phoneNumberController.text.trim();
      if (currentFormattedPhone.startsWith('0')) {
        currentFormattedPhone = '+62${currentFormattedPhone.substring(1)}';
      }
      isCurrentPhoneLinked = currentUser.providerData.any(
        (p) =>
            p.providerId == fb_auth.PhoneAuthProvider.PROVIDER_ID &&
            p.phoneNumber == currentFormattedPhone,
      );
    }

    bool canUpdateAuthEmail =
        !isGoogleEmail &&
        _emailController.text.isNotEmpty &&
        (_firebaseAuth.currentUser?.email != _emailController.text.trim() ||
            !(_firebaseAuth.currentUser?.emailVerified ?? false));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ... (UI Avatar dan Nama tetap sama)
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: displayImage,
                          child:
                              displayImage == null
                                  ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[500],
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: Colors.blue.shade600,
                            shape: const CircleBorder(),
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _showProfilePictureOptions,
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : (widget.userProfile.name ?? 'Nama Pengguna'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    _buildProfileInfoCard(
                      title: 'Info Profil Pasien',
                      children: [
                        // ... (Field Nama, Umur, Gender, Tanggal Lahir tetap sama)
                        _buildLabeledFormField(
                          label: 'Nama',
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _fieldInputDecoration(),
                            validator:
                                (value) =>
                                    (value?.isEmpty ?? true)
                                        ? 'Nama tidak boleh kosong'
                                        : null,
                            onChanged: (_) => _validateForm(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabeledFormField(
                          label: 'Umur',
                          showTooltip: true,
                          tooltipMessage:
                              'Otomatis terisi setelah mengisi tanggal lahir.',
                          child: TextFormField(
                            controller: _ageController,
                            readOnly: true,
                            decoration: _fieldInputDecoration(readOnly: true),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabeledFormField(
                          label: 'Gender',
                          child: DropdownButtonFormField2<String>(
                            value: _genderValue.isEmpty ? null : _genderValue,
                            decoration: _fieldInputDecoration(
                              isDropdown: false,
                            ),
                            isExpanded: true,
                            buttonStyleData: ButtonStyleData(height: 36),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              maxHeight: 200,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                            ),
                            items:
                                ['Male', 'Female']
                                    .map(
                                      (gender) => DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(
                                          gender == 'Male'
                                              ? 'Laki-laki'
                                              : 'Perempuan',
                                        ),
                                      ),
                                    )
                                    .toList(),
                            validator:
                                (value) =>
                                    (value?.isEmpty ?? true)
                                        ? 'Jenis kelamin harus dipilih'
                                        : null,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _genderValue = value;
                                  _validateForm();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabeledFormField(
                          label: 'Tanggal Lahir',
                          child: GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    _birthDate ??
                                    DateTime.now().subtract(
                                      const Duration(days: 365 * 20),
                                    ),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.blue.shade600,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _birthDate = pickedDate;
                                  _updateAgeDisplay();
                                  _validateForm();
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text:
                                      _birthDate != null
                                          ? DateFormat(
                                            'dd / MM / yyyy',
                                          ).format(_birthDate!)
                                          : '',
                                ),
                                decoration: _fieldInputDecoration(
                                  suffixIcon: Icons.keyboard_arrow_down,
                                ),
                                validator:
                                    (_) =>
                                        _birthDate == null
                                            ? 'Tanggal lahir tidak boleh kosong'
                                            : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabeledFormField(
                          label: 'Nomor Telepon Pasien',
                          tooltipMessage:
                              'Otomatis terisi setelah mengisi tanggal lahir.',
                          child: TextFormField(
                            controller: _patientPhoneNumberController,
                            decoration: _fieldInputDecoration(
                              hintText: 'Opsional',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Tidak wajib
                              }
                              // Validasi sederhana untuk nomor Indonesia (8-13 digit setelah 0/62)
                              if (!RegExp(r'^(0|(\+62))\d{8,13}$').hasMatch(
                                value.replaceAll(RegExp(r'\s+|-'), ''),
                              )) {
                                return 'Format nomor telepon tidak valid (08xx atau +628xx)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProfileInfoCard(
                      title: 'Info Akun',
                      children: [
                        _buildLabeledFormField(
                          label: 'Email Akun Saat Ini',
                          child: TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: _fieldInputDecoration(readOnly: true),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // --- KONDISI UNTUK MENAMPILKAN FIELD PERBARUI EMAIL ---
                        if (!isGoogleEmail) ...[
                          // Hanya tampilkan jika BUKAN email Google
                          _buildLabeledFormField(
                            label: 'Perbarui Email Akun',
                            showTooltip: true,
                            tooltipMessage:
                                "Kode verifikasi akan dikirim ke alamat email baru untuk konfirmasi perubahan.",
                            child: TextFormField(
                              controller: _newEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _fieldInputDecoration(
                                hintText: 'Masukkan email baru',
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    !RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(value)) {
                                  return 'Format email baru tidak valid';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          // TOMBOL PERBARUI & VERIFIKASI EMAIL AKUN
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child:
                                _isUpdatingEmail
                                    ? Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Memproses..."),
                                        ],
                                      ),
                                    )
                                    : ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.email_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'Perbarui & Verifikasi Email Akun',
                                      ),
                                      onPressed:
                                          (isLoading ||
                                                  _isLinkingPhone ||
                                                  _isUpdatingEmail ||
                                                  !canActivateUpdateButton)
                                              ? null
                                              : _handleUpdateAuthEmail,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            canActivateUpdateButton
                                                ? Colors.amber.shade700
                                                : Colors.grey.shade400,
                                        foregroundColor: Colors.white,
                                        textStyle: TextStyle(fontSize: 14),
                                        minimumSize: Size(double.infinity, 40),
                                      ),
                                    ),
                          ),
                        ] else ...[
                          // Tampilkan pesan ini jika email Google
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                            ), // Disesuaikan paddingnya
                            child: Text(
                              "Email akun Anda tertaut dengan Google, sehingga tidak dapat diubah.",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors
                                        .grey[700], // Warna sedikit diperjelas
                              ),
                            ),
                          ),
                        ],

                        // --- END BAGIAN EMAIL ---
                        const SizedBox(height: 24),

                        // --- NOMOR TELEPON (FIELD + TOMBOL VERIFIKASI) ---
                        _buildLabeledFormField(
                          label: 'Akun Telepon Login ',
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldInputDecoration(
                              hintText: 'Contoh: 08123456789',
                            ), // Ubah hint ke format lokal
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Tidak wajib
                              }
                              // Validasi sederhana untuk nomor Indonesia (8-13 digit setelah 0/62)
                              if (!RegExp(r'^(0|(\+62))\d{8,13}$').hasMatch(
                                value.replaceAll(RegExp(r'\s+|-'), ''),
                              )) {
                                return 'Format nomor telepon tidak valid (08xx atau +628xx)';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              _validateForm(); // Panggil validate form umum
                              setState(
                                () {},
                              ); // Rebuild untuk update status tombol link
                            },
                          ),
                        ),
                        // Tombol untuk Verifikasi & Tautkan Nomor Telepon
                        if (_phoneNumberController.text.isNotEmpty &&
                            !isCurrentPhoneLinked &&
                            !_isLinkingPhone)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.phonelink_ring_outlined,
                                size: 18,
                              ),
                              label: Text('Verifikasi & Tautkan Nomor Telepon'),
                              onPressed:
                                  (isLoading || _isLinkingPhone)
                                      ? null
                                      : _handleLinkPhoneNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal, // Warna berbeda
                                foregroundColor: Colors.white,
                                textStyle: TextStyle(fontSize: 14),
                                minimumSize: Size(double.infinity, 60),
                              ),
                            ),
                          ),
                        if (_isLinkingPhone) // Tampilkan loading khusus untuk telepon
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(strokeWidth: 2),
                                  SizedBox(width: 10),
                                  Text("Memproses OTP..."),
                                ],
                              ),
                            ),
                          ),
                        if (isCurrentPhoneLinked)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Nomor ini sudah tertaut sebagai metode login",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          // Loading utama (untuk _saveChanges)
          if (isLoading &&
              !_isLinkingPhone) // Hanya tampilkan jika bukan loading phone linking
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_isFormValid)
                        ? Colors.blue.shade700
                        : Colors.grey.shade400,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              // Tombol Simpan dinonaktifkan jika sedang loading utama ATAU sedang linking phone
              onPressed:
                  (_isFormValid &&
                          !isLoading &&
                          !_isLinkingPhone &&
                          !_isUpdatingEmail)
                      ? _saveChanges
                      : null,
              child: const Text(
                'Simpan Perubahan Profil',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi _buildProfileInfoCard, _buildLabeledFormField, _fieldInputDecoration
  // tetap sama seperti yang sudah Anda miliki dan telah diperbaiki sebelumnya.
  // Pastikan fungsi-fungsi tersebut ada di sini.
  Widget _buildProfileInfoCard({
    String? title,
    required List<Widget> children,
  }) {
    // (Pastikan ada)
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledFormField({
    required String label,
    required Widget child,
    bool showTooltip = false,
    String tooltipMessage = '',
  }) {
    // (Pastikan ada)
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (showTooltip) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltipMessage,
                  child: InkWell(
                    onTap: () {
                      _showSnackBar(
                        tooltipMessage,
                        isError: false,
                        backgroundColor: Colors.blueGrey,
                      );
                    },
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _fieldInputDecoration({
    String? hintText,
    IconData? suffixIcon,
    bool readOnly = false,
    bool isDropdown = false,
  }) {
    // (Pastikan ada)
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
      ),
      suffixIcon:
          isDropdown
              ? Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700)
              : (suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey.shade700, size: 20)
                  : null),
    );
  }
}
