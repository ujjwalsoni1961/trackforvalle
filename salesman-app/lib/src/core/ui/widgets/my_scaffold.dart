import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/back_button.dart';
import 'package:track/src/core/ui/widgets/line_seperator.dart';
// import 'package:track/src/core/ui/widgets/network_widget.dart';

class MyScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final bool? showBottomLine;
  final Widget? drawer;
  final bool? hideKeyboardOnTap;
  final String? title;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? floatingActionButton;
  final bool? centreTitle;
  final Widget? endDrawer;
  final Color? bgColor;
  final Widget? bottomSheet;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? titleWidget;
  final Widget? bottomBar;
  final bool? isTab;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;

  const MyScaffold({
    super.key,
    this.appBar,
    this.title,
    required this.body,
    this.drawer,
    this.scaffoldKey,
    this.hideKeyboardOnTap,
    this.floatingActionButton,
    this.centreTitle,
    this.showBottomLine,
    this.endDrawer,
    this.bgColor,
    this.bottomSheet,
    this.actions,
    this.leading,
    this.bottomBar,
    this.titleWidget,
    this.isTab,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBgColor = bgColor ?? theme.colorScheme.surface;

    return GestureDetector(
      onTap: () {
        if (hideKeyboardOnTap ?? false) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        backgroundColor: scaffoldBgColor,
        extendBody: true,
        endDrawer: endDrawer,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bottomBar ?? const SizedBox(),
            // const NetworkWidget(),
          ],
        ),
        floatingActionButtonLocation: floatingActionButtonLocation,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
        drawer: drawer,
        key: scaffoldKey,
        appBar:
            appBar ??
            ((leading == null &&
                    title == null &&
                    showBottomLine == null &&
                    actions == null)
                ? null
                : AppBar(
                    leading:
                        leading ??
                        (Navigator.canPop(context)
                            ? !(isTab ?? false)
                                  ? const BackWidget()
                                  : null
                            : null),
                    title:
                        titleWidget ??
                        (title != null
                            ? Text(title!, style: const TextStyle(fontSize: 18))
                            : null),
                    centerTitle: centreTitle ?? false,
                    bottom: (showBottomLine ?? false)
                        ? const PreferredSize(
                            preferredSize: Size.fromHeight(1),
                            child: LineSeperator(),
                          )
                        : null,
                    actions: actions,
                  )),
        body: body,
      ),
    );
  }
}
