import 'package:flutter/material.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class ExpansionCardGroup extends ChangeNotifier {
  ExpansionCardState? _expanded;
  ExpansionCardState? get expanded => _expanded;
  set expanded(ExpansionCardState? k) {
    _expanded = k;
    notifyListeners();
  }
}

class ExpansionCard extends StatefulWidget {
  const ExpansionCard(
      {this.elevation = 1,
      required this.title,
      this.leading,
      this.contentPadding,
      this.group,
      this.children = const <Widget>[],
      super.key});
  final double elevation;
  final Widget title;
  final Widget? leading;
  final List<Widget> children;
  final EdgeInsetsGeometry? contentPadding;
  final ExpansionCardGroup? group;

  @override
  State<ExpansionCard> createState() => ExpansionCardState();
}

class ExpansionCardState extends State<ExpansionCard>
    with TickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);
  bool _isExpanded = false;

  late final AnimationController _animationController;
  late final Animation<double> _iconTurns;
  late final Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _animationController.drive(_easeInTween);
    _iconTurns = _animationController.drive(_halfTween.chain(_easeInTween));
    widget.group?.addListener(groupUpdated);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.group?.removeListener(groupUpdated);
    super.dispose();
  }

  void groupUpdated() {
    if (_isExpanded && widget.group!.expanded != this) {
      toggleExpanded();
    }
  }

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    if (_isExpanded && widget.group != null) {
      widget.group!.expanded = this;
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Card(
      elevation: widget.elevation,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            contentPadding: widget.contentPadding,
            leading: widget.leading,
            title: widget.title,
            trailing: RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more_rounded),
            ),
            onTap: toggleExpanded,
          ),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: AnimatedSize(
                alignment: Alignment.topCenter,
                duration: _kExpand,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _animationController.isDismissed;

    final Widget result = Offstage(
      offstage: closed,
      child: TickerMode(
        enabled: !closed,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.children,
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _animationController.view,
      builder: _buildChildren,
      child: result,
    );
  }
}
