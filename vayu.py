from pathlib import Path
import subprocess
import textwrap

PROJECT = Path("vayu_ai")

def write(path, content):
    file = PROJECT / path
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_text(textwrap.dedent(content).strip() + "\n", encoding="utf-8")
    print(f"Created: {file}")

# --------------------------------------------------
# Create Flutter project
# --------------------------------------------------

if not PROJECT.exists():
    print("Creating Flutter project...")
    subprocess.run(
        [
            "flutter",
            "create",
            "--org",
            "org.kakarot003",
            "--project-name",
            "vayu_ai",
            str(PROJECT),
        ],
        check=True,
    )

# --------------------------------------------------
# pubspec.yaml
# --------------------------------------------------

write("pubspec.yaml", r"""
name: vayu_ai
description: Vayu AI - AI buddy and work partner.
publish_to: "none"

version: 0.0.1+1

environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  shared_preferences: ^2.5.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
""")

# --------------------------------------------------
# main.dart
# --------------------------------------------------

write("lib/main.dart", r"""
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VayuApp(),
    ),
  );
}

class VayuApp extends StatelessWidget {
  const VayuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vayu AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const VayuHomePage(),
    );
  }
}

class VayuHomePage extends StatefulWidget {
  const VayuHomePage({super.key});

  @override
  State<VayuHomePage> createState() => _VayuHomePageState();
}

class _VayuHomePageState extends State<VayuHomePage> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, String>> messages = [];

  bool coreVisible = false;

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });

      messages.add({
        "role": "vayu",
        "text": VayuBehaviour.reply(text),
      });

      controller.clear();
    });
  }

  void showCore() {
    setState(() {
      coreVisible = !coreVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vayu AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Vayu Core",
            onPressed: showCore,
            icon: const Icon(Icons.blur_circular),
          ),
          IconButton(
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: Column(
        children: [
          if (coreVisible)
            const Padding(
              padding: EdgeInsets.all(16),
              child: VayuCore(),
            ),

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "Welcome, Sir.\n\n"
                      "Vayu is ready.\n"
                      "What are we building?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.5,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message["role"] == "user";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(
                            maxWidth: 330,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Text(
                            message["text"] ?? "",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Talk to Vayu...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: sendMessage,
                    child: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Vayu Behaviour Layer
// --------------------------------------------------

class VayuBehaviour {
  static String reply(String input) {
    final text = input.toLowerCase();

    if (text.contains("hello") ||
        text.contains("hi") ||
        text.contains("hey")) {
      return "Hello, Sir. I'm online. What are we working on?";
    }

    if (text.contains("wake up")) {
      return "Welcome home, Sir. Systems are online. What are we building tonight?";
    }

    if (text.contains("who are you")) {
      return "I'm Vayu, Sir. Your AI buddy and work partner.";
    }

    if (text.contains("time")) {
      final now = DateTime.now();
      return "It's ${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}, Sir.";
    }

    return "Understood, Sir. I'm ready to work through that with you.";
  }
}

// --------------------------------------------------
// Vayu Core
// --------------------------------------------------

class VayuCore extends StatefulWidget {
  const VayuCore({super.key});

  @override
  State<VayuCore> createState() => _VayuCoreState();
}

class _VayuCoreState extends State<VayuCore>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        return SizedBox(
          height: 220,
          width: double.infinity,
          child: CustomPaint(
            painter: CorePainter(controller.value),
          ),
        );
      },
    );
  }
}

class CorePainter extends CustomPainter {
  final double progress;

  CorePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 18; i++) {
      final angle =
          (i / 18) * 6.283185 + progress * 6.283185;

      final radius = 35.0 + (i % 5) * 12;

      final point = Offset(
        center.dx + radius * 1.5 * _cos(angle),
        center.dy + radius * _sin(angle),
      );

      canvas.drawCircle(
        point,
        2 + (i % 3),
        paint,
      );
    }

    canvas.drawCircle(
      center,
      28 + progress * 8,
      paint,
    );
  }

  double _cos(double value) {
    return value == 0 ? 1 : _trig(value, true);
  }

  double _sin(double value) {
    return _trig(value, false);
  }

  double _trig(double value, bool cosine) {
    // Small approximation is enough for this first visual prototype.
    double result = 0;
    double term = cosine ? 1 : value;

    for (int n = 0; n < 8; n++) {
      if (n > 0) {
        term *= -value * value /
            ((2 * n - (cosine ? 1 : 2)) *
             (2 * n - (cosine ? 0 : 1)));
      }

      result += term;
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant CorePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// --------------------------------------------------
// Settings
// --------------------------------------------------

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vayu Settings"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.palette),
            title: Text("Chat Themes"),
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text("Font"),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_customize),
            title: Text("Chat Layout"),
          ),
          ListTile(
            leading: Icon(Icons.emoji_emotions),
            title: Text("Emoji & Stickers"),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text("Developer Security"),
          ),
        ],
      ),
    );
  }
}
""")

# --------------------------------------------------
# Get dependencies
# --------------------------------------------------

print("\nRunning flutter pub get...")
subprocess.run(
    ["flutter", "pub", "get"],
    cwd=PROJECT,
    check=True,
)

print("\n======================================")
print("VAYU AI 0.0.1 PROJECT CREATED")
print("======================================")
print(f"Project folder: {PROJECT.resolve()}")
print("\nNext:")
print("cd vayu_ai")
print("flutter run")
print("\nTo build APK:")
print("flutter build apk --release")
