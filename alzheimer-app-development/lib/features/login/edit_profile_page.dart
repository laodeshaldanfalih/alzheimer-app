// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// // Import provider Anda
// // Sesuaikan path ini jika berbeda di struktur proyek Anda
// import 'package:project/core/providers/shared_providers.dart';
// import 'package:project/features/login/auth_provider.dart';
// import 'package:project/features/login/user_profile_provider.dart';

// class EditProfilePage extends ConsumerStatefulWidget {
//   final UserProfile userProfile; // Terima data profil saat ini

//   const EditProfilePage({super.key, required this.userProfile});

//   @override
//   ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends ConsumerState<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isFormValid = false;

//   File? _profileImageFile;
//   String? _profileImageUrlFromNetwork; // URL gambar awal dari network

//   late TextEditingController _nameController;
//   late TextEditingController _ageController; // Hanya untuk tampilan
//   late TextEditingController _phoneNumberController;
//   String _genderValue = '';
//   DateTime? _birthDate;

//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     // Inisialisasi controller dengan data profil yang ada
//     _nameController = TextEditingController(text: widget.userProfile.name ?? '');
//     _ageController = TextEditingController();
//     _phoneNumberController = TextEditingController(text: widget.userProfile.phone ?? '');
//     _genderValue = widget.userProfile.gender ?? '';
//     _birthDate = widget.userProfile.birthDate;
//     _profileImageUrlFromNetwork = widget.userProfile.photoUrl;

//     _updateAgeDisplay();
//     // Validasi form di awal berdasarkan data yang ada
//     WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _phoneNumberController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, {bool isError = true, Color? backgroundColor}) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
//         ),
//       );
//     }
//   }

//   void _updateAgeDisplay() {
//     if (_birthDate != null) {
//       final now = DateTime.now();
//       int age = now.year - _birthDate!.year;
//       if (now.month < _birthDate!.month ||
//           (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
//         age--;
//       }
//       _ageController.text = age.toString();
//     } else {
//       _ageController.text = '';
//     }
//   }

//   void _validateForm() {
//     final isValid = _nameController.text.isNotEmpty &&
//         _phoneNumberController.text.isNotEmpty &&
//         _birthDate != null &&
//         _genderValue.isNotEmpty;
//     // Foto tidak wajib untuk validasi form dasar

//     if (_isFormValid != isValid) {
//       setState(() {
//         _isFormValid = isValid;
//       });
//     }
//   }

//   // Fungsi _pickImage dimodifikasi untuk akses galeri
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       if (source == ImageSource.camera) {
//         var cameraStatus = await Permission.camera.request();
//         if (!cameraStatus.isGranted) {
//           _showSnackBar('Izin kamera diperlukan.');
//           if (cameraStatus.isPermanentlyDenied) openAppSettings();
//           return;
//         }
//       } else {
//         // PERUBAHAN: Blok permintaan izin Permission.photos untuk galeri dihapus.
//         // Sekarang akan langsung memanggil ImagePicker, mirip dengan AlzheimerScanPage.
//         // ImagePicker mungkin akan memicu dialog izin sistem jika diperlukan.
//         // Namun, penanganan status 'isPermanentlyDenied' secara eksplisit untuk galeri
//         // tidak lagi ada di sini.
//       }

//       final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1024);
//       if (pickedFile != null) {
//         setState(() {
//           _profileImageFile = File(pickedFile.path);
//           // _profileImageUrlFromNetwork = null; // Opsional: hapus URL lama jika ingin langsung ganti
//         });
//       }
//     } catch (e) {
//       // Tangani error jika ImagePicker gagal atau jika ada masalah izin yang tidak tertangani
//       _showSnackBar('Gagal memilih gambar: ${e.toString()}');
//     }
//     // Menutup bottom sheet setelah operasi selesai (baik berhasil maupun gagal)
//     // Ini sesuai dengan struktur asli kode Anda di EditProfilePage
//     if (mounted && Navigator.canPop(context)) {
//        // Pastikan pop hanya dipanggil jika ada route yang bisa di-pop (misalnya, bottom sheet masih terbuka)
//        // Ini untuk menghindari error jika bottom sheet sudah ditutup oleh interaksi lain.
//        // Pada kode _showProfilePictureOptions Anda, bottom sheet ditutup secara manual di onTap ListTile nya.
//        // Jadi, pop di sini mungkin tidak selalu diperlukan jika sudah ditangani di pemanggil.
//        // Untuk konsistensi dengan kode AlzheimerScanPage, pop biasanya dilakukan di onTap ListTile.
//        // Namun, saya akan biarkan ini sesuai dengan kode asli EditProfilePage Anda,
//        // di mana pop ada di akhir _pickImage.
//        // Jika _showProfilePictureOptions Anda sudah memanggil pop, baris ini bisa jadi redundan atau error.
//        // Untuk amannya, saya akan hapus pop di sini, karena sudah ada di _showProfilePictureOptions pada kode asli Anda.
//        // Navigator.of(context).pop(); // Dihapus karena sudah ditangani di _showProfilePictureOptions
//     }
//   }

//   Future<String?> _uploadProfileImage(File imageFile, String userId) async {
//     ref.read(isLoadingProvider.notifier).state = true;
//     _showSnackBar('Mengunggah foto profil...', isError: false, backgroundColor: Colors.orange);
//     try {
//       final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final storagePath = 'profile_images/$userId/$fileName';
//       final storageRef = _storage.ref().child(storagePath);

//       UploadTask uploadTask = storageRef.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
//       TaskSnapshot snapshot = await uploadTask;
//       String downloadUrl = await snapshot.ref.getDownloadURL();

//       _showSnackBar('Foto profil berhasil diunggah!', isError: false);
//       return downloadUrl;
//     } on fb_auth.FirebaseException catch (e) {
//       print("Firebase Storage Upload Error: code=${e.code}, message=${e.message}");
//       _showSnackBar('Gagal unggah: ${e.message ?? e.code}');
//       return null;
//     } catch (e) {
//       print("Generic Storage Upload Error: $e");
//       _showSnackBar('Gagal mengunggah foto profil: Terjadi kesalahan.');
//       return null;
//     } finally {
//         if(mounted) ref.read(isLoadingProvider.notifier).state = false;
//     }
//   }

//   Future<void> _removeProfilePicture() async {
//     final currentUser = _firebaseAuth.currentUser;
//     if (currentUser == null) return;

//     // Tutup bottom sheet dulu jika ini dipanggil dari sana
//     if (Navigator.canPop(context)) {
//         Navigator.of(context).pop();
//     }

//     ref.read(isLoadingProvider.notifier).state = true;
//     try {
//       // Hapus dari Firebase Storage jika ada URL network lama
//       if (_profileImageUrlFromNetwork != null && _profileImageUrlFromNetwork!.isNotEmpty) {
//         try {
//           final existingImageRef = _storage.refFromURL(_profileImageUrlFromNetwork!);
//           await existingImageRef.delete();
//         } catch (e) {
//           print('Gagal menghapus foto lama dari Storage (mungkin sudah tidak ada): $e');
//           // Tidak perlu showSnackBar error di sini karena ini adalah operasi latar belakang
//         }
//       }
//       // Hapus juga file lokal yang mungkin dipilih
//       setState(() {
//         _profileImageFile = null;
//         _profileImageUrlFromNetwork = null; // Ini penting agar UI update
//       });
//       _showSnackBar('Foto profil telah dihapus. Perubahan akan disimpan saat Anda menekan "Simpan Perubahan".', isError: false);
//     } catch (e) {
//       _showSnackBar('Gagal menghapus foto: ${e.toString()}');
//     } finally {
//         if(mounted) ref.read(isLoadingProvider.notifier).state = false;
//     }
//   }

//   void _showProfilePictureOptions() {
//      showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library), title: const Text('Pilih dari Galeri'),
//                 onTap: () {
//                   Navigator.of(context).pop(); // Tutup bottom sheet
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera), title: const Text('Ambil Foto'),
//                 onTap: () {
//                   Navigator.of(context).pop(); // Tutup bottom sheet
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               if (_profileImageFile != null || (_profileImageUrlFromNetwork?.isNotEmpty ?? false))
//                 ListTile(
//                   leading: const Icon(Icons.delete, color: Colors.red),
//                   title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
//                   onTap: _removeProfilePicture, // _removeProfilePicture akan menangani pop-nya sendiri
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) {
//       _showSnackBar('Harap perbaiki error pada form.');
//       return;
//     }

//     ref.read(isLoadingProvider.notifier).state = true;
//     final currentUser = _firebaseAuth.currentUser;

//     if (currentUser == null || currentUser.email == null) {
//       _showSnackBar('User tidak terautentikasi.');
//       if(mounted) ref.read(isLoadingProvider.notifier).state = false;
//       return;
//     }

//     String? finalPhotoUrl = _profileImageUrlFromNetwork;

//     if (_profileImageFile != null) {
//       finalPhotoUrl = await _uploadProfileImage(_profileImageFile!, currentUser.uid);
//       if (finalPhotoUrl == null) {
//         if(mounted) ref.read(isLoadingProvider.notifier).state = false;
//         return;
//       }
//     } else if (_profileImageUrlFromNetwork == null) {
//         // Ini berarti foto dihapus dan tidak ada gambar baru yang dipilih
//         finalPhotoUrl = null;
//     }

//     try {
//       await ref.read(userProfileProvider.notifier).updateProfile(
//             email: currentUser.email!,
//             name: _nameController.text.trim(),
//             phone: _phoneNumberController.text.trim(),
//             birthDate: _birthDate,
//             gender: _genderValue,
//             photoUrl: finalPhotoUrl,
//           );
//       _showSnackBar('Profil berhasil diperbarui!', isError: false);
//       if (mounted) {
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       _showSnackBar('Gagal memperbarui profil: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         ref.read(isLoadingProvider.notifier).state = false;
//       }
//     }
//   }

//  @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(isLoadingProvider);

//     ImageProvider? displayImage;
//     if (_profileImageFile != null) {
//       displayImage = FileImage(_profileImageFile!);
//     } else if (_profileImageUrlFromNetwork != null && _profileImageUrlFromNetwork!.isNotEmpty) {
//       displayImage = NetworkImage(_profileImageUrlFromNetwork!);
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Edit Profil', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Stack(
//         children: [
//           GestureDetector(
//             onTap: () => FocusScope.of(context).unfocus(),
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//               child: Form(
//                 key: _formKey,
//                 autovalidateMode: AutovalidateMode.onUserInteraction,
//                 child: Column(
//                   children: [
//                     Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         CircleAvatar(
//                           radius: 70,
//                           backgroundColor: Colors.grey[300],
//                           backgroundImage: displayImage,
//                           child: displayImage == null
//                               ? Icon(Icons.person, size: 70, color: Colors.grey[500])
//                               : null,
//                         ),
//                         Positioned(
//                           bottom: 0, right: 0,
//                           child: Material(
//                             color: Colors.blue, shape: const CircleBorder(),
//                             clipBehavior: Clip.antiAlias,
//                             child: InkWell(
//                               onTap: _showProfilePictureOptions,
//                               child: const Padding(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: Icon(Icons.edit, color: Colors.white, size: 24),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 32),
//                     _buildTextFormField(
//                       controller: _nameController, labelText: 'Nama Lengkap',
//                       validator: (value) => (value?.isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextFormField(
//                       controller: _phoneNumberController, labelText: 'Nomor Telepon',
//                       keyboardType: TextInputType.phone,
//                       validator: (value) {
//                         if (value?.isEmpty ?? true) return 'Nomor telepon tidak boleh kosong';
//                         if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value!)) return 'Format nomor telepon tidak valid';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     GestureDetector(
//                       onTap: () async {
//                         final pickedDate = await showDatePicker(
//                           context: context,
//                           initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
//                           firstDate: DateTime(1900), lastDate: DateTime.now(),
//                         );
//                         if (pickedDate != null) {
//                           setState(() {
//                             _birthDate = pickedDate;
//                             _updateAgeDisplay(); _validateForm();
//                           });
//                         }
//                       },
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           controller: TextEditingController(
//                             text: _birthDate != null
//                                 ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
//                                 : '',
//                           ),
//                           decoration: _inputDecoration('Tanggal Lahir', icon: Icons.calendar_today),
//                           validator: (_) => _birthDate == null ? 'Tanggal lahir tidak boleh kosong' : null,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _ageController, readOnly: true,
//                       decoration: _inputDecoration('Umur (otomatis terisi)', readOnly: true),
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField2<String>(
//                       value: _genderValue.isEmpty ? null : _genderValue,
//                       decoration: _inputDecoration('Jenis Kelamin', isDropdown: true),
//                       isExpanded: true,
//                       items: ['Male', 'Female']
//                           .map((gender) => DropdownMenuItem<String>(
//                                 value: gender,
//                                 child: Text(gender == 'Male' ? 'Laki-laki' : 'Perempuan'),
//                               ))
//                           .toList(),
//                       validator: (value) => (value?.isEmpty ?? true) ? 'Jenis kelamin harus dipilih' : null,
//                       onChanged: (value) {
//                         if (value != null) {
//                           setState(() { _genderValue = value; _validateForm(); });
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _isFormValid ? Theme.of(context).primaryColor : Colors.grey,
//                         minimumSize: const Size(double.infinity, 50),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: (_isFormValid && !isLoading) ? _saveChanges : null,
//                       child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 18, color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(child: CircularProgressIndicator()),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String labelText,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     bool readOnly = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: _inputDecoration(labelText, readOnly: readOnly),
//       validator: validator,
//       readOnly: readOnly,
//       onChanged: (_) => _validateForm(),
//     );
//   }

//   InputDecoration _inputDecoration(String labelText, {IconData? icon, bool readOnly = false, bool isDropdown = false}) {
//     return InputDecoration(
//       labelText: labelText,
//       labelStyle: TextStyle(color: Colors.grey[700]),
//       filled: true,
//       fillColor: readOnly ? Colors.grey[200] : Colors.white,
//       suffixIcon: isDropdown ? Icon(Icons.arrow_drop_down, color: Colors.grey[700]) : (icon != null ? Icon(icon, color: Colors.grey[700]) : null),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey[400]!),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey[400]!),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.red, width: 1.5),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.red, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     );
//   }
// }

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
// Sesuaikan path ini jika berbeda di struktur proyek Anda
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/features/login/auth_provider.dart';
import 'package:project/features/login/user_profile_provider.dart';
import 'package:project/features/login/signin_page.dart'; // Untuk navigasi logout

class EditProfilePage extends ConsumerStatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;

  File? _profileImageFile;
  String? _profileImageUrlFromNetwork;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneNumberController;
  String _genderValue = '';
  DateTime? _birthDate;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  // Indeks untuk BottomNavigationBar
  int _selectedIndex = 2; // Asumsi halaman profil adalah indeks ke-2

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userProfile.name ?? '',
    );
    _ageController = TextEditingController();
    _phoneNumberController = TextEditingController(
      text: widget.userProfile.phone ?? '',
    );
    _genderValue = widget.userProfile.gender ?? '';
    _birthDate = widget.userProfile.birthDate;
    _profileImageUrlFromNetwork = widget.userProfile.photoUrl;

    _updateAgeDisplay();
    WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
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
          behavior: SnackBarBehavior.floating, // Agar SnackBar lebih terlihat
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
    final isValid =
        _nameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _birthDate != null &&
        _genderValue.isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        var cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted && mounted) {
          _showSnackBar('Izin kamera diperlukan.');
          if (cameraStatus.isPermanentlyDenied) openAppSettings();
          return;
        }
      }
      // Untuk galeri, image_picker akan menangani dialog izin jika diperlukan

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
      if (mounted) {
        _showSnackBar('Gagal memilih gambar: ${e.toString()}');
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    if (!mounted) return null;
    ref.read(isLoadingProvider.notifier).state = true;
    _showSnackBar(
      'Mengunggah foto profil...',
      isError: false,
      backgroundColor: Colors.orangeAccent,
    );
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
      String downloadUrl = await snapshot.ref.getDownloadURL();

      _showSnackBar('Foto profil berhasil diunggah!', isError: false);
      return downloadUrl;
    } on fb_auth.FirebaseException catch (e) {
      print(
        "Firebase Storage Upload Error: code=${e.code}, message=${e.message}",
      );
      _showSnackBar('Gagal unggah: ${e.message ?? e.code}');
      return null;
    } catch (e) {
      print("Generic Storage Upload Error: $e");
      _showSnackBar('Gagal mengunggah foto profil: Terjadi kesalahan.');
      return null;
    } finally {
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _removeProfilePicture() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || !mounted) return;

    Navigator.of(context).pop(); // Tutup bottom sheet dulu

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      if (_profileImageUrlFromNetwork != null &&
          _profileImageUrlFromNetwork!.isNotEmpty) {
        try {
          final existingImageRef = _storage.refFromURL(
            _profileImageUrlFromNetwork!,
          );
          await existingImageRef.delete();
        } catch (e) {
          print('Gagal menghapus foto lama dari Storage: $e');
        }
      }
      setState(() {
        _profileImageFile = null;
        _profileImageUrlFromNetwork = null;
      });
      _showSnackBar(
        'Foto profil telah dihapus. Perubahan akan disimpan saat Anda menekan "Simpan Perubahan".',
        isError: false,
      );
    } catch (e) {
      _showSnackBar('Gagal menghapus foto: ${e.toString()}');
    } finally {
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _showProfilePictureOptions() {
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Harap perbaiki error pada form.');
      return;
    }
    if (!mounted) return;

    ref.read(isLoadingProvider.notifier).state = true;
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null || currentUser.email == null) {
      _showSnackBar('User tidak terautentikasi.');
      if (mounted) ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    String? finalPhotoUrl = _profileImageUrlFromNetwork;

    if (_profileImageFile != null) {
      finalPhotoUrl = await _uploadProfileImage(
        _profileImageFile!,
        currentUser.uid,
      );
      if (finalPhotoUrl == null) {
        if (mounted) ref.read(isLoadingProvider.notifier).state = false;
        return;
      }
    } else if (_profileImageUrlFromNetwork == null &&
        _profileImageFile == null) {
      finalPhotoUrl = null;
    }

    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            email: currentUser.email!,
            name: _nameController.text.trim(),
            phone: _phoneNumberController.text.trim(),
            birthDate: _birthDate,
            gender: _genderValue,
            photoUrl: finalPhotoUrl,
          );
      _showSnackBar('Profil berhasil diperbarui!', isError: false);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnackBar('Gagal memperbarui profil: ${e.toString()}');
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _showSnackBar(
          'Navigasi ke Beranda (belum diimplementasi)',
          isError: false,
          backgroundColor: Colors.blueGrey,
        );
        break;
      case 1:
        _showSnackBar(
          'Navigasi ke Scan (belum diimplementasi)',
          isError: false,
          backgroundColor: Colors.blueGrey,
        );
        break;
      case 2:
        // Sudah di halaman profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);

    ImageProvider? displayImage;
    if (_profileImageFile != null) {
      displayImage = FileImage(_profileImageFile!);
    } else if (_profileImageUrlFromNetwork != null &&
        _profileImageUrlFromNetwork!.isNotEmpty) {
      displayImage = NetworkImage(_profileImageUrlFromNetwork!);
    }

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
                        // PERUBAHAN: Menambahkan ikon info pada field Umur
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
                                color:
                                    Colors
                                        .white, // Latar belakang putih untuk menu
                              ),
                              maxHeight:
                                  200, // Batas tinggi menu jika item banyak
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              // Styling untuk setiap item di menu
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 48, // Tinggi standar untuk item menu
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
                                        primary:
                                            Colors
                                                .blue
                                                .shade600, // Warna header dan tombol
                                        onPrimary:
                                            Colors
                                                .white, // Warna teks pada header/tombol
                                        surface:
                                            Colors
                                                .white, // Warna background utama
                                        onSurface:
                                            Colors
                                                .black, // Warna teks pada kalender
                                      ),
                                      dialogBackgroundColor:
                                          Colors
                                              .white, // Warna background dialog
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
                        _buildLabeledFormField(
                          label: 'Nomor Telepon',
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldInputDecoration(),
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return 'Nomor telepon tidak boleh kosong';
                              if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value!))
                                return 'Format nomor telepon tidak valid';
                              return null;
                            },
                            onChanged: (_) => _validateForm(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildProfileInfoCard(
                      children: [
                        _buildLabeledReadOnlyField(
                          label: 'Email Login',
                          value: widget.userProfile.email,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
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
                    _isFormValid ? Colors.blue.shade700 : Colors.grey.shade400,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              onPressed: (_isFormValid && !isLoading) ? _saveChanges : null,
              child: const Text(
                'Simpan Perubahan',
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

  Widget _buildProfileInfoCard({
    String? title,
    required List<Widget> children,
  }) {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris untuk label dan tooltip
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
                      // Opsional: Dapat menampilkan snackbar saat diklik
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

  Widget _buildLabeledReadOnlyField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
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
