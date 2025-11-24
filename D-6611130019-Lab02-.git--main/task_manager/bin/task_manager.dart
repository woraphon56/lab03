import 'dart:io';
import 'package:task_manager/task.dart';
import 'package:task_manager/task_manager.dart';

import 'package:task_manager/storage.dart';

// Make main async to use await
Future<void> main(List<String> arguments) async {
  print('Welcome to Task Manager CLI!');
  await runApp();
}

Future<void> runApp() async {
  final manager = TaskManager();
  final storage = TaskStorage('tasks.json');
  
  // Load existing tasks
  print('\n--- Loading Tasks ---');
  final loadedTasks = await storage.loadTasks();
  for (var task in loadedTasks) {
    manager.addOrReplaceTask(task);
  }
  
  // Add new tasks if none exist
  if (manager.allTasks.isEmpty) {
    print('No tasks found. Adding sample tasks...');
    manager.addTask(Task(
      id: '1',
      title: 'Learn Async Programming',
      dueDate: DateTime.now().add(Duration(days: 3)),
    ));
    manager.addTask(Task(
      id: '2',
      title: 'Master Future and await',
    ));
  }
  
  // Interactive CRUD menu
  String? prompt(String message) {
    stdout.write(message);
    return stdin.readLineSync()?.trim();
  }

  void listTasks() {
    print('\n--- Current Tasks ---');
    if (manager.allTasks.isEmpty) {
      print('No tasks.');
      return;
    }
    for (var t in manager.allTasks) {
      print('${t.id}: $t');
    }
  }

  Future<void> doAdd() async {
    final id = prompt('Enter id: ');
    if (id == null || id.isEmpty) { print('Invalid id'); return; }
    final title = prompt('Enter title: ') ?? '';
    final desc = prompt('Enter description (optional): ') ?? '';
    final dueRaw = prompt('Enter due date (YYYY-MM-DD) or blank: ');
    DateTime? due;
    if (dueRaw != null && dueRaw.isNotEmpty) {
      due = DateTime.tryParse(dueRaw);
      if (due == null) print('Invalid date format, ignoring due date.');
    }

    final added = manager.addTask(Task(id: id, title: title, description: desc, dueDate: due));
    print(added ? 'Task added.' : 'Task id already exists. Use update or addOrReplace.');
  }

  Future<void> doUpdate() async {
    final id = prompt('Enter id to update: ');
    if (id == null || id.isEmpty) return;
    final existing = manager.findTaskById(id);
    if (existing == null) { print('Task not found'); return; }
    final title = prompt('Enter new title (blank to keep): ');
    final desc = prompt('Enter new description (blank to keep): ');
    final dueRaw = prompt('Enter new due date (YYYY-MM-DD) or blank to clear/keep: ');
    DateTime? due;
    if (dueRaw != null && dueRaw.isNotEmpty) {
      due = DateTime.tryParse(dueRaw);
      if (due == null) print('Invalid date format, ignoring due date change.');
    }
    final completedRaw = prompt('Is completed? (y/n/blank to keep): ');
    bool? isCompleted;
    if (completedRaw != null) {
      if (completedRaw.toLowerCase() == 'y') isCompleted = true;
      else if (completedRaw.toLowerCase() == 'n') isCompleted = false;
    }
    final ok = manager.updateTask(id,
      title: (title != null && title.isNotEmpty) ? title : null,
      description: (desc != null && desc.isNotEmpty) ? desc : null,
      dueDate: dueRaw != null && dueRaw.isEmpty ? null : due,
      isCompleted: isCompleted,
    );
    print(ok ? 'Task updated.' : 'Update failed.');
  }

  void doDelete() {
    final id = prompt('Enter id to delete: ');
    if (id == null || id.isEmpty) return;
    final ok = manager.removeTask(id);
    print(ok ? 'Task removed.' : 'Task not found.');
  }

  void doMark(bool complete) {
    final id = prompt('Enter id: ');
    if (id == null || id.isEmpty) return;
    final ok = complete ? manager.markComplete(id) : manager.markIncomplete(id);
    print(ok ? (complete ? 'Marked complete.' : 'Marked incomplete.') : 'Task not found.');
  }

  Future<void> doSave() async {
    print('\n--- Saving Tasks ---');
    await storage.saveTasks(manager.allTasks);
  }

  void doClear() {
    final confirm = prompt('Clear ALL tasks? Type YES to confirm: ');
    if (confirm == 'YES') {
      manager.clearAllTasks();
      print('All tasks cleared.');
    } else {
      print('Aborted.');
    }
  }

  print('\n--- Interactive Task Manager (CRUD) ---');
  while (true) {
    print('\nChoose: (L)ist (A)dd (U)pdate (D)elete (C)lear (M)arkComplete (I)ncomplete (S)ave (Q)uit');
    final choice = prompt('> ');
    if (choice == null) continue;
    final cmd = choice.trim().toLowerCase();
    if (cmd == 'l') listTasks();
    else if (cmd == 'a') await doAdd();
    else if (cmd == 'u') await doUpdate();
    else if (cmd == 'd') doDelete();
    else if (cmd == 'c') doClear();
    else if (cmd == 'm') doMark(true);
    else if (cmd == 'i') doMark(false);
    else if (cmd == 's') await doSave();
    else if (cmd == 'q') {
      final saveExit = prompt('Save before exit? (y/n): ');
      if (saveExit != null && saveExit.toLowerCase() == 'y') await doSave();
      break;
    } else {
      print('Unknown command');
    }
  }

  // Simulate async operation
  print('\n--- Testing Async Delay ---');
  await storage.simulateNetworkDelay();
  print('\nTask Manager session complete!');
}