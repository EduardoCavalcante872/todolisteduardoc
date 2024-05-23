import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String name;
  String category;

  Task({required this.name, required this.category});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChecklistScreen(),
    );
  }
}

class ChecklistScreen extends StatefulWidget {
  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<Task> tasks = [];
  List<Task> archivedTasks = [];
  TextEditingController _taskNameController = TextEditingController();

  void _addTask() {
    setState(() {
      String taskName = _taskNameController.text;
      if (taskName.isNotEmpty) {
        tasks.add(Task(name: taskName, category: 'A fazer'));
        _taskNameController.clear();
      }
    });
  }

  void _changeStatus(int index, String newStatus) {
    setState(() {
      if (newStatus == 'Feito') {
        tasks[index].category = newStatus;
        _archiveOldTasksIfNecessary();
      } else {
        tasks[index].category = newStatus;
      }
    });
  }

  void _archiveOldTasksIfNecessary() {
    List<Task> doneTasks =
        tasks.where((task) => task.category == 'Feito').toList();
    if (doneTasks.length > 5) {
      Task oldestTask = doneTasks.first;
      tasks.remove(oldestTask);
      archivedTasks.add(oldestTask);
    }
  }

  void _navigateToArchivedTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ArchivedTasksScreen(archivedTasks: archivedTasks)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'To Do List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskNameController,
                    decoration: InputDecoration(
                      hintText: 'Nova tarefa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text('Adicionar'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildCategoryList('A fazer'),
                  _buildCategoryList('Fazendo'),
                  _buildCategoryList('Feito'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToArchivedTasks(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    List<Task> tasksToShow =
        tasks.where((task) => task.category == category).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: tasksToShow.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tasksToShow[index].name,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownButton<String>(
                      value: tasksToShow[index].category,
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != tasksToShow[index].category) {
                          _changeStatus(
                              tasks.indexWhere(
                                  (task) => task == tasksToShow[index]),
                              newValue);
                        }
                      },
                      items: <String>['A fazer', 'Fazendo', 'Feito']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ArchivedTasksScreen extends StatelessWidget {
  final List<Task> archivedTasks;

  ArchivedTasksScreen({required this.archivedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Antigas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
          itemCount: archivedTasks.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                archivedTasks[index].name,
                style: TextStyle(color: Colors.black),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
        ),
      ),
    );
  }
}
