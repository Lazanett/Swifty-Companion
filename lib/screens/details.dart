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
      return;
    }
    login = args['login'];
    token = args['token'];
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() => _loading = true);
    final data = await UserService().fetchUserInfo(login, token);
    setState(() {
      userInfo = data;
      _loading = false;
    });
    //print("coucou");
  }
@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    appBar: AppBar(title: Text('Informations of $login')),
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
                                          userInfo!['image']['versions'] != null)
                                      ? CircleAvatar(
                                          radius: 100,
                                          backgroundImage: NetworkImage(
                                              userInfo!['image']['versions']['large']),
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
                                          Text('${userInfo!['displayname'] ?? 'N/A'}',
                                              style: const TextStyle(fontSize: 20)),
                                          Text('${userInfo!['login']}',
                                              style: const TextStyle(fontSize: 16)),
                                          Text('${userInfo!['email'] ?? 'N/A'}',
                                              style: const TextStyle(fontSize: 16)),
                                          Text('Evaluation points : ${userInfo!['correction_point']}',
                                              style: const TextStyle(fontSize: 16)),
                                          Text('Wallet : ${userInfo!['wallet']}',
                                              style: const TextStyle(fontSize: 16)),
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
                                        const Text('Skills',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
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
                                        const Text('Projects',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
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
      (c) => c['cursus_id'] == 21,
      orElse: () => cursusUsers.first,
    );

    if (cursus == null || cursus['level'] == null) return 0.0;

    return (cursus['level'] as num).toDouble();
  }

  Widget _buildSkills() {
    final cursusUsers = userInfo!['cursus_users'] as List<dynamic>;
    final cursus = cursusUsers.firstWhere(
      (c) => c['cursus_id'] == 21,
      orElse: () => cursusUsers.isNotEmpty ? cursusUsers.first : null,
    );

    if (cursus == null || cursus['skills'] == null) {
      return const Text('No skills found..');
    }

    final skills = cursus['skills'] as List<dynamic>;

    return skills.isEmpty
        ? const Text('No skills found.')
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              return ListTile(
                title: Text(skill['name']),
                subtitle: Text('Level : ${skill['level'].toStringAsFixed(2)}'),
              );
            },
          );
  }

  Widget _buildProjects() {
    final projects = userInfo!['projects_users'] as List<dynamic>?;

    if (projects == null || projects.isEmpty) {
      return const Text('No project completed.');
    }

    final finishedProjects = projects.where((p) => p['status'] == 'finished').toList();

    if (finishedProjects.isEmpty) {
      return const Text('No project completed.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: finishedProjects.length,
      itemBuilder: (context, index) {
        final p = finishedProjects[index];
        final validated = p['validated?'] == true;
        return ListTile(
          title: Text(p['project']['name']),
          subtitle: Text('Final note : ${p['final_mark'] ?? "N/A"}'),
          trailing: Icon(
            validated ? Icons.check_circle : Icons.cancel,
            color: validated ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}


Widget buildProgressBar(double currentLevel, double maxLevel) {
  final double percentage = (currentLevel / maxLevel).clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Global level : ${currentLevel.toStringAsFixed(2)} / $maxLevel',
          style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white, // fond gris clair
          borderRadius: BorderRadius.circular(6),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: percentage, // largeur proportionnelle
          child: Container(
            decoration: BoxDecoration(
              color:  Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    ],
  );
}