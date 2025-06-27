import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // avatar
          CircleAvatar(
            radius: 60,
            backgroundImage: const AssetImage('assets/pet_placeholder.jpg'),
          ),
          const SizedBox(height: 16),
          Text('Lucky',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),

          const SizedBox(height: 24),

          _glassCard(context, 'Pet Info', [
            _row('Breed', 'Labrador Retriever'),
            _row('Age', '3 years'),
            _row('Weight', '24 kg'),
          ]),
          const SizedBox(height: 16),
          _glassCard(context, 'Owner', [
            _row('Name', 'John Doe'),
            _row('Phone', '+91 98765 43210'),
            _row('Email', 'john@example.com'),
          ]),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
            ),
          )
        ],
      ),
    );
  }

  // Re-usable glass-morphism card
  Widget _glassCard(BuildContext ctx, String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 12),
          ...rows
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ],
        ),
      );
}
