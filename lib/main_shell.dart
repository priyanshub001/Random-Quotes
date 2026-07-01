import 'package:flutter/material.dart';

import 'category_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'quote_model.dart';
import 'home_page.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;


  List<Quote> favoriteQuotes = [];
  int totalQuotes = 0;

  static const _accent = Color(0xff7C4DFF);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const CategoryPage(),
      FavoritePage(favoriteQuotes: favoriteQuotes),
      ProfilePage(
        totalQuotes: totalQuotes,
        favoriteCount: favoriteQuotes.length,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            selectedItemColor: _accent,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category_rounded),
                label: "Categories",
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: favoriteQuotes.isNotEmpty,
                  label: Text("${favoriteQuotes.length}"),
                  child: const Icon(Icons.favorite_border_rounded),
                ),
                activeIcon: const Icon(Icons.favorite_rounded),
                label: "Favorites",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}