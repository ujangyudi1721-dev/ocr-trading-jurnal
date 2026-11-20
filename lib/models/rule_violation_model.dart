/// The rules that the app can check automatically.
enum RuleId {
  noStopLoss,
  slTooWide,
  lossOverLimit,
  overtrading,
}

/// How serious a violation is.
enum ViolationSeverity { warning, serious }

/// One possible rule violation found in one trade.
class RuleViolation {
  final String ticket; // which trade
  final RuleId rule; // which rule
  final ViolationSeverity severity;
  final String title; // short text, for a badge
  final String detail; // explanation with numbers

  const RuleViolation({
    required this.ticket,
    required this.rule,
    required this.severity,
    required this.title,
    required this.detail,
  });
}