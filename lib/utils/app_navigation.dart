import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';

Route<T> _buildRoute<T>({
  required WidgetBuilder builder,
  required bool animated,
}) {
  if (animated) {
    return MaterialPageRoute<T>(builder: builder);
  }
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

Future<T?> pushAppRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool? animated,
}) {
  final useAnimation =
      animated ?? context.read<PosProvider>().useAnimatedPageTransitions;
  return Navigator.of(
    context,
  ).push<T>(_buildRoute<T>(builder: builder, animated: useAnimation));
}

Future<T?> pushReplacementAppRoute<T, TO>(
  BuildContext context, {
  required WidgetBuilder builder,
  TO? result,
  bool? animated,
}) {
  final useAnimation =
      animated ?? context.read<PosProvider>().useAnimatedPageTransitions;
  return Navigator.of(context).pushReplacement<T, TO>(
    _buildRoute<T>(builder: builder, animated: useAnimation),
    result: result,
  );
}

Future<T?> pushAndRemoveUntilAppRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required RoutePredicate predicate,
  bool? animated,
}) {
  final useAnimation =
      animated ?? context.read<PosProvider>().useAnimatedPageTransitions;
  return Navigator.of(context).pushAndRemoveUntil<T>(
    _buildRoute<T>(builder: builder, animated: useAnimation),
    predicate,
  );
}
