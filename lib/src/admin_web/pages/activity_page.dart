import 'package:flutter/material.dart';
import '../../shared/index.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final LogService _logService = LogService();

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _logService.getLogs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              return ListTile(
                title: Text(log.user),
                subtitle: Text('${log.phone}\n${log.location}'),
                trailing: Text(log.success ? 'OK' : 'FAIL'),
              );
            },
          ),
        );
      },
    );
  }
}