import 'package:flutter/widgets.dart';

/// Shadow halus bertingkat (sm / md / lg).
class Shd {
  Shd._();
  static const sm = <BoxShadow>[
    BoxShadow(color: Color(0x0F0D3311), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const md = <BoxShadow>[
    BoxShadow(color: Color(0x140D3311), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A0D3311), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const lg = <BoxShadow>[
    BoxShadow(color: Color(0x1F0D3311), blurRadius: 30, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0F0D3311), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
