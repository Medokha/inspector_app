import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Icon(Icons.support_agent_outlined, size: 80, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'نحن هنا لمساعدتك',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'إذا كنت تواجه أي مشاكل تقنية في استخدام التطبيق، يمكنك التواصل مع فريق الدعم الفني عبر القنوات التالية:',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          _SupportCard(
            title: 'البريد الإلكتروني',
            subtitle: 'support@waqfland.gov.eg',
            icon: Icons.email_outlined,
            color:  theme.colorScheme.primary,
            onTap: () => _launchUrl('mailto:support@waqfland.gov.eg'),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            title: 'رقم الهاتف',
            subtitle: '+20 123 456 7890',
            icon: Icons.phone_outlined,
            color:  theme.colorScheme.primary,

            onTap: () => _launchUrl('tel:+201234567890'),
          ),
          const SizedBox(height: 16),
          _SupportCard(
            title: 'واتساب',
            subtitle: 'تواصل مباشر عبر الواتساب',
            icon: Icons.chat_outlined,            color:  theme.colorScheme.primary,

            onTap: () => _launchUrl('https://wa.me/201234567890'),
          ),
          
          const SizedBox(height: 48),

        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color:color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_left, size: 20),
        onTap: onTap,
      ),
    );
  }
}
