import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'profile_view.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const DashboardView(),
    const HistoryView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1565C0),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        child: SafeArea(
          bottom: true,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.analytics_rounded, color: _currentIndex == 0 ? Colors.white : Colors.white60),
                    onPressed: () => setState(() => _currentIndex = 0),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.history_toggle_off_rounded, color: _currentIndex == 1 ? Colors.white : Colors.white60),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.person_outline_rounded, color: _currentIndex == 2 ? Colors.white : Colors.white60),
                    onPressed: () => setState(() => _currentIndex = 2),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white60),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}