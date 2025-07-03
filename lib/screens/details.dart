import 'package:flutter/material.dart';
import '../services/user_service.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late String login;
  late String token;
  Map<String, dynamic>? userInfo;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || !args.containsKey('login') || !args.containsKey('token')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reload, go to home page',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/');
      });
      return;
    }

    login = args['login'] ?? '';
    token = args['token'] ?? '';

    if (userInfo == null) {
      _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    setState(() => _loading = true);
    final data = await UserService().fetchUserInfo(login);
    setState(() {
      userInfo = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return const Scaffold(
        body: Center(child: Text('Reload required, return to the home page')),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Informations of ${userInfo!['login'] ?? 'N/A'}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('Error loading data.'))
              : screenWidth < 375 || screenHeight <= 250
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Flexible(
                            flex: 4,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: (userInfo?['image'] is Map<String, dynamic> &&
                                            userInfo!['image']['versions'] is Map<String, dynamic>)
                                        ? ClipOval(
                                            child: SizedBox(
                                              width: 200,
                                              height: 200,
                                              child: Image.network(
                                                userInfo!['image']['versions']['large'] ?? '',
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) =>
                                                    const Icon(Icons.person, size: 100),
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(radius: 100, child: Icon(Icons.person)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${userInfo!['displayname'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                  fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${userInfo!['login'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.normal),
                                            ),
                                            Text(
                                              '${userInfo!['email'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.normal),
                                            ),
                                            Text(
                                              'Evaluation points : ${userInfo!['correction_point'] ?? 0}',
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.normal),
                                            ),
                                            Text(
                                              'Wallet : ${userInfo!['wallet'] ?? 0}',
                                              style: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.normal),
                                            ),
                                            buildProgressBar(_getGlobalLevel(), 21),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (screenHeight > 600)
                            Flexible(
                              flex: 6,
                              child: Row(
                                children: [
                                  // Section Skills
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Skills',
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              padding: EdgeInsets.zero,
                                              child: _buildSkills(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Section Projects
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Projects',
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: _buildProjects(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
    );
  }

  double _getGlobalLevel() {
    final cursusUsers = userInfo?['cursus_users'] as List<dynamic>?;
    if (cursusUsers == null || cursusUsers.isEmpty) return 0.0;
    final cursus = cursusUsers.firstWhere(
      (c) => c is Map<String, dynamic> && c['cursus_id'] == 21,
      orElse: () => cursusUsers.first,
    );
    if (cursus == null || cursus['level'] == null) return 0.0;
    final level = cursus['level'];
    return (level is num) ? level.toDouble() : 0.0;
  }

  Widget _buildSkills() {
    try {
      final cursusUsers = userInfo?['cursus_users'] as List<dynamic>?;
      if (cursusUsers == null || cursusUsers.isEmpty) return const Text('No skills found..');
      final cursus = cursusUsers.firstWhere(
        (c) => c is Map<String, dynamic> && c['cursus_id'] == 21,
        orElse: () => cursusUsers.first,
      );
      final skills = (cursus['skills'] as List<dynamic>?) ?? [];
      if (skills.isEmpty) return const Text('No skills found.');
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: skills.length,
        itemBuilder: (context, i) {
          final skill = skills[i] as Map<String, dynamic>? ?? {};
          final level = (skill['level'] is num) ? (skill['level'] as num).toDouble().toStringAsFixed(2) : '0.00';
          return ListTile(
            title: Text(skill['name'] ?? 'Unnamed skill'),
            subtitle: Text('Level : $level'),
          );
        },
      );
    } catch (_) {
      return const Text('No skills found..');
    }
  }

  Widget _buildProjects() {
    try {
      final projects = userInfo?['projects_users'] as List<dynamic>?;
      if (projects == null || projects.isEmpty) return const Text('No project completed.');
      final finished = projects.where((p) => p is Map<String, dynamic> && p['status'] == 'finished').toList();
      if (finished.isEmpty) return const Text('No project completed.');
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: finished.length,
        itemBuilder: (context, i) {
          final p = finished[i] as Map<String, dynamic>? ?? {};
          final project = p['project'] as Map<String, dynamic>? ?? {};
          final mark = p['final_mark']?.toString() ?? 'N/A';
          final validated = p['validated?'] == true;
          return ListTile(
            title: Text(project['name'] ?? 'Unnamed project'),
            subtitle: Text('Final note : $mark'),
            trailing: Icon(validated ? Icons.check_circle : Icons.cancel,
                           color: validated ? Colors.green : Colors.red),
          );
        },
      );
    } catch (_) {
      return const Text('No project completed.');
    }
  }
}

Widget buildProgressBar(double currentLevel, double maxLevel) {
  final percentage = (currentLevel / maxLevel).clamp(0.0, 1.0);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Global level : ${currentLevel.toStringAsFixed(2)} / $maxLevel',
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity, height: 12,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: percentage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800], borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    ],
  );
}
