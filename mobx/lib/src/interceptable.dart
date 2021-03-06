part of 'core.dart';

typedef Interceptor<T> = WillChangeNotification<T> Function(
    WillChangeNotification<T>);

// ignore: one_member_abstracts
abstract class Interceptable<T> {
  Dispose intercept(Interceptor<T> interceptor);
}

class Interceptors<T>
    extends NotificationHandlers<WillChangeNotification<T>, Interceptor<T>>
    implements Interceptable<T> {
  Interceptors(ReactiveContext context) : super(context);

  @override
  Dispose intercept(Interceptor<T> interceptor) => add(interceptor);

  WillChangeNotification interceptChange(WillChangeNotification<T> change) {
    if (!_canHandle(change)) {
      return change;
    }

    return _context.untracked(() {
      var nextChange = change;
      for (final interceptor in _handlers.toList(growable: false)) {
        nextChange = interceptor(nextChange);
        if (nextChange == null) {
          break;
        }
      }

      return nextChange;
    });
  }
}
