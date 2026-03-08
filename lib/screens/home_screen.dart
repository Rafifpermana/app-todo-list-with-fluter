import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_task_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await TaskDatabaseService.instance.getTasks();
    setState(() {});
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    final task = TaskModel(
      title: title.trim(),
      isDone: false,
    );

    await TaskDatabaseService.instance.createTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await TaskDatabaseService.instance.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTask(TaskModel task) async {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      isDone: !task.isDone,
    );

    await TaskDatabaseService.instance.updateTask(updatedTask);
    await loadTasks();
  }

  void showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tambah Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan task',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await addTask(controller.text);
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List - ${widget.userName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text('Belum ada task'),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (_) {
                toggleTask(task);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteTask(task.id!);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}