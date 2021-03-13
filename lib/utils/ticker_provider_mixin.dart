import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

mixin TickerProviderMixin implements TickerProvider {
  Set<Ticker> _tickers;

  Set<Ticker> get providedTickers => _tickers == null ? Set<Ticker>.unmodifiable(_tickers) : Set<Ticker>.identity();

  void disposeTickers() {
    assert(() {
      if (_tickers != null) {
        for (final Ticker ticker in _tickers) {
          if (ticker.isActive) {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('$this was disposed with an active Ticker.'),
              ErrorDescription('$runtimeType created a Ticker via its TickerProviderStateMixin, but at the time '
                  'dispose() was called on the mixin, that Ticker was still active. All Tickers must '
                  'be disposed before calling super.dispose().'),
              ErrorHint('Tickers used by AnimationControllers '
                  'should be disposed by calling dispose() on the AnimationController itself. '
                  'Otherwise, the ticker will leak.'),
              ticker.describeForError('The offending ticker was'),
            ]);
          }
        }
      }
      return true;
    }());
  }

  void _removeTicker(_RemovableTicker ticker) {
    assert(_tickers != null);
    _tickers.remove(ticker);
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= Set<Ticker>();
    final newTicker = _RemovableTicker(onTick, this);
    _tickers.add(newTicker);
    return newTicker;
  }
}

class _RemovableTicker extends Ticker {
  final TickerProviderMixin _creator;

  _RemovableTicker(TickerCallback onTick, this._creator) : super(onTick);

  @override
  void dispose() {
    _creator?._removeTicker(this);
    super.dispose();
  }
}
