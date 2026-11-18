import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../localization/app_strings.dart';

class AppBottomBar extends ConsumerWidget {
  final int currentIndex;

  const AppBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final unreadCount = ref.watch(unreadConversationsCountProvider).value ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textMuted,
        selectedFontSize: 11.5,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        onTap: (index) {
          if (index == currentIndex) return;
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/search-rides');
              break;
            case 2:
              context.go('/my-travel');
              break;
            case 3:
              context.go('/conversations');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            activeIcon: const Icon(Icons.home_filled),
            label: s.navHomeText,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_rounded),
            activeIcon: const Icon(Icons.search_rounded),
            label: s.navSearchText,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.commute_outlined),
            activeIcon: const Icon(Icons.commute_rounded),
            label: s.navMyTravelText,
          ),
          BottomNavigationBarItem(
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            activeIcon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: s.navMessagesText,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: s.navProfileText,
          ),
        ],
      ),
    );
  }
}
