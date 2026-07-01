import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quote_model.dart';


class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Quote> allQuotes = [];
  List<Quote> favoriteQuotes = [];
  bool isLoading = true;

   static const List<Map<String, dynamic>> _categories = [
    {
      "name": "Motivation",
      "icon": Icons.bolt_rounded,
      "color": Color(0xffFF6D00),
      "desc": "Push your limits every day",
    },
    {
      "name": "Life",
      "icon": Icons.spa_rounded,
      "color": Color(0xff00897B),
      "desc": "Wisdom for the journey",
    },
    {
      "name": "Love",
      "icon": Icons.favorite_rounded,
      "color": Color(0xffE91E63),
      "desc": "Words from the heart",
    },
    {
      "name": "Leadership",
      "icon": Icons.emoji_events_rounded,
      "color": Color(0xff1565C0),
      "desc": "Lead with vision & purpose",
    },
    {
      "name": "Friendship",
      "icon": Icons.people_rounded,
      "color": Color(0xff558B2F),
      "desc": "Bonds that never break",
    },
    {
      "name": "Success",
      "icon": Icons.trending_up_rounded,
      "color": Color(0xffF9A825),
      "desc": "On the road to greatness",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load quotes
    final data = await rootBundle.loadString('assets/quotes.json');
    final List jsonResult = json.decode(data);
    allQuotes = jsonResult.map((e) => Quote.fromJson(e)).toList();

    // Load favorites
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList("favorites");
    if (favs != null) {
      favoriteQuotes =
          favs.map((item) => Quote.fromJson(jsonDecode(item))).toList();
    }

    setState(() => isLoading = false);
  }

  int _quoteCount(String category) => allQuotes
      .where((q) =>
      q.category.toLowerCase().contains(category.toLowerCase()))
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F8),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Categories",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Text(
            "${allQuotes.length} quotes across ${_categories.length} categories",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

           Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, i) =>
                  _buildCategoryCard(_categories[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final Color color = cat["color"] as Color;
    final IconData icon = cat["icon"] as IconData;
    final String name = cat["name"] as String;
    final String desc = cat["desc"] as String;
    final int count = _quoteCount(name);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryQuotesPage(
            category: name,
            color: color,
            icon: icon,
            allQuotes: allQuotes,
            favoriteQuotes: favoriteQuotes,
            onFavoritesUpdated: (updated) {
              setState(() => favoriteQuotes = updated);
            },
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
             Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon box
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),

                  const Spacer(),

                  // Category name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Quote count pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$count quotes",
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CategoryQuotesPage extends StatefulWidget {
  final String category;
  final Color color;
  final IconData icon;
  final List<Quote> allQuotes;
  final List<Quote> favoriteQuotes;
  final ValueChanged<List<Quote>> onFavoritesUpdated;

  const CategoryQuotesPage({
    super.key,
    required this.category,
    required this.color,
    required this.icon,
    required this.allQuotes,
    required this.favoriteQuotes,
    required this.onFavoritesUpdated,
  });

  @override
  State<CategoryQuotesPage> createState() => _CategoryQuotesPageState();
}

class _CategoryQuotesPageState extends State<CategoryQuotesPage> {
  late List<Quote> _quotes;
  late List<Quote> _favorites;
  late List<Quote> _filtered;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favoriteQuotes);
    _quotes = widget.allQuotes
        .where((q) => q.category
        .toLowerCase()
        .contains(widget.category.toLowerCase()))
        .toList()
      ..shuffle(Random());
    _filtered = List.from(_quotes);

    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_quotes)
          : _quotes
          .where((quote) =>
      quote.quote.toLowerCase().contains(q) ||
          quote.author.toLowerCase().contains(q))
          .toList();
    });
  }

  bool _isFav(Quote q) =>
      _favorites.any((f) => f.quote == q.quote && f.author == q.author);

  Future<void> _toggleFav(Quote quote) async {
    if (_isFav(quote)) {
      _favorites.removeWhere(
              (f) => f.quote == quote.quote && f.author == quote.author);
    } else {
      _favorites.add(quote);
    }
    setState(() {});
    widget.onFavoritesUpdated(_favorites);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    final favs = _favorites
        .map((q) => jsonEncode({
      "quote": q.quote,
      "author": q.author,
      "category": q.category,
    }))
        .toList();
    await prefs.setStringList("favorites", favs);
  }

  void _copyQuote(Quote quote) {
    Clipboard.setData(
        ClipboardData(text: "${quote.quote}\n\n— ${quote.author}"));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text("Quote copied!",
              style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: widget.color,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                "${_filtered.length} quotes",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          _filtered.isEmpty
              ? SliverFillRemaining(child: _buildEmpty())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildQuoteCard(_filtered[i]),
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: widget.color,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Content
              Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              "${_quotes.length} quotes",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: "Search quotes or authors…",
            hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon:
            Icon(Icons.search_rounded, color: widget.color, size: 22),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.grey, size: 20),
              onPressed: () {
                _searchCtrl.clear();
                FocusScope.of(context).unfocus();
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No quotes found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try a different search term",
            style:
            TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Quote card ───────────────────────────────────────────
  Widget _buildQuoteCard(Quote quote) {
    final fav = _isFav(quote);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote icon
            Icon(Icons.format_quote_rounded,
                color: widget.color.withOpacity(0.35), size: 32),

            const SizedBox(height: 8),

            // Quote text
            Text(
              quote.quote,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 14),

            // Divider
            Divider(color: Colors.grey.shade100),

            const SizedBox(height: 10),

             Row(
              children: [
                 Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      quote.author.isNotEmpty
                          ? quote.author[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quote.author,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                 _iconActionBtn(
                  icon: Icons.copy_rounded,
                  color: Colors.grey.shade400,
                  onTap: () => _copyQuote(quote),
                ),
                const SizedBox(width: 4),

                 _iconActionBtn(
                  icon: fav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: fav ? Colors.red : Colors.grey.shade400,
                  onTap: () => _toggleFav(quote),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}