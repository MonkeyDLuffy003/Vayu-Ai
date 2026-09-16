import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
      ],
      child: const VayuApp(),
    ),
  );
}

// ============================================================
// PROVIDERS
// ============================================================

final preferencesProvider =
    Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeModeProvider =
    StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});

final currentTabProvider =
    StateProvider<int>((ref) {
  return 0;
});

final vayuCoreStateProvider =
    StateProvider<VayuCoreState>((ref) {
  return VayuCoreState.idle;
});

// ============================================================
// VAYU CORE STATE
// ============================================================

enum VayuCoreState {
  idle,
  listening,
  thinking,
  speaking,
  warning,
}

// ============================================================
// VAYU APP
// ============================================================

class VayuApp extends ConsumerWidget {
  const VayuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vayu AI',

      themeMode: themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFF05070D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C4DFF),
          secondary: Color(0xFF00BCD4),
        ),
      ),

      home: const VayuHome(),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class VayuHome extends ConsumerWidget {
  const VayuHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab =
        ref.watch(currentTabProvider);

    final screens = [
      const HomeScreen(),
      const ChatScreen(),
      const TopicsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[currentTab],
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: currentTab,

        onDestinationSelected: (index) {
          ref
              .read(currentTabProvider.notifier)
              .state = index;
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
                Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon:
                Icon(Icons.chat_bubble),
            label: 'Chat',
          ),

          NavigationDestination(
            icon: Icon(Icons.notes_outlined),
            selectedIcon:
                Icon(Icons.notes),
            label: 'Topics',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coreState =
        ref.watch(vayuCoreStateProvider);

    return Column(
      children: [

        const SizedBox(height: 25),

        const Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 28,
              ),

              SizedBox(width: 10),

              Text(
                'Vayu AI',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // VAYU CORE
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                ref
                    .read(
                      vayuCoreStateProvider
                          .notifier,
                    )
                    .state =
                    VayuCoreState.thinking;
              },
              child: const VayuCore(),
            ),
          ),
        ),

        Text(
          _stateText(coreState),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Your AI companion',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 25),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ref
                    .read(currentTabProvider
                        .notifier)
                    .state = 1;
              },
              icon: const Icon(
                Icons.chat,
              ),
              label: const Text(
                'Talk to Vayu',
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  String _stateText(VayuCoreState state) {
    switch (state) {
      case VayuCoreState.idle:
        return 'Vayu is ready';

      case VayuCoreState.listening:
        return 'Listening...';

      case VayuCoreState.thinking:
        return 'Thinking...';

      case VayuCoreState.speaking:
        return 'Speaking...';

      case VayuCoreState.warning:
        return 'Attention required';
    }
  }
}

// ============================================================
// VAYU CORE
// ============================================================

class VayuCore extends StatefulWidget {
  const VayuCore({super.key});

  @override
  State<VayuCore> createState() =>
      _VayuCoreState();
}

class _VayuCoreState extends State<VayuCore>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(260, 260),
          painter: VayuCorePainter(
            animation:
                controller.value,
          ),
        );
      },
    );
  }
}

// ============================================================
// VAYU CORE PAINTER
// ============================================================

class VayuCorePainter
    extends CustomPainter {

  final double animation;

  VayuCorePainter({
    required this.animation,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width * 0.22;

    // Core
    final corePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader =
              RadialGradient(
            colors: const [
              Color(0xFFFFFFFF),
              Color(0xFF7C4DFF),
              Color(0xFF00BCD4),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius: radius * 2,
            ),
          );

    canvas.drawCircle(
      center,
      radius * 2,
      corePaint,
    );

    // Energy rings
    final ringPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final ringRadius =
          radius +
          25 +
          (i * 18);

      canvas.drawCircle(
        center,
        ringRadius,
        ringPaint,
      );
    }

    // Moving particles
    final particlePaint =
        Paint()
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 36; i++) {
      final angle =
          animation *
              6.28318 +
          (i * 6.28318 / 36);

      final orbit =
          radius +
          35 +
          ((i % 5) * 9);

      final x =
          center.dx +
          (orbit *
              _cos(angle));

      final y =
          center.dy +
          (orbit *
              _sin(angle));

      canvas.drawCircle(
        Offset(x, y),
        2.2,
        particlePaint,
      );
    }
  }

  double _sin(double x) {
    return _approxSin(x);
  }

  double _cos(double x) {
    return _approxSin(
      x + 1.57079632679,
    );
  }

  double _approxSin(double x) {
    while (x > 3.14159265359) {
      x -= 6.28318530718;
    }

    while (x < -3.14159265359) {
      x += 6.28318530718;
    }

    return x -
        (x * x * x / 6) +
        (x * x * x * x * x / 120);
  }

  @override
  bool shouldRepaint(
    covariant VayuCorePainter oldDelegate,
  ) {
    return oldDelegate.animation !=
        animation;
  }
}

// ============================================================
// CHAT SCREEN
// ============================================================

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  final TextEditingController controller =
      TextEditingController();

  final List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Chat with Vayu',
              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Start a conversation with Vayu.',
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount:
                      messages.length,
                  itemBuilder:
                      (context, index) {
                    return Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                14),
                        child: Text(
                          messages[index],
                        ),
                      ),
                    );
                  },
                ),
        ),

        Padding(
          padding:
              const EdgeInsets.all(12),
          child: Row(
            children: [

              Expanded(
                child: TextField(
                  controller:
                      controller,
                  decoration:
                      const InputDecoration(
                    hintText:
                        'Message Vayu...',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                icon: const Icon(
                  Icons.send,
                ),
                onPressed: () {
                  final text =
                      controller.text.trim();

                  if (text.isEmpty) {
                    return;
                  }

                  setState(() {
                    messages.add(
                      'You: $text',
                    );

                    messages.add(
                      'Vayu: I received your message. AI connection will be added next.',
                    );
                  });

                  controller.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TOPICS
// ============================================================

class TopicsScreen
    extends StatelessWidget {

  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            'Saved Topics',
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Center(
            child: Text(
              'Topic memory will be added next.',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen
    extends ConsumerWidget {

  const SettingsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListView(
      padding:
          const EdgeInsets.all(20),
      children: [

        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        ListTile(
          leading:
              const Icon(Icons.palette),
          title:
              const Text('Appearance'),
          subtitle:
              const Text(
                'Theme and visual settings',
              ),
          onTap: () {
            final current =
                ref.read(
                    themeModeProvider);

            ref
                .read(
                  themeModeProvider
                      .notifier,
                )
                .state =
                current ==
                        ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
          },
        ),

        ListTile(
          leading:
              const Icon(Icons.text_fields),
          title:
              const Text('Font'),
          subtitle:
              const Text(
                'Font settings will be added',
              ),
          onTap: () {},
        ),

        ListTile(
          leading:
              const Icon(Icons.security),
          title:
              const Text('Developer'),
          subtitle:
              const Text(
                'Protected developer settings',
              ),
          onTap: () {},
        ),

        ListTile(
          leading:
              const Icon(Icons.notifications),
          title:
              const Text('Permissions'),
          subtitle:
              const Text(
                'Background, microphone and notifications',
              ),
          onTap: () {},
        ),

        ListTile(
          leading:
              const Icon(Icons.info_outline),
          title:
              const Text('About Vayu'),
          subtitle:
              const Text(
                'Vayu AI 0.0.1',
              ),
          onTap: () {},
        ),
      ],
    );
  }
}
