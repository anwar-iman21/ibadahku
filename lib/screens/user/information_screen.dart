import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';

enum InformationSection { guide, privacy, terms, help }

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key, required this.section});
  final InformationSection section;

  String get _title => switch (section) {
    InformationSection.guide => 'Panduan ibadah',
    InformationSection.privacy => 'Kebijakan privasi',
    InformationSection.terms => 'Syarat penggunaan',
    InformationSection.help => 'FAQ & bantuan',
  };

  String get _subtitle => switch (section) {
    InformationSection.guide =>
      'Ringkasan niat dan langkah ibadah zakat serta qurban.',
    InformationSection.privacy =>
      'Penjelasan data yang diproses dan kontrol yang tersedia.',
    InformationSection.terms =>
      'Ketentuan penggunaan IbadahKu dan batasan layanan.',
    InformationSection.help =>
      'Jawaban ringkas untuk pertanyaan yang sering ditanyakan.',
  };

  @override
  Widget build(BuildContext context) => AppPage(
    title: _title,
    subtitle: _subtitle,
    onBack: () => context.pop(),
    children: [
      AppCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green[800], AppColors.green[600]],
        ),
        border: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
            const HGap(Sp.s3),
            Expanded(
              child: Text(
                'Informasi ini membantu penggunaan aplikasi. Untuk kepastian '
                'hukum ibadah, ikuti bimbingan ulama atau lembaga resmi.',
                style: AppText.sm.c(Colors.white),
              ),
            ),
          ],
        ),
      ),
      ...switch (section) {
        InformationSection.guide => _guideContent(),
        InformationSection.privacy => _privacyContent(),
        InformationSection.terms => _termsContent(),
        InformationSection.help => _helpContent(),
      },
    ],
  );

  List<Widget> _guideContent() => [
    const _InfoBlock(
      icon: Icons.grass_rounded,
      title: 'Zakat fitrah',
      paragraphs: [
        'Niat berada di dalam hati saat menunaikan zakat. Contoh lafal untuk diri sendiri: '
            'نَوَيْتُ أَنْ أُخْرِجَ زَكَاةَ الْفِطْرِ عَنْ نَفْسِي فَرْضًا لِلَّهِ تَعَالَى',
        'Transliterasi: Nawaitu an ukhrija zakaatal fitri ‘an nafsii fardhan lillaahi ta‘aalaa. '
            'Lafal ini contoh, bukan syarat; niat dalam hati sudah menjadi pokok.',
        'Tentukan jumlah jiwa, pilih makanan pokok atau nilai uang yang setara, lalu cek besaran '
            'dan waktu penyaluran sesuai ketentuan BAZNAS/LAZ atau otoritas setempat.',
        'Bayarkan melalui amil/lembaga tepercaya agar dapat disalurkan kepada penerima yang berhak.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Zakat maal',
      paragraphs: [
        'Tinjau harta yang termasuk objek zakat, kewajiban/utang yang relevan, serta masa kepemilikan '
            'sesuai jenis hartanya.',
        'Bandingkan nilai harta bersih dengan nisab dan haul yang berlaku. Kalkulator memakai data '
            'yang dimasukkan pengguna dan harga acuan; periksa kembali sebelum membayar.',
        'Niatkan zakat dalam hati ketika menunaikan, kemudian salurkan kepada golongan penerima yang '
            'berhak melalui lembaga atau amil tepercaya.',
        'Ketentuan nisab, haul, harta yang dihitung, dan tarif dapat berbeda menurut jenis harta '
            'dan panduan yang diikuti. Konsultasikan kasus khusus kepada ahli zakat.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.pets_rounded,
      title: 'Qurban',
      paragraphs: [
        'Pilih hewan yang memenuhi ketentuan jenis, umur, kesehatan, dan bebas cacat menurut panduan '
            'yang diikuti. Kalkulator ini hanya membantu merencanakan biaya dan tabungan.',
        'Niatkan qurban untuk Allah saat penyembelihan atau ketika mewakilkan penyembelihan. Pemilik '
            'dapat menyebut nama pekurban kepada penyelenggara.',
        'Pastikan penyembelihan dilakukan pada waktu yang sah oleh petugas yang kompeten, dengan '
            'memperhatikan kesejahteraan hewan, kebersihan, dan aturan setempat.',
        'Atur pembagian daging bersama panitia dan ikuti ketentuan fikih serta kebijakan lembaga '
            'penyelenggara. Rincian pembagian bukan pengganti konsultasi agama.',
      ],
    ),
    AppCard(
      color: AppColors.cream[100],
      child: const Text(
        'Panduan ini bersifat ringkas dan edukatif. Rujuk BAZNAS/LAZ, Kementerian Agama, '
        'atau ulama terpercaya untuk keputusan ibadah.',
      ),
    ),
  ];

  List<Widget> _privacyContent() => [
    const _InfoBlock(
      icon: Icons.dataset_outlined,
      title: 'Data yang digunakan',
      paragraphs: [
        'Aplikasi menyimpan username, nama profil, peran akun, serta data masukan dan hasil '
            'perhitungan yang pengguna pilih untuk disimpan sebagai riwayat.',
        'Data akun dan riwayat disimpan di Firebase Authentication dan Cloud Firestore pada proyek '
            'yang mengoperasikan aplikasi.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.admin_panel_settings_outlined,
      title: 'Akses dan keamanan',
      paragraphs: [
        'Aturan akses membatasi riwayat ke pemilik akun dan administrator proyek. Administrator '
            'proyek dapat memiliki akses operasional ke data yang tersimpan.',
        'Gunakan password yang kuat dan jangan membagikan kredensial. Keamanan juga bergantung pada '
            'konfigurasi Firebase dan perangkat yang digunakan.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.tune_rounded,
      title: 'Pilihan pengguna',
      paragraphs: [
        'Pengguna dapat menghapus satu atau seluruh riwayat dari aplikasi.',
        'Penghapusan akun tidak tersedia di dalam aplikasi. Untuk permintaan terkait akun, hubungi '
            'administrator/pengelola aplikasi.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.update_rounded,
      title: 'Perubahan kebijakan',
      paragraphs: [
        'Kebijakan dapat diperbarui ketika cara kerja aplikasi berubah. Versi terbaru ditampilkan '
            'di halaman ini; tinjau kembali setelah pembaruan aplikasi.',
      ],
    ),
  ];

  List<Widget> _termsContent() => [
    const _InfoBlock(
      icon: Icons.calculate_outlined,
      title: 'Fungsi aplikasi',
      paragraphs: [
        'IbadahKu menyediakan alat bantu estimasi zakat dan perencanaan qurban. Hasil dipengaruhi '
            'oleh data yang dimasukkan dan harga acuan yang tersedia.',
        'Pengguna bertanggung jawab memeriksa harga, nisab, haul, syarat ibadah, waktu, dan '
            'penyaluran kepada sumber resmi atau ahli yang kompeten.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.warning_amber_rounded,
      title: 'Batasan layanan',
      paragraphs: [
        'Hasil aplikasi bukan fatwa, nasihat keuangan, atau jaminan penerimaan ibadah. Pengelola '
            'tidak menjamin layanan selalu tersedia atau bebas dari gangguan jaringan.',
        'Jangan mengandalkan nilai contoh sebagai harga pasar terkini. Admin perlu memperbarui '
            'harga dan pengguna perlu memeriksa tanggal serta sumbernya.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.account_circle_outlined,
      title: 'Akun dan penggunaan wajar',
      paragraphs: [
        'Jaga kerahasiaan akun dan gunakan aplikasi secara sah. Jangan mencoba mengakses data '
            'pengguna lain, mengganggu layanan, atau memasukkan konten yang melanggar hukum.',
        'Pengelola dapat membatasi akun atau fitur jika terjadi penyalahgunaan atau jika diwajibkan '
            'oleh hukum.',
      ],
    ),
    const _InfoBlock(
      icon: Icons.policy_outlined,
      title: 'Pembaruan ketentuan',
      paragraphs: [
        'Ketentuan dapat diperbarui mengikuti perubahan layanan. Penggunaan aplikasi setelah '
            'pembaruan berarti pengguna diminta membaca dan menerima ketentuan terbaru.',
      ],
    ),
  ];

  List<Widget> _helpContent() => [
    const _FaqBlock(
      items: [
        (
          'Bagaimana cara mengubah password?',
          'Masuk ke Akun, pilih Ganti password, masukkan password sekarang, lalu password baru. '
              'Firebase dapat meminta login ulang jika sesi sudah lama.',
        ),
        (
          'Bagaimana cara mengubah nama profil?',
          'Buka Akun, pilih Ubah profil, edit nama lengkap lalu simpan. Username login tidak '
              'diubah dari aplikasi.',
        ),
        (
          'Apakah nilai zakat dan qurban merupakan keputusan final?',
          'Tidak. Nilainya adalah estimasi berdasarkan data yang dimasukkan. Periksa harga dan '
              'ketentuan terbaru kepada BAZNAS/LAZ atau ulama terpercaya.',
        ),
        (
          'Riwayat saya tersimpan di mana?',
          'Riwayat disimpan di Cloud Firestore pada proyek Firebase aplikasi dan hanya dapat dibaca '
              'oleh pemilik akun serta administrator sesuai aturan akses proyek.',
        ),
      ],
    ),
    AppCard(
      color: AppColors.cream[100],
      child: const Text(
        'Jika masalah berkaitan dengan akun Firebase atau akses admin, hubungi pengelola aplikasi. '
        'Jangan kirim password atau kode verifikasi kepada siapa pun.',
      ),
    ),
  ];
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.paragraphs,
  });
  final IconData icon;
  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(icon, size: 44),
            const HGap(Sp.s3),
            Expanded(child: Text(title, style: AppText.lg.semibold)),
          ],
        ),
        const VGap(Sp.s3),
        for (final paragraph in paragraphs) ...[
          Text(paragraph, style: AppText.sm.c(context.mutedText)),
          if (paragraph != paragraphs.last) const VGap(Sp.s3),
        ],
      ],
    ),
  );
}

class _FaqBlock extends StatelessWidget {
  const _FaqBlock({required this.items});
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          ExpansionTile(
            leading: const IconBadge(Icons.help_outline_rounded, size: 38),
            title: Text(items[i].$1, style: AppText.sm.semibold),
            childrenPadding: const EdgeInsets.fromLTRB(Sp.s4, 0, Sp.s4, Sp.s4),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  items[i].$2,
                  style: AppText.sm.c(context.mutedText),
                ),
              ),
            ],
          ),
          if (i != items.length - 1)
            Divider(height: 1, color: context.borderColor),
        ],
      ],
    ),
  );
}
