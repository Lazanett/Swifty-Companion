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

    // Si déjà des infos, pas besoin de re-fetch
    if (userInfo == null) {
      _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    setState(() => _loading = true);
    final data = await UserService().fetchUserInfo(login); // 1 retrieve user info
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Informations of ${userInfo!['login'] ?? 'N/A'}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : userInfo == null
              ? const Center(child: Text('Error loading data.'))
              : screenHeight <= 250
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
                                    child: (userInfo?['image'] != null &&
                                            userInfo!['image'] is Map<String, dynamic> &&
                                            (userInfo!['image']['versions'] is Map<String, dynamic>))
                                        ? CircleAvatar(
                                            radius: 100,
                                            backgroundImage: NetworkImage(
                                              userInfo!['image']['versions']['large'] ??
                                                  '',
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 100,
                                            child: Icon(Icons.person),
                                          ),
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
    if (level is num) {
      return level.toDouble();
    }
    return 0.0;
  }

  Widget _buildSkills() {
    try {
      final cursusUsers = userInfo?['cursus_users'] as List<dynamic>?;

      if (cursusUsers == null || cursusUsers.isEmpty) {
        return const Text(
          'No skills found..',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }

      final cursus = cursusUsers.firstWhere(
        (c) => c is Map<String, dynamic> && c['cursus_id'] == 21,
        orElse: () => cursusUsers.first,
      );

      if (cursus == null || cursus['skills'] == null) {
        return const Text(
          'No skills found..',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }

      final skills = cursus['skills'] as List<dynamic>? ?? [];

      if (skills.isEmpty) {
        return const Text(
          'No skills found.',
          style: TextStyle(fontWeight: FontWeight.normal),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index] as Map<String, dynamic>? ?? {};
          final skillName = skill['name'] ?? 'Unnamed skill';
          final skillLevel = skill['level'] is num
              ? (skill['level'] as num).toDouble().toStringAsFixed(2)
              : '0.00';

          return ListTile(
            title: Text(skillName, style: const TextStyle(fontWeight: FontWeight.normal)),
            subtitle: Text('Level : $skillLevel'),
          );
        },
      );
    } catch (_) {
      return const Text(
        'No skills found..',
        style: TextStyle(fontWeight: FontWeight.normal),
      );
    }
  }

  Widget _buildProjects() {
    try {
      final projects = userInfo?['projects_users'] as List<dynamic>?;

      if (projects == null || projects.isEmpty) {
        return const Text('No project completed.');
      }

      final finishedProjects = projects.where((p) {
        if (p is Map<String, dynamic>) {
          return p['status'] == 'finished';
        }
        return false;
      }).toList();

      if (finishedProjects.isEmpty) {
        return const Text('No project completed.');
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: finishedProjects.length,
        itemBuilder: (context, index) {
          final p = finishedProjects[index] as Map<String, dynamic>? ?? {};
          final project = p['project'] as Map<String, dynamic>? ?? {};
          final projectName = project['name'] ?? 'Unnamed project';
          final finalMark = p['final_mark']?.toString() ?? 'N/A';
          final validated = p['validated?'] == true;

          return ListTile(
            title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.normal)),
            subtitle: Text('Final note : $finalMark'),
            trailing: SizedBox(
              width: 24,
              child: Icon(
                validated ? Icons.check_circle : Icons.cancel,
                color: validated ? Colors.green : Colors.red,
              ),
            )
          );
        },
      );
    } catch (_) {
      return const Text('No project completed.');
    }
  }
}

Widget buildProgressBar(double currentLevel, double maxLevel) {
  final double percentage = (currentLevel / maxLevel).clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Global level : ${currentLevel.toStringAsFixed(2)} / $maxLevel',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: percentage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    ],
  );
}
