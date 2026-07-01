import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  final int totalQuotes;
  final int favoriteCount;

  const ProfilePage({
    super.key,
    required this.totalQuotes,
    required this.favoriteCount,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── User data ─────────────────────────────────────────────
  String _name = "Quote Lover";
  String _bio = "Collecting wisdom, one quote at a time.";
  String _selectedAvatar = "🌟";
  int _quotesRead = 0;
  String _favoriteCategory = "Motivation";
  bool _notificationsOn = true;
  bool _darkMode = false;

  // ── Avatar options ────────────────────────────────────────
  final List<String> _avatars = [
    "🌟", "🔥", "💫", "☠️", "🦋", "🌺",
    "🎯", "💡", "🚀", "🎨", "📚", "🌊",
  ];

  static const Map<String, Color> _catColors = {
    "Motivation": Color(0xffFF6D00),
    "Life":       Color(0xff00897B),
    "Love":       Color(0xffE91E63),
    "Leadership": Color(0xff1565C0),
    "Friendship": Color(0xff558B2F),
    "Success":    Color(0xffF9A825),
  };

  static const List<String> _categories = [
    "Motivation", "Life", "Love", "Leadership", "Friendship", "Success",
  ];

  static const Color _primary = Color(0xff7C4DFF);

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Persistence ───────────────────────────────────────────
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name             = prefs.getString("profile_name")     ?? "Quote Lover";
      _bio              = prefs.getString("profile_bio")      ?? "Collecting wisdom, one quote at a time.";
      _selectedAvatar   = prefs.getString("profile_avatar")   ?? "🌟";
      _quotesRead       = prefs.getInt("quotes_read")         ?? 0;
      _favoriteCategory = prefs.getString("fav_category")     ?? "Motivation";
      _notificationsOn  = prefs.getBool("notifications")      ?? true;
      _darkMode         = prefs.getBool("dark_mode")          ?? false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_name",   _name);
    await prefs.setString("profile_bio",    _bio);
    await prefs.setString("profile_avatar", _selectedAvatar);
    await prefs.setString("fav_category",   _favoriteCategory);
    await prefs.setBool("notifications",    _notificationsOn);
    await prefs.setBool("dark_mode",        _darkMode);
  }

  // ── Edit profile bottom sheet ─────────────────────────────
  void _openEditSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final bioCtrl  = TextEditingController(text: _bio);
    String tempAvatar = _selectedAvatar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar picker
                const Text(
                  "Choose Avatar",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _avatars.map((emoji) {
                    final selected = tempAvatar == emoji;
                    return GestureDetector(
                      onTap: () => setSheet(() => tempAvatar = emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: selected
                              ? _primary.withOpacity(0.12)
                              : const Color(0xffF5F5F8),
                          borderRadius: BorderRadius.circular(14),
                          border: selected
                              ? Border.all(color: _primary, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Name field
                _inputField(
                  label: "Name",
                  controller: nameCtrl,
                  hint: "Your name",
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 14),

                // Bio field
                _inputField(
                  label: "Bio",
                  controller: bioCtrl,
                  hint: "A short bio...",
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _name           = nameCtrl.text.trim().isEmpty
                            ? "Quote Lover"
                            : nameCtrl.text.trim();
                        _bio            = bioCtrl.text.trim().isEmpty
                            ? "Collecting wisdom, one quote at a time."
                            : bioCtrl.text.trim();
                        _selectedAvatar = tempAvatar;
                      });
                      await _saveProfile();
                      if (mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffF5F5F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(icon, color: _primary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final catColor =
        _catColors[_favoriteCategory] ?? _primary;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F8),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _openEditSheet,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: _primary, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    "Edit",
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
             _buildProfileCard(),

            const SizedBox(height: 20),

             _buildStatsRow(),

            const SizedBox(height: 20),

             _buildSectionTitle("Favourite Category"),
            const SizedBox(height: 12),
            _buildCategoryPicker(),

            const SizedBox(height: 20),

             _buildSectionTitle("Settings"),
            const SizedBox(height: 12),
            _buildSettingsCard(),

            const SizedBox(height: 20),

             _buildSectionTitle("About"),
            const SizedBox(height: 12),
            _buildAboutCard(),

            const SizedBox(height: 16),

             Text(
              "QuoteVerse v1.0",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile card ──────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: -10,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: _openEditSheet,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _selectedAvatar,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name + bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _bio,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            value: "${widget.totalQuotes}",
            label: "Total\nQuotes",
            icon: Icons.format_quote_rounded,
            color: const Color(0xff7C4DFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            value: "${widget.favoriteCount}",
            label: "Saved\nQuotes",
            icon: Icons.favorite_rounded,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            value: "$_quotesRead",
            label: "Quotes\nRead",
            icon: Icons.auto_stories_rounded,
            color: const Color(0xff00897B),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ── Category picker ───────────────────────────────────────
  Widget _buildCategoryPicker() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final color = _catColors[cat] ?? _primary;
          final selected = _favoriteCategory == cat;
          return GestureDetector(
            onTap: () async {
              setState(() => _favoriteCategory = cat);
              await _saveProfile();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? color : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? color.withOpacity(0.3)
                        : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Settings card ─────────────────────────────────────────
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.notifications_rounded,
            iconColor: const Color(0xffFF6D00),
            title: "Daily Reminders",
            subtitle: "Get a quote every day",
            trailing: Switch.adaptive(
              value: _notificationsOn,
              activeColor: _primary,
              onChanged: (val) async {
                setState(() => _notificationsOn = val);
                await _saveProfile();
              },
            ),
          ),
          _divider(),
          _settingsTile(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xff5C6BC0),
            title: "Dark Mode",
            subtitle: "Coming soon",
            trailing: Switch.adaptive(
              value: _darkMode,
              activeColor: _primary,
              onChanged: (val) async {
                setState(() => _darkMode = val);
                await _saveProfile();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Dark mode coming soon!"),
                      backgroundColor: _primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
          ),
          _divider(),
          _settingsTile(
            icon: Icons.share_rounded,
            iconColor: const Color(0xff00897B),
            title: "Share App",
            subtitle: "Spread the inspiration",
            trailing: Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.star_rounded,
            iconColor: const Color(0xffF9A825),
            title: "Rate Us",
            subtitle: "Love the app? Let us know!",
            trailing: Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── About card ────────────────────────────────────────────
  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.info_rounded,
            iconColor: _primary,
            title: "About QuoteVerse",
            subtitle: "Version 1.0.0",
            trailing: Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
            onTap: () {},
          ),
          _divider(),
          _settingsTile(
            icon: Icons.privacy_tip_rounded,
            iconColor: const Color(0xff1565C0),
            title: "Privacy Policy",
            subtitle: "How we handle your data",
            trailing: Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _divider() => Divider(
    height: 1,
    indent: 72,
    endIndent: 16,
    color: Colors.grey.shade100,
  );
}