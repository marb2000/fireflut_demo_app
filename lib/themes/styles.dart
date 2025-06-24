import '../common_dependencies.dart';
import 'fireflut_theme.dart';

class AppStyle {
  AppStyle({Size? screenSize}) {
    if (screenSize == null) {
      scale = 1;
      return;
    }
    final shortestSide = screenSize.shortestSide;
    const tabletXl = 1000;
    const tabletLg = 800;
    if (shortestSide > tabletXl) {
      scale = 1.2;
    } else if (shortestSide > tabletLg) {
      scale = 1.1;
    } else {
      scale = 1;
    }
  }

  late final double scale;
  late final Insets insets = Insets(scale);
  late final AppColors colors = AppColors();
  late final Corners corners = Corners();
}

class Insets {
  Insets(this._scale);
  final double _scale;

  late final double xxs = 4 * _scale;
  late final double xs = 8 * _scale;
  late final double sm = 16 * _scale;
  late final double md = 24 * _scale;
  late final double lg = 32 * _scale;
  late final double xl = 48 * _scale;
  late final double xxl = 56 * _scale;
  late final double offset = 80 * _scale;
}

class Corners {
  Corners() {
    smRadius = BorderRadius.circular(sm);
    medRadius = BorderRadius.circular(med);
    lgRadius = BorderRadius.circular(lg);
  }

  final double sm = 4;

  /// 4
  late final BorderRadius smRadius;

  final double med = 8;

  /// 8
  late final BorderRadius medRadius;

  final double lg = 16;

  /// 16
  late final BorderRadius lgRadius;
}

AppStyle $styles = AppStyle();
