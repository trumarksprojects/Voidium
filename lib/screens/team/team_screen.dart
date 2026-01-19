import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      const Color(0xFF06B6D4).withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.groups,
                  size: 50,
                  color: Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Team Feature',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Join or create a team to mine together!\nEarn bonus rewards and compete with other teams.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Team creation coming soon!'),
                        backgroundColor: Color(0xFF06B6D4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                  child: const Text('CREATE TEAM'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Join team coming soon!'),
                      backgroundColor: Color(0xFF06B6D4),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF06B6D4)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'JOIN TEAM',
                  style: TextStyle(color: Color(0xFF06B6D4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
