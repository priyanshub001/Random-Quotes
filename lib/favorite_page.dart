import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_model.dart';

class FavoritePage extends StatefulWidget {
  final List<Quote> favoriteQuotes;

  const FavoritePage({
    super.key,
    required this.favoriteQuotes,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<Quote> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = List.from(widget.favoriteQuotes);
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favs = _favorites.map((q) {
      return jsonEncode({
        "quote": q.quote,
        "author": q.author,
        "category": q.category,
      });
    }).toList();
    await prefs.setStringList("favorites", favs);
  }

  void _removeFromFavorites(Quote quote) async {
    setState(() {
      _favorites.removeWhere(
            (q) => q.quote == quote.quote && q.author == quote.author,
      );
      widget.favoriteQuotes.removeWhere(
            (q) => q.quote == quote.quote && q.author == quote.author,
      );
    });
    await _saveFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Removed from favorites"),
          backgroundColor: const Color(0xff7C4DFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F8),

      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Favorites",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        // Quote count badge
        actions: [
          if (_favorites.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff7C4DFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_favorites.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: _favorites.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xff7C4DFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 50,
              color: Color(0xff7C4DFF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Favorites Yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Tap the heart on any quote\nto save it here",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Favorites List UI
  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final quote = _favorites[index];
        return _buildQuoteCard(quote, index);
      },
    );
  }

  Widget _buildQuoteCard(Quote quote, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff7C4DFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quote.category,
                      style: const TextStyle(
                        color: Color(0xff7C4DFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () => _removeFromFavorites(quote),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Icon(
              Icons.format_quote,
              color: Color(0xff7C4DFF),
              size: 30,
            ),

            const SizedBox(height: 8),

            Text(
              quote.quote,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            const Divider(color: Color(0xffF0F0F0)),

            const SizedBox(height: 10),

            // Author
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xff7C4DFF).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      quote.author.isNotEmpty
                          ? quote.author[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        color: Color(0xff7C4DFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quote.author,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}