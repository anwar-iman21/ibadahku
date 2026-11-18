import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system/design_system.dart';

class NavItem {
  const NavItem(
    this.label,
    this.icon,
    this.selectedIcon, {
    this.customIcon,
    this.customSelectedIcon,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget? customIcon;
  final Widget? customSelectedIcon;

  Widget get iconWidget => customIcon ?? Icon(icon);

  Widget get selectedIconWidget => customSelectedIcon ?? Icon(selectedIcon);
}

/// Navigasi adaptif:
/// HP = NavigationBar bawah, tablet = NavigationRail, desktop = sidebar lebar.
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.shell,
    required this.items,
    required this.roleLabel,
  });

  final StatefulNavigationShell shell;
  final List<NavItem> items;
  final String roleLabel;

  void _go(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    if (size == ScreenSize.mobile) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.borderColor)),
          ),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final it in items)
                NavigationDestination(
                  icon: it.iconWidget,
                  selectedIcon: it.selectedIconWidget,
                  label: it.label,
                  tooltip: it.label,
                ),
            ],
          ),
        ),
      );
    }

    final extended = size == ScreenSize.desktop;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.surfaceCard,
              border: Border(right: BorderSide(color: context.borderColor)),
            ),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              extended: extended,
              minExtendedWidth: 240,
              labelType:
                  extended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
              indicatorColor:
                  context.isDark ? AppColors.green[800] : AppColors.green[100],
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.s2, Sp.s5, Sp.s2, Sp.s5),
                child:
                    extended
                        ? SizedBox(
                          width: 200,
                          child: Row(
                            children: [
                              const LogoMark(size: 44),
                              const HGap(Sp.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IbadahKu',
                                      style: AppText.lg.semibold,
                                    ),
                                    Text(
                                      roleLabel,
                                      style: AppText.xs.c(context.mutedText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        : const LogoMark(size: 44),
              ),
              destinations: [
                for (final it in items)
                  NavigationRailDestination(
                    icon: it.iconWidget,
                    selectedIcon: it.selectedIconWidget,
                    label: Text(it.label),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                  ),
              ],
            ),
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
