import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/chat/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/chat/presentation/screens/new_chat_screen.dart';
import '../../features/chat/presentation/screens/new_group_screen.dart';
import '../../features/live/presentation/screens/live_list_screen.dart';
import '../../features/live/presentation/screens/live_room_screen.dart';
import '../../features/bluetooth/presentation/screens/ble_home_screen.dart';
import '../../features/bluetooth/presentation/screens/ble_chat_screen.dart';
import '../../features/stories/presentation/screens/story_viewer_screen.dart';
import '../../features/stories/presentation/screens/story_camera_screen.dart';
import '../../features/channels/presentation/screens/channels_screen.dart';
import '../../features/channels/presentation/screens/channel_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/calls/presentation/screens/call_screen.dart';
import '../constants/app_constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Splash → if session: Home, else Login
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupScreen()),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, s) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/live',
            pageBuilder: (_, s) => const NoTransitionPage(child: LiveListScreen()),
          ),
          GoRoute(
            path: '/ble',
            pageBuilder: (_, s) => const NoTransitionPage(child: BleHomeScreen()),
          ),
          GoRoute(
            path: '/channels',
            pageBuilder: (_, s) => const NoTransitionPage(child: ChannelsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, s) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(path: '/chat/:id', builder: (_, s) => ChatRoomScreen(chatId: s.pathParameters['id']!)),
      GoRoute(path: '/chat/:id/info', builder: (_, s) => ChatRoomScreen(chatId: s.pathParameters['id']!, showInfo: true)),
      GoRoute(path: '/new-chat', builder: (_, __) => const NewChatScreen()),
      GoRoute(path: '/new-group', builder: (_, __) => const NewGroupScreen()),
      GoRoute(path: '/live/:id', builder: (_, s) => LiveRoomScreen(roomId: s.pathParameters['id']!)),
      GoRoute(path: '/ble/chat/:id', builder: (_, s) => BleChatScreen(peerId: s.pathParameters['id']!)),
      GoRoute(path: '/story/:userId', builder: (_, s) => StoryViewerScreen(userId: s.pathParameters['userId']!)),
      GoRoute(path: '/story/camera', builder: (_, __) => const StoryCameraScreen()),
      GoRoute(path: '/channel/:id', builder: (_, s) => ChannelDetailScreen(channelId: s.pathParameters['id']!)),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/call/:id', builder: (_, s) => CallScreen(callId: s.pathParameters['id']!)),
    ],
    errorBuilder: (_, s) => Scaffold(
      body: Center(child: Text('Route not found: ${s.uri}')),
    ),
  );
});

/// Wraps the bottom-nav shell. The home screen decides which tab to show
/// based on the current location, so all 5 tabs share state.
class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/live')) index = 1;
    else if (location.startsWith('/ble')) index = 2;
    else if (location.startsWith('/channels')) index = 3;
    else if (location.startsWith('/profile')) index = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/live'); break;
            case 2: context.go('/ble'); break;
            case 3: context.go('/channels'); break;
            case 4: context.go('/profile'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.sensors), selectedIcon: Icon(Icons.sensors), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.bluetooth), selectedIcon: Icon(Icons.bluetooth), label: 'Mesh'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Channels'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
