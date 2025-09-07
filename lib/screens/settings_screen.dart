import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/notification_helper.dart';

class _AppearanceSettingsSection extends StatelessWidget {
  const _AppearanceSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsScreenState._buildSectionHeader(context, 'Tampilan'),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _SettingsScreenState._buildSettingTile(
              context,
              icon: themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              title: 'Tema Gelap',
              subtitle: themeProvider.isDarkMode ? 'Aktif' : 'Nonaktif',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Tema gelap diaktifkan'
                            : 'Tema terang diaktifkan',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NotificationSettingsSection extends StatelessWidget {
  const _NotificationSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsScreenState._buildSectionHeader(context, 'Notifikasi'),
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return _SettingsScreenState._buildSettingTile(
              context,
              icon: settingsProvider.isDailyReminderEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              title: 'Pengingat Harian',
              subtitle: settingsProvider.isDailyReminderEnabled
                  ? 'Aktif - 11:00 AM setiap hari'
                  : 'Nonaktif',
              trailing: Switch(
                value: settingsProvider.isDailyReminderEnabled,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);

                  if (value) {
                    final status = await Permission.notification.request();
                    if (!context.mounted) return;

                    if (status.isGranted) {
                      try {
                        await settingsProvider.setDailyReminder(true);
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Pengingat harian telah diaktifkan'),
                          ),
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal mengaktifkan pengingat: $error',
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Izin notifikasi ditolak. Pengingat tidak diaktifkan.',
                          ),
                          action: SnackBarAction(
                            label: 'Setelan',
                            onPressed: openAppSettings,
                          ),
                        ),
                      );
                    }
                  } else {
                    try {
                      await settingsProvider.setDailyReminder(false);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Pengingat harian telah dinonaktifkan'),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal menonaktifkan pengingat: $error',
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
              ),
            );
          },
        ),
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            if (settingsProvider.isDailyReminderEnabled || kDebugMode) {
              return _SettingsScreenState._buildSettingTile(
                context,
                icon: Icons.notification_important,
                title: 'Test Notifikasi',
                subtitle: 'Kirim notifikasi test sekarang',
                onTap: () async {
                  await NotificationHelper.showInstantTestNotification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi test telah dikirim!'),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _AboutSettingsSection extends StatelessWidget {
  final Function(BuildContext) showAboutDialog;
  final Function(BuildContext) showRatingDialog;
  final Function(BuildContext) showHelpDialog;
  final Function(BuildContext) showPrivacyDialog;

  const _AboutSettingsSection({
    required this.showAboutDialog,
    required this.showRatingDialog,
    required this.showHelpDialog,
    required this.showPrivacyDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsScreenState._buildSectionHeader(context, 'Tentang'),
        _SettingsScreenState._buildSettingTile(
          context,
          icon: Icons.info_outline,
          title: 'Versi Aplikasi',
          subtitle: '1.0.0',
          onTap: () => showAboutDialog(context),
        ),
        _SettingsScreenState._buildSettingTile(
          context,
          icon: Icons.star_outline,
          title: 'Beri Rating',
          subtitle: 'Bantu kami dengan memberikan rating',
          onTap: () => showRatingDialog(context),
        ),
        _SettingsScreenState._buildSettingTile(
          context,
          icon: Icons.help_outline,
          title: 'Bantuan',
          subtitle: 'FAQ dan panduan penggunaan',
          onTap: () => showHelpDialog(context),
        ),
        _SettingsScreenState._buildSettingTile(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Kebijakan Privasi',
          subtitle: 'Pelajari bagaimana kami melindungi data Anda',
          onTap: () => showPrivacyDialog(context),
        ),
      ],
    );
  }
}

class _DebugSettingsSection extends StatelessWidget {
  final Function(BuildContext) showResetDialog;

  const _DebugSettingsSection({required this.showResetDialog});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsScreenState._buildSectionHeader(context, 'Debug'),
        _SettingsScreenState._buildSettingTile(
          context,
          icon: Icons.bug_report_outlined,
          title: 'Reset Pengaturan',
          subtitle: 'Kembalikan ke pengaturan default',
          onTap: () => showResetDialog(context),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  static Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: AppTheme.containerDecoration(
          theme.colorScheme,
          opacity: 0.3,
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: theme.listTileTheme.shape,
      tileColor: theme.listTileTheme.tileColor,
      contentPadding: theme.listTileTheme.contentPadding,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Restaurant App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2023 Restaurant App. All rights reserved.',
    );
  }

  void _showRatingDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: theme.colorScheme.secondary),
              const SizedBox(width: 8.0),
              const Text('Beri Rating'),
            ],
          ),
          content: const Text(
            'Terima kasih telah menggunakan Restaurant App! \n'
            'Rating Anda sangat berarti untuk pengembangan aplikasi ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti Saja'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur rating akan segera tersedia di Play Store!',
                    ),
                  ),
                );
              },
              child: const Text('Beri Rating'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bantuan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  context,
                  '🏠',
                  'Beranda',
                  'Lihat daftar semua restoran yang tersedia',
                ),
                _buildHelpItem(
                  context,
                  '🔍',
                  'Pencarian',
                  'Cari restoran berdasarkan nama atau kata kunci',
                ),
                _buildHelpItem(
                  context,
                  '❤️',
                  'Favorit',
                  'Simpan dan kelola restoran favorit Anda',
                ),
                _buildHelpItem(
                  context,
                  '⚙️',
                  'Pengaturan',
                  'Atur tema, notifikasi, dan preferensi lainnya',
                ),
                _buildHelpItem(
                  context,
                  '🔔',
                  'Pengingat',
                  'Dapatkan notifikasi harian di jam 11:00 AM',
                ),
                _buildHelpItem(
                  context,
                  '⭐',
                  'Review',
                  'Baca dan tulis review untuk restoran',
                ),
                _buildHelpItem(
                  context,
                  '📍',
                  'Detail',
                  'Lihat informasi lengkap, menu, dan lokasi restoran',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kebijakan Privasi'),
          content: const SingleChildScrollView(
            child: Text(
              'Aplikasi Restaurant App menghormati privasi Anda:\n\n'
              '• Data favorit disimpan secara lokal di perangkat Anda\n'
              '• Pengaturan tema dan notifikasi tersimpan di perangkat\n'
              '• Tidak ada data pribadi yang dikirim ke server\n'
              '• Review yang Anda tulis akan disimpan di server API\n'
              '• Aplikasi memerlukan akses internet untuk mengambil data restoran\n'
              '• Notifikasi hanya digunakan untuk pengingat harian\n\n'
              'Kami berkomitmen untuk melindungi privasi dan keamanan data Anda.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Pengaturan'),
          content: const Text(
            'Apakah Anda yakin ingin mereset semua pengaturan ke default?\n\n'
            'Ini akan:\n'
            '• Mengatur tema ke mode terang\n'
            '• Mematikan pengingat harian\n'
            '• Tidak akan menghapus data favorit',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final themeProvider = Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                );
                final settingsProvider = Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                );

                await themeProvider.setTheme(ThemeMode.light);
                await settingsProvider.setDailyReminder(false);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan telah direset ke default'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20.0)),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.0,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppearanceSettingsSection(),
            const _NotificationSettingsSection(),
            _AboutSettingsSection(
              showAboutDialog: _showAboutDialog,
              showRatingDialog: _showRatingDialog,
              showHelpDialog: _showHelpDialog,
              showPrivacyDialog: _showPrivacyDialog,
            ),
            if (kDebugMode)
              _DebugSettingsSection(showResetDialog: _showResetDialog),
          ],
        ),
      ),
    );
  }
}
