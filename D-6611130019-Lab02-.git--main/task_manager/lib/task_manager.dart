import 'task.dart';

// Manages collection of tasks
class TaskManager {
  // Private list of tasks - only accessible within class
  final List<Task> _tasks = [];
  
  // Private map for quick task lookup by ID
  final Map<String, Task> _taskMap = {};
  
  // Set of task IDs for uniqueness checking
  final Set<String> _taskIds = {};
  
  // Getter for all tasks - returns unmodifiable list
  List<Task> get allTasks => List.unmodifiable(_tasks);
  
  // Getter for pending tasks only
  List<Task> get pendingTasks => 
      _tasks.where((task) => !task.isCompleted).toList();
  
  // Getter for completed tasks only
  List<Task> get completedTasks => 
      _tasks.where((task) => task.isCompleted).toList();
  
  // Add a new task
  bool addTask(Task task) {
    // Check if task ID already exists
    if (_taskIds.contains(task.id)) {
      return false; // Task ID must be unique
    }
    
    _tasks.add(task);
    _taskMap[task.id] = task;
    _taskIds.add(task.id);
    return true;
  }
  
  // Find task by ID - returns null if not found
  Task? findTaskById(String id) {
    return _taskMap[id];
  }
  
  // Remove task by ID
  bool removeTask(String id) {
    final task = _taskMap[id];
    if (task == null) {
      return false;
    }
    
    _tasks.remove(task);
    _taskMap.remove(id);
    _taskIds.remove(id);
    return true;
  }
  
  // Get tasks due within specified days
  List<Task> getTasksDueWithin(int days) {
    final deadline = DateTime.now().add(Duration(days: days));
    return _tasks.where((task) {
      final due = task.dueDate;
      return due != null && 
             due.isBefore(deadline) && 
             !task.isCompleted;
    }).toList();
  }
  
  // Count tasks by status
  Map<String, int> getTaskStats() {   
    return {
      'total': _tasks.length,
      'pending': pendingTasks.length,
      'completed': completedTasks.length,
      'overdue': _tasks.where((t) => t.isOverdue()).length,
    };
  }
  // Count tasks by Due Date (returns map keyed by YYYY-MM-DD)
  Map<String, int> countTasksByDueDate() {
    final Map<String, int> counts = {};
    for (final task in _tasks) {
      final due = task.dueDate;
      if (due == null) continue;
      final dateKey =
          '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
      counts[dateKey] = (counts[dateKey] ?? 0) + 1;
    }
    // Return sorted by date string (ascending)
    return Map.fromEntries(counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }
  
  // Update an existing task's mutable fields. Returns true if updated.
  bool updateTask(String id, {String? title, String? description, DateTime? dueDate, bool? isCompleted}) {
    final task = _taskMap[id];
    if (task == null) return false;

    if (title != null) task.title = title;
    if (description != null) task.description = description;
    if (dueDate != null) task.dueDate = dueDate;
    if (isCompleted != null) task.isCompleted = isCompleted;
    return true;
  }

  // Add or replace a task: if an existing task with same id exists, replace it.
  void addOrReplaceTask(Task task) {
    final existing = _taskMap[task.id];
    if (existing != null) {
      final index = _tasks.indexOf(existing);
      if (index != -1) {
        _tasks[index] = task;
      }
      _taskMap[task.id] = task;
    } else {
      addTask(task);
    }
  }

  // Mark a task completed by id. Returns true if found and updated.
  bool markComplete(String id) {
    final task = _taskMap[id];
    if (task == null) return false;
    task.complete();
    return true;
  }

  // Mark a task incomplete by id. Returns true if found and updated.
  bool markIncomplete(String id) {
    final task = _taskMap[id];
    if (task == null) return false;
    task.isCompleted = false;
    return true;
  }

  // Remove all tasks
  void clearAllTasks() {
    _tasks.clear();
    _taskMap.clear();
    _taskIds.clear();
  }
 
}