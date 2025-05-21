import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project/core/providers/shared_providers.dart';
import 'package:project/features/auth/presentation/pages/signin_page.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:project/features/profile/providers/user_profile_provider.dart';

class ViewProfilePage extends ConsumerStatefulWidget {
  const ViewProfilePage({super.key});

  @override
  ConsumerState<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends ConsumerState<ViewProfilePage> {
  @override
  void initState() {
    super.initState();
    // Memuat data profil saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    // Cek apakah widget masih mounted sebelum melakukan update state
    if (!mounted) return;
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      // Memastikan UserProfileNotifier memuat data terbaru
      await ref.read(userProfileProvider.notifier).loadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data profil: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  String _calculateAge(DateTime? birthdate) {
    if (birthdate == null) return '-';
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age.toString();
  }

  String _formatBirthDate(DateTime? birthdate) {
    if (birthdate == null) return '-';
    return DateFormat('dd / MM / yyyy').format(birthdate);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileProvider);
    final authUser = ref.watch(
      authProvider,
    ); // firebaseAuthProvider di user_profile_provider
    final isLoading = ref.watch(isLoadingProvider);

    ImageProvider? displayImage;
    if (userProfileState?.photoUrl != null &&
        userProfileState!.photoUrl!.isNotEmpty) {
      displayImage = NetworkImage(userProfileState.photoUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang sedikit abu-abu
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white, // AppBar putih seperti di gambar
        elevation: 0.5, // Sedikit shadow tipis untuk AppBar
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Tombol back (jika ada dari Nav)
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.blue, // Warna biru untuk ikon edit
            tooltip: 'Edit Profil',
            onPressed: () {
              if (userProfileState != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfilePage(
                          userProfile: userProfileState,
                        ), // Pastikan userProfileState di sini sudah update
                  ),
                ).then((value) {
                  if (value == true) _loadProfileData();
                });
              } else if (authUser != null) {
                // Jika profil Firestore belum ada
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditProfilePage(
                          userProfile: UserProfile(
                            // PASTIKAN SEMUA FIELD ADA, termasuk patientPhone
                            email: authUser.email ?? '',
                            name: authUser.displayName,
                            phone: authUser.phoneNumber,
                            photoUrl: authUser.photoURL,
                            patientPhone:
                                '', // Atau null, tergantung bagaimana Anda ingin menampilkannya jika baru
                          ),
                        ),
                  ),
                ).then((value) {
                  if (value == true) _loadProfileData();
                });
              } else {
                _showSnackBar('Data profil belum termuat untuk diedit.');
              }
            },
          ),
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              ref.read(isLoadingProvider.notifier).state = true;
              try {
                await ref.read(authProvider.notifier).signOut();
                if (mounted) {
                  // Navigasi ke SignInPage dan hapus semua route sebelumnya
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                    (Route<dynamic> route) => false,
                  );
                }
              } catch (e) {
                _showSnackBar('Gagal logout: ${e.toString()}');
              } finally {
                if (mounted) {
                  ref.read(isLoadingProvider.notifier).state = false;
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.logout, color: Colors.blue[700], size: 20),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          if (userProfileState == null && !isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Data profil tidak ditemukan atau belum lengkap.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadProfileData,
                      child: const Text('Coba Muat Ulang'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Membuat UserProfile dummy hanya dengan email jika authUser ada
                        // atau UserProfile kosong jika authUser juga null
                        final fallbackEmail = authUser?.email ?? '';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfilePage(
                                  userProfile: UserProfile(
                                    email: fallbackEmail,
                                  ),
                                ),
                          ),
                        ).then((value) {
                          if (value == true) _loadProfileData();
                        });
                      },
                      child: const Text('Lengkapi Profil Sekarang'),
                    ),
                  ],
                ),
              ),
            )
          else if (userProfileState != null)
            RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ), // Padding utama
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60, // Ukuran avatar seperti di gambar
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
                    const SizedBox(height: 12),
                    Text(
                      userProfileState.name ?? 'Nama Belum Diisi',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4B5563),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24), // Jarak sebelum kartu info
                    // KARTU INFO PROFIL PASIEN
                    _buildInfoSection(context, "Info Profil Pasien", [
                      _buildProfileDetailItem(
                        'Nama',
                        userProfileState.name ?? '-',
                      ),
                      _buildProfileDetailItem(
                        'Umur',
                        _calculateAge(userProfileState.birthDate) +
                            (_calculateAge(userProfileState.birthDate) != '-'
                                ? ''
                                : ''),
                      ), // ' tahun' sudah implisit atau tidak perlu
                      _buildProfileDetailItem(
                        'Gender',
                        userProfileState.gender == 'Male'
                            ? 'Laki-laki'
                            : (userProfileState.gender == 'Female'
                                ? 'Perempuan'
                                : '-'),
                      ),
                      _buildProfileDetailItem(
                        'Tanggal Lahir',
                        _formatBirthDate(userProfileState.birthDate),
                      ),
                      _buildProfileDetailItem(
                        'Nomor Telepon Pasien',
                        userProfileState.patientPhone ?? '-',
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // KARTU EMAIL LOGIN
                    _buildInfoSection(
                      context,
                      null, // Judul null agar langsung menampilkan item
                      [
                        _buildProfileDetailItem2(
                          'Email Login',
                          // Jika userProfileState.email null atau kosong, dan authUser.email ada, gunakan itu.
                          // Ini menangani kasus di mana profil Firestore mungkin belum sinkron atau user baru via telepon.
                          (userProfileState.email?.isEmpty ?? true)
                              ? (authUser?.email ??
                                  'Belum diisi') // Tampilkan email dari Auth jika ada, atau "Belum diisi"
                              : userProfileState
                                  .email!, // Jika ada di profil, tampilkan
                          isTitleAsLabel: true,
                        ),
                      ],
                      isSingleItemSection: true,
                    ),
                    const SizedBox(height: 20),

                    // KARTU NOMOR TELEPON
                    _buildInfoSection(
                      context,
                      null, // Judul null agar langsung menampilkan item
                      [
                        _buildProfileDetailItem2(
                          'Akun Telepon Login',
                          userProfileState.phone ?? '-',
                          isTitleAsLabel: true,
                        ),
                      ],
                      isSingleItemSection: true,
                    ),
                    const SizedBox(height: 24), // Padding bawah
                  ],
                ),
              ),
            ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String? title,
    List<Widget> children, {
    bool isSingleItemSection = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Tambahkan baris ini
          color: Colors.grey[300]!, // Ganti dengan warna yang Anda inginkan
          width: 0.5, // Ganti dengan ketebalan border yang Anda inginkan
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && !isSingleItemSection) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileDetailItem(
    String? label,
    String value, {
    bool isTitleAsLabel = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isTitleAsLabel ? 0 : 20,
      ), // Tidak ada bottom padding jika ini adalah item tunggal dengan label sebagai judul
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: isTitleAsLabel ? 14 : 13, // Ukuran label sedikit beda
                color: Colors.grey[700],
                fontWeight:
                    isTitleAsLabel ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            SizedBox(height: isTitleAsLabel ? 8 : 6),
          ],
          Container(
            width: double.infinity,
            // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              // Hapus warna latar belakang atau sesuaikan jika ingin berbeda dari Scaffold
              // color: Colors.white, // Opsional: jika ingin latar belakangnya tetap putih
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[400]!, // Warna underline, sesuaikan
                  width: 1.0, // Ketebalan underline, sesuaikan
                ),
              ),
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailItem2(
    String? label,
    String value, {
    bool isTitleAsLabel = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTitleAsLabel ? 0 : 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: isTitleAsLabel ? 14 : 13,
                color: Colors.grey[700],
                fontWeight:
                    isTitleAsLabel ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            SizedBox(height: isTitleAsLabel ? 8 : 6),
          ],
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
