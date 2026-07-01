import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'category_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'quote_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Data ──────────────────────────────────────────────
  List<Quote> allQuotes = [];
  List<Quote> favoriteQuotes = [];
  Quote? currentQuote;

  // ── UI state ──────────────────────────────────────────
  int _bottomNavIndex = 0;
  String selectedCategory = "All Categories";

  final List<String> categories = const [
    "All Categories",
    "Motivation",
    "Life",
    "Love",
    "Leadership",
    "Friendship",
    "Success",
  ];

  // Each category gets its own accent swatch
  static const Map<String, Color> _catColors = {
    "All Categories": Color(0xff7C4DFF),
    "Motivation":     Color(0xffFF6D00),
    "Life":           Color(0xff00897B),
    "Love":           Color(0xffE91E63),
    "Leadership":     Color(0xff1565C0),
    "Friendship":     Color(0xff558B2F),
    "Success":        Color(0xffF9A825),
  };

  Color get _accent =>
      _catColors[selectedCategory] ?? const Color(0xff7C4DFF);

  // ── Lifecycle ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadQuotes();
    _loadFavorites();
  }

  // ── Persistence ───────────────────────────────────────
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = favoriteQuotes
        .map((q) => jsonEncode({
      "quote": q.quote,
      "author": q.author,
      "category": q.category,
    }))
        .toList();
    await prefs.setStringList("favorites", favs);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList("favorites");
    if (favs != null) {
      setState(() {
        favoriteQuotes =
            favs.map((item) => Quote.fromJson(jsonDecode(item))).toList();
      });
    }
  }

  Future<void> _loadQuotes() async {
    final data = await rootBundle.loadString('assets/quotes.json');
    final List jsonResult = json.decode(data);
    allQuotes = jsonResult.map((e) => Quote.fromJson(e)).toList();
    _generateRandomQuote();
  }

  // ── Business logic ────────────────────────────────────
  void _generateRandomQuote() {
    final filtered = selectedCategory == "All Categories"
        ? allQuotes
        : allQuotes
        .where((q) => q.category
        .toLowerCase()
        .contains(selectedCategory.toLowerCase()))
        .toList();

    if (filtered.isEmpty) return;

    setState(() {
      currentQuote = filtered[Random().nextInt(filtered.length)];
    });
  }

  bool _isFavorite() {
    if (currentQuote == null) return false;
    return favoriteQuotes.any((q) =>
    q.quote == currentQuote!.quote && q.author == currentQuote!.author);
  }

  Future<void> _toggleFavorite() async {
    if (currentQuote == null) return;
    if (_isFavorite()) {
      favoriteQuotes.removeWhere((q) =>
      q.quote == currentQuote!.quote && q.author == currentQuote!.author);
    } else {
      favoriteQuotes.add(currentQuote!);
    }
    setState(() {});
    await _saveFavorites();
  }

  void _copyQuote() {
    if (currentQuote == null) return;
    Clipboard.setData(
      ClipboardData(
          text: "${currentQuote!.quote}\n\n— ${currentQuote!.author}"),
    );
    _showSnack("Quote copied!", Icons.copy_rounded);
  }

  void _showSnack(String msg, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        ]),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // void _onBottomNavTap(int index) {
  //   if (index == 1) {
  //      Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const CategoryPage(),
  //       ),
  //     );
  //     return;
  //   }
  //   if (index == 2) {
  //      Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => FavoritePage(favoriteQuotes: favoriteQuotes),
  //       ),
  //     );
  //     return;
  //   }
  //   if (index == 3) {
  //      Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => ProfilePage(
  //           totalQuotes: allQuotes.length,
  //           favoriteCount: favoriteQuotes.length,
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   setState(() => _bottomNavIndex = index);
  // }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F8),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: currentQuote == null
          ? Center(
        child: CircularProgressIndicator(color: _accent),
      )
          : _buildBody(),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xffF5F5F8),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.format_quote, color: _accent, size: 22),
          const SizedBox(width: 6),
          const Text(
            "Quotes",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (ctx) => GestureDetector(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: const Icon(Icons.menu_rounded, color: Colors.black87),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FavoritePage(favoriteQuotes: favoriteQuotes),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: _accent, size: 18),
                if (favoriteQuotes.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    "${favoriteQuotes.length}",
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Drawer ────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accent, _accent.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.format_quote_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "QuoteVerse",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${allQuotes.length} quotes · ${favoriteQuotes.length} saved",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Nav items
            _drawerItem(
              icon: Icons.home_rounded,
              label: "Home",
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.favorite_rounded,
              label: "Favorites",
              badge: favoriteQuotes.isNotEmpty
                  ? "${favoriteQuotes.length}"
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FavoritePage(favoriteQuotes: favoriteQuotes),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.category_rounded,
              label: "Categories",
              onTap: () => Navigator.pop(context),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(color: Color(0xffEEEEEE)),
            ),

             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "CATEGORIES",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...categories.skip(1).map((cat) {
              final color = _catColors[cat] ?? const Color(0xff7C4DFF);
              final isSelected = selectedCategory == cat;
              return ListTile(
                dense: true,
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  cat,
                  style: TextStyle(
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: color, size: 18)
                    : null,
                onTap: () {
                  setState(() => selectedCategory = cat);
                  _generateRandomQuote();
                  Navigator.pop(context);
                },
              );
            }),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "QuoteVerse v1.0",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _accent),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          badge,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  // ── Body ──────────────────────────────────────────────
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
           SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = selectedCategory == cat;
                final color =
                    _catColors[cat] ?? const Color(0xff7C4DFF);
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    _generateRandomQuote();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? color.withOpacity(0.3)
                              : Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Quote card ────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative top-left blob
                  Positioned(
                    top: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Decorative bottom-right blob
                  Positioned(
                    bottom: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category pill + quote icon row
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentQuote!.category.isEmpty
                                    ? selectedCategory
                                    : currentQuote!.category
                                    .split(',')
                                    .first
                                    .trim(),
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.format_quote_rounded,
                              color: _accent.withOpacity(0.3),
                              size: 44,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quote text
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentQuote!.quote,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _accent,
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentQuote!.author,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action buttons row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              _actionBtn(
                                icon: Icons.copy_rounded,
                                label: "Copy",
                                onTap: _copyQuote,
                              ),
                              _dividerDot(),
                              _actionBtn(
                                icon: _isFavorite()
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                label: _isFavorite() ? "Saved" : "Save",
                                color: _isFavorite()
                                    ? Colors.red
                                    : null,
                                onTap: _toggleFavorite,
                              ),
                              _dividerDot(),
                              _actionBtn(
                                icon: Icons.share_rounded,
                                label: "Share",
                                onTap: () {
                                  _showSnack(
                                      "Share coming soon!",
                                      Icons.share_rounded);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── New Quote button ──────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _generateRandomQuote,
              // icon: const Icon(Icons.auto_awesome_rounded,
              //     color: Colors.white, size: 20),
              label: const Text(
                "New Quote",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                elevation: 0,
                shadowColor: _accent.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color ?? Colors.black54),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerDot() => Container(
    width: 1,
    height: 30,
    color: const Color(0xffDDDDDD),
  );

  // ── Bottom Nav ────────────────────────────────────────
  // Widget _buildBottomNav() {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
  //       ],
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: const BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //       child: BottomNavigationBar(
  //         currentIndex: _bottomNavIndex,
  //         onTap: _onBottomNavTap,
  //         selectedItemColor: _accent,
  //         unselectedItemColor: Colors.grey,
  //         type: BottomNavigationBarType.fixed,
  //         backgroundColor: Colors.white,
  //         elevation: 0,
  //         selectedLabelStyle: const TextStyle(
  //             fontWeight: FontWeight.w700, fontSize: 12),
  //         unselectedLabelStyle: const TextStyle(fontSize: 11),
  //         items: [
  //           const BottomNavigationBarItem(
  //             icon: Icon(Icons.home_outlined),
  //             activeIcon: Icon(Icons.home_rounded),
  //             label: "Home",
  //           ),
  //           const BottomNavigationBarItem(
  //             icon: Icon(Icons.category_outlined),
  //             activeIcon: Icon(Icons.category_rounded),
  //             label: "Categories",
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Badge(
  //               isLabelVisible: favoriteQuotes.isNotEmpty,
  //               label: Text("${favoriteQuotes.length}"),
  //               child: const Icon(Icons.favorite_border_rounded),
  //             ),
  //             activeIcon: const Icon(Icons.favorite_rounded),
  //             label: "Favorites",
  //           ),
  //           const BottomNavigationBarItem(
  //             icon: Icon(Icons.person_outline_rounded),
  //             activeIcon: Icon(Icons.person_rounded),
  //             label: "Profile",
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}