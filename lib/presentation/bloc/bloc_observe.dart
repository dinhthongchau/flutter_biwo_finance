import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LogType { create, event, change, transition, error, close, debug }

void customPrintBloc(String message, {LogType type = LogType.debug}) {
  String icon = '';
  String colorCode = '';

  switch (type) {
    case LogType.create:
      icon = '🟢';
      colorCode = '\x1B[32m';
      break;
    case LogType.event:
      icon = '🔵';
      colorCode = '\x1B[34m';
      break;
    case LogType.change:
      icon = '🟡';
      colorCode = '\x1B[33m';
      break;
    case LogType.transition:
      icon = '🟣';
      colorCode = '\x1B[35m';
      break;
    case LogType.error:
      icon = '🔴';
      colorCode = '\x1B[31m';
      break;
    case LogType.close:
      icon = '⚫';
      colorCode = '\x1B[90m';
      break;
    case LogType.debug:
      icon = '⚪';
      colorCode = '\x1B[0m';
      break;
  }

  const String resetColor = '\x1B[0m';
  debugPrint('$colorCode$icon $message$resetColor');
}

class MyBlocObserver extends BlocObserver {
  const MyBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    customPrintBloc(
      'onCreate -- bloc: ${bloc.runtimeType}',
      type: LogType.create,
    );
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    customPrintBloc(
      'onEvent -- bloc: ${bloc.runtimeType}, event: $event',
      type: LogType.event,
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    final formattedCurrentState = _formatStateForLog(change.currentState);
    final formattedNextState = _formatStateForLog(change.nextState);
    customPrintBloc(
      'onChange -- bloc: ${bloc.runtimeType}, change: Change { currentState: $formattedCurrentState, nextState: $formattedNextState }',
      type: LogType.change,
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);

    final formattedCurrentState = _formatStateForLog(transition.currentState);
    final formattedNextState = _formatStateForLog(transition.nextState);
    customPrintBloc(
      'onTransition -- bloc: ${bloc.runtimeType}, transition: Transition { currentState: $formattedCurrentState, event: ${transition.event}, nextState: $formattedNextState }',
      type: LogType.transition,
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    customPrintBloc(
      'onError -- bloc: ${bloc.runtimeType}, error: $error',
      type: LogType.error,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    customPrintBloc(
      'onClose -- bloc: ${bloc.runtimeType}',
      type: LogType.close,
    );
  }

  String _formatStateForLog(dynamic state) {
    if (state == null) {
      return 'null';
    }

    final stateType = state.runtimeType.toString();
    String stateString = state.toString();

    if (state is List) {
      if (state.isEmpty) {
        return '$stateType[]';
      }
      final firstElement = state.first;
      final modelName = firstElement.runtimeType.toString();
      return '$stateType[List<$modelName> (count: ${state.length})]';
    }

    final verboseListPattern = RegExp(
      r"\[\s*(Instance of '\w+'(?:,\s*Instance of '\w+')*)\s*(?:,\s*\.\.\.)?\s*\]",
    );
    stateString = stateString.replaceAllMapped(verboseListPattern, (match) {
      final innerContent = match.group(1);
      if (innerContent != null) {
        final instanceRegex = RegExp(r"Instance of '(\w+)'");
        final innerInstanceMatches = instanceRegex.allMatches(innerContent);
        final Map<String, int> currentListModelCounts = {};
        for (final m in innerInstanceMatches) {
          final modelName = m.group(1);
          if (modelName != null) {
            currentListModelCounts[modelName] =
                (currentListModelCounts[modelName] ?? 0) + 1;
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
      return match.group(0)!;
    });

    final verboseMapPattern = RegExp(r"\{[^}]*,\s*[^}]*\}");
    stateString = stateString.replaceAllMapped(verboseMapPattern, (match) {
      final mapContent = match.group(0)!;

      if (mapContent.length > 50) {
        return '{...}';
      }
      return mapContent;
    });

    const int maxDisplayLength = 150;

    String finalFormattedString;
    if (stateString.length > maxDisplayLength) {
      finalFormattedString = '${stateString.substring(0, maxDisplayLength)}...';
    } else {
      finalFormattedString = stateString;
    }

    return '$stateType($finalFormattedString)';
  }
}
