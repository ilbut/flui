import 'dart:ui';

import 'package:flutter/cupertino.dart';

const BoxDecoration _kAlertBlurOverlayDecoration = BoxDecoration(
  color: CupertinoColors.white,
  backgroundBlendMode: BlendMode.overlay,
);

// Translucent, very light gray that is painted on top of the blurred backdrop
// as the action sheet's background color.
const Color _kBackgroundColor = Color(0xD1F8F8F8);
const Color _kCancelButtonPressedColor = Color(0xFFEAEAEA);

const double _kBlurAmount = 20.0;
const double _kEdgeHorizontalPadding = 8.0;
const double _kEdgeVerticalPadding = 10.0;
const double _kCancelButtonPadding = 8.0;
const double _kCornerRadius = 14.0;

enum FLCupertinoActionSheetStyle {
  roundedCard,
  filled
}

class FLCupertinoActionSheet extends StatelessWidget {
  FLCupertinoActionSheet({
    Key key,
    this.backgroundColor = _kBackgroundColor,
    this.style = FLCupertinoActionSheetStyle.roundedCard,
    this.borderRadius,
    @required this.child,
    this.cancelButton
  }) : assert(child != null),
        super(key: key);

  final Color backgroundColor;
  final Widget child;

  /// Customized border radius, both two styles use this value first.
  final BorderRadius borderRadius;

  /// The style of the action sheet, currently support
  /// [FLCupertinoActionSheetStyle.roundedCard] & [FLCupertinoActionSheetStyle.filled].
  /// Default value is [FLCupertinoActionSheetStyle.roundedCard], like iOS style.
  final FLCupertinoActionSheetStyle style;

  /// The optional cancel button that is grouped separately from the other
  /// actions.
  ///
  /// Typically this is an [CupertinoActionSheetAction] widget.
  final CupertinoActionSheetAction cancelButton;

  bool _isRound() {
    return style == FLCupertinoActionSheetStyle.roundedCard;
  }

  Widget _buildMainContent() {
    BorderRadius radius = this.borderRadius ??
        _isRound() ? BorderRadius.circular(_kCornerRadius): null;
    final Widget blurContent = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: _kBlurAmount, sigmaY: _kBlurAmount),
      child: Container(
          decoration: _kAlertBlurOverlayDecoration,
          child: Container(
            color: backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(child: child)
              ],
            ),
          )
      ),
    );

    final Widget mainChild = _isRound() ? ClipRRect(
      borderRadius: radius,
      child: blurContent,
    ) : ClipRect(
      child: blurContent,
    );

    return Flexible(
      child: mainChild,
    );
  }

  Widget _buildCancelButton() {
    double top = _isRound() ? _kCancelButtonPadding : 0;
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: _FLCupertinoActionSheetCancelButton(
        isRound: _isRound(),
        child: cancelButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets margin = _isRound()
        ? EdgeInsets.symmetric(horizontal: _kEdgeHorizontalPadding, vertical: _kEdgeVerticalPadding)
        : EdgeInsets.only(top: _kEdgeVerticalPadding);
    List<Widget> children = <Widget>[];
    children.add(_buildMainContent());

    if (cancelButton != null)
      children.add(_buildCancelButton());

    final Orientation orientation = MediaQuery.of(context).orientation;
    double preferWidth;
    if (orientation == Orientation.portrait) {
      preferWidth = MediaQuery.of(context).size.width - margin.horizontal;
    } else {
      preferWidth = MediaQuery.of(context).size.height - margin.horizontal;
    }

    return SafeArea(
      child: Semantics(
        namesRoute: true,
        scopesRoute: true,
        explicitChildNodes: true,
        label: 'Alert',
        child: Container(
            width: preferWidth,
            margin: margin,
            child: Column(
              children: children,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            )
        ),
      ),
    );
  }
}

class _FLCupertinoActionSheetCancelButton extends StatefulWidget {
  const _FLCupertinoActionSheetCancelButton({
    Key key,
    this.child,
    this.isRound = true
  }) : super(key: key);

  final Widget child;
  final bool isRound;

  @override
  _FLCupertinoActionSheetCancelButtonState createState() => _FLCupertinoActionSheetCancelButtonState();
}

class _FLCupertinoActionSheetCancelButtonState extends State<_FLCupertinoActionSheetCancelButton> {
  Color _backgroundColor;

  @override
  void initState() {
    _backgroundColor = CupertinoColors.white;
    super.initState();
  }

  void _onTapDown(TapDownDetails event) {
    setState(() {
      _backgroundColor = _kCancelButtonPressedColor;
    });
  }

  void _onTapUp(TapUpDetails event) {
    setState(() {
      _backgroundColor = CupertinoColors.white;
    });
  }

  void _onTapCancel() {
    setState(() {
      _backgroundColor = CupertinoColors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = widget.isRound
        ? BorderRadius.circular(_kCornerRadius) : null;
    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: borderRadius,
        ),
        child: widget.child,
      ),
    );
  }
}