/// Log levels
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  fatal(4);

  const LogLevel(this.priority);
  final int priority;

  bool operator >=(LogLevel other) => priority >= other.priority;
  bool operator <=(LogLevel other) => priority <= other.priority;
  bool operator >(LogLevel other) => priority > other.priority;
  bool operator <(LogLevel other) => priority < other.priority;
}
