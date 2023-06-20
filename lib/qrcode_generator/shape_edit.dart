import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrcode_generator/components/expansion_card.dart';
import 'package:qrcode_generator/qrcode_generator/qrcode_generator.dart';

enum _ShapeTab {
  content,
  outerCorners,
  innerCorners,
}

class ShapeEdit extends StatefulWidget {
  const ShapeEdit({this.group, super.key});
  final ExpansionCardGroup? group;

  @override
  State<ShapeEdit> createState() => _ShapeEditState();
}

class _ShapeEditState extends State<ShapeEdit> {
  _ShapeTab _selectedTab = _ShapeTab.content;

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      group: widget.group,
      elevation: 2,
      contentPadding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      title: const Text("Shape"),
      leading: const CircleAvatar(child: Icon(Icons.hexagon_outlined)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SegmentedButton<_ShapeTab>(
            showSelectedIcon: false,
            onSelectionChanged: (p0) {
              setState(() {
                _selectedTab = p0.first;
              });
            },
            segments: const [
              ButtonSegment(value: _ShapeTab.content, label: Text("Content")),
              ButtonSegment(
                  value: _ShapeTab.outerCorners, label: Text("Outer Corner")),
              ButtonSegment(
                  value: _ShapeTab.innerCorners, label: Text("Inner Corner"))
            ],
            selected: <_ShapeTab>{_selectedTab},
          ),
        ),
        IndexedStack(
          index: _selectedTab.index,
          children: [
            SizedBox(
                height: _selectedTab != _ShapeTab.content ? 1 : null,
                child: const ContentShapeEdit()),
            SizedBox(
                height: _selectedTab != _ShapeTab.outerCorners ? 1 : null,
                child: const OuterCornerShapeEdit()),
            SizedBox(
                height: _selectedTab != _ShapeTab.innerCorners ? 1 : null,
                child: const InnerCornerShapeEdit()),
          ],
        )
      ],
    );
  }
}

class ContentShapeEdit extends StatefulWidget {
  const ContentShapeEdit({super.key});

  @override
  State<ContentShapeEdit> createState() => _ContentShapeEditState();
}

class _ContentShapeEditState extends State<ContentShapeEdit> {
  @override
  Widget build(BuildContext context) {
    Provider.of<StyleModel>(context).contentBuilderGenerator?.addListener(() {
      setState(() {});
    });
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Provider.of<StyleModel>(context)
            .contentBuilderGenerator
            ?.buildForm(context));
  }
}

class InnerCornerShapeEdit extends StatefulWidget {
  const InnerCornerShapeEdit({super.key});

  @override
  State<InnerCornerShapeEdit> createState() => _InnerCornerShapeEditState();
}

class _InnerCornerShapeEditState extends State<InnerCornerShapeEdit> {
  @override
  Widget build(BuildContext context) {
    Provider.of<StyleModel>(context)
        .innerCornerBuilderGenerator
        ?.addListener(() {
      setState(() {});
    });
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Provider.of<StyleModel>(context)
            .innerCornerBuilderGenerator
            ?.buildForm(context));
  }
}

class OuterCornerShapeEdit extends StatefulWidget {
  const OuterCornerShapeEdit({super.key});

  @override
  State<OuterCornerShapeEdit> createState() => _OuterCornerShapeEditState();
}

class _OuterCornerShapeEditState extends State<OuterCornerShapeEdit> {
  @override
  Widget build(BuildContext context) {
    Provider.of<StyleModel>(context)
        .outerCornerBuilderGenerator
        ?.addListener(() {
      setState(() {});
    });
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Provider.of<StyleModel>(context)
            .outerCornerBuilderGenerator
            ?.buildForm(context));
  }
}
