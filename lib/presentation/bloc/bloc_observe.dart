import 'package:flutter_bloc/flutter_bloc.dart';

// Enum để định nghĩa các loại log
enum LogType {
  create,
  event,
  change,
  transition,
  error,
  close,
  debug, // Thêm loại debug nếu cần
}

// Hàm customPrintBloc để in log với màu sắc và biểu tượng
void customPrintBloc(String message, {LogType type = LogType.debug}) {
  String icon = '';
  String colorCode = ''; // ANSI escape codes for console colors

  switch (type) {
    case LogType.create:
      icon = '🟢'; // Green circle
      colorCode = '\x1B[32m'; // Green
      break;
    case LogType.event:
      icon = '🔵'; // Blue circle
      colorCode = '\x1B[34m'; // Blue
      break;
    case LogType.change:
      icon = '🟡'; // Yellow circle
      colorCode = '\x1B[33m'; // Yellow
      break;
    case LogType.transition:
      icon = '🟣'; // Purple circle
      colorCode = '\x1B[35m'; // Magenta (purple-ish)
      break;
    case LogType.error:
      icon = '🔴'; // Red circle
      colorCode = '\x1B[31m'; // Red
      break;
    case LogType.close:
      icon = '⚫'; // Black circle
      colorCode = '\x1B[90m'; // Bright Black (gray)
      break;
    case LogType.debug:
      icon = '⚪'; // White circle
      colorCode = '\x1B[0m'; // Reset color
      break;
  }

  // Reset color code at the end of the message
  const String resetColor = '\x1B[0m';
  print('$colorCode$icon $message$resetColor');
}

class MyBlocObserver extends BlocObserver {
  const MyBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    customPrintBloc('onCreate -- bloc: ${bloc.runtimeType}', type: LogType.create);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    customPrintBloc('onEvent -- bloc: ${bloc.runtimeType}, event: $event', type: LogType.event);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // Định dạng lại currentState và nextState để tránh chi tiết quá mức
    final formattedCurrentState = _formatStateForLog(change.currentState);
    final formattedNextState = _formatStateForLog(change.nextState);
    customPrintBloc('onChange -- bloc: ${bloc.runtimeType}, change: Change { currentState: $formattedCurrentState, nextState: $formattedNextState }', type: LogType.change);
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc,
      Transition<dynamic, dynamic> transition,
      ) {
    super.onTransition(bloc, transition);
    // Định dạng lại currentState và nextState để tránh chi tiết quá mức
    final formattedCurrentState = _formatStateForLog(transition.currentState);
    final formattedNextState = _formatStateForLog(transition.nextState);
    customPrintBloc('onTransition -- bloc: ${bloc.runtimeType}, transition: Transition { currentState: $formattedCurrentState, event: ${transition.event}, nextState: $formattedNextState }', type: LogType.transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    customPrintBloc('onError -- bloc: ${bloc.runtimeType}, error: $error', type: LogType.error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    customPrintBloc('onClose -- bloc: ${bloc.runtimeType}', type: LogType.close);
  }

  /// Helper function to format state objects for logging,
  /// reducing verbosity for lists of instances and general state objects.
  String _formatStateForLog(dynamic state) {
    if (state == null) {
      return 'null';
    }

    final stateType = state.runtimeType.toString();
    String stateString = state.toString();

    // Case 1: If the state itself is a List, format it directly
    if (state is List) {
      if (state.isEmpty) {
        return '$stateType[]';
      }
      final firstElement = state.first;
      final modelName = firstElement.runtimeType.toString();
      return '$stateType[List<$modelName> (count: ${state.length})]';
    }

    // Regex to find "Instance of 'SomeModel'" within a string and replace with summary
    final verboseListPattern = RegExp(r"\[\s*(Instance of '\w+'(?:,\s*Instance of '\w+')*)\s*(?:,\s*\.\.\.)?\s*\]");
    stateString = stateString.replaceAllMapped(verboseListPattern, (match) {
      final innerContent = match.group(1);
      if (innerContent != null) {
        final instanceRegex = RegExp(r"Instance of '(\w+)'");
        final innerInstanceMatches = instanceRegex.allMatches(innerContent);
        final Map<String, int> currentListModelCounts = {};
        for (final m in innerInstanceMatches) {
          final modelName = m.group(1);
          if (modelName != null) {
            currentListModelCounts[modelName] = (currentListModelCounts[modelName] ?? 0) + 1;
          }
        }

        String currentListSummary = '';
        currentListModelCounts.forEach((modelName, count) {
          if (currentListSummary.isNotEmpty) {
            currentListSummary += ', ';
          }
          currentListSummary += 'List<$modelName> (count: $count)';
        });
        return '[$currentListSummary]';
      }
      return match.group(0)!; // Return original match if no inner content
    });

    // Handle maps that might be too verbose, replacing them with {...}
    // This regex looks for a string that starts with '{' and ends with '}'
    // and contains a comma, indicating multiple key-value pairs.
    // We're being a bit more aggressive here to catch verbose maps.
    final verboseMapPattern = RegExp(r"\{[^}]*,\s*[^}]*\}"); // Matches maps with at least one comma
    stateString = stateString.replaceAllMapped(verboseMapPattern, (match) {
      final mapContent = match.group(0)!;
      // You can adjust this length threshold. If the map string is longer than 50 chars, summarize.
      if (mapContent.length > 50) {
        return '{...}';
      }
      return mapContent;
    });

    // Define a maximum length for the overall state string to prevent overly long logs
    const int maxDisplayLength = 150; // Adjust as needed for desired verbosity

    // If the state's toString() is already concise or has been summarized,
    // we just prepend its type for clarity.
    String finalFormattedString;
    if (stateString.length > maxDisplayLength) {
      finalFormattedString = '${stateString.substring(0, maxDisplayLength)}...';
    } else {
      finalFormattedString = stateString;
    }

    return '$stateType($finalFormattedString)';
  }
}
