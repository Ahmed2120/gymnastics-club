import 'package:easy_localization/easy_localization.dart';

extension Localizzation on String {
  String get translate => tr(this);
}
