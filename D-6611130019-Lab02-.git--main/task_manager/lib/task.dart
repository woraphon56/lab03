class Task {
  // Non-nullable fields - must be initialized
  final String id;
  String title;
  String description;
  
  // Nullable field - can be null
  DateTime? dueDate;
  
  // Non-nullable with default value
  bool isCompleted;
  
  // Constructor with required and optional parameters
  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
  });
  
  // Method to mark task as completed
  void complete() {
    isCompleted = true;
  }
  
  // Method to check if task is overdue
  bool isOverdue() {
    // Safe null checking with ?.
    final due = dueDate;
    if (due == null) {
      return false; // No due date means not overdue
    }
    return DateTime.now().isAfter(due);
  }
  
  // String representation for debugging
  @override
  String toString() {
    final status = isCompleted ? 'Completed' : 'Pending';
    final due = dueDate != null 
        ? 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}' 
        : 'No due date';
    return 'Task: $title ($status) - $due';
  }
}

// Priority task with priority level
class PriorityTask extends Task {
  // Priority levels: 1 (highest) to 3 (lowest)
  final int priority;
  
  PriorityTask({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    this.priority = 2, // Default medium priority
  }) : assert(priority >= 1 && priority <= 3, 
              'Priority must be between 1 and 3');
  
  // Get priority label
  String get priorityLabel {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'Low';
      default: return 'Unknown';
    }
  }
  
  @override
  String toString() {
    return '${super.toString()} [Priority: $priorityLabel]';
  }
}
// Recurring task that repeats periodically
class RecurringTask extends Task {
  // Recurrence interval in days
  final int intervalDays;
  
  // Last completion date
  DateTime? lastCompleted;
  
  RecurringTask({
    required super.id,
    required super.title,
    super.description,
    super.dueDate,
    super.isCompleted,
    required this.intervalDays,
    this.lastCompleted,
  }) : assert(intervalDays > 0, 
              'Interval must be positive');
  
  // Calculate next due date
  DateTime? getNextDueDate() {
    final last = lastCompleted ?? dueDate;
    if (last == null) return null;
    return last.add(Duration(days: intervalDays));
  }
  
  @override
  void complete() {
    super.complete();
    lastCompleted = DateTime.now();
    // Reset for next occurrence
    isCompleted = false;
    dueDate = getNextDueDate();
  }
  
  @override
  String toString() {
    return '${super.toString()} [Repeats every $intervalDays days]';
  }
}