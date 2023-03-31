import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web/src/controllers/controllers.dart';
import 'package:flutter_web/src/models/models.dart';
import 'package:get/get.dart';

class BtmNavBar extends StatelessWidget {
  const BtmNavBar({
    super.key,
  });
  final double smallIconSize = 24;
  final double bigIconSize = 40;
  final double iconPadding = 8;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedLabelStyle: Theme.of(context).textTheme.displaySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.displaySmall,
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        currentIndex: BtmNavController.to.bottomIndex.value,
        onTap: (idx) => MenuNames.values[idx] != MenuNames.plus
            ? BtmNavController.to.bottomIndex(idx)
            : BtmNavController.to.onClickPlus(),
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
                height: smallIconSize,
                child: SvgPicture.asset(
                    width: smallIconSize, "assets/svg/icons/home_off.svg")),
            activeIcon: SizedBox(
                height: smallIconSize,
                child: SvgPicture.asset(
                    width: smallIconSize, "assets/svg/icons/home_on.svg")),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: smallIconSize,
              child: SvgPicture.asset(
                  width: smallIconSize, "assets/svg/icons/compass_off.svg"),
            ),
            activeIcon: SizedBox(
              height: smallIconSize,
              child: SvgPicture.asset(
                  width: smallIconSize, "assets/svg/icons/compass_on.svg"),
            ),
            label: "탐색",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: iconPadding),
              child: SizedBox(
                  height: bigIconSize,
                  child: SvgPicture.asset(
                      width: bigIconSize, "assets/svg/icons/plus.svg")),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
                height: smallIconSize,
                child: SvgPicture.asset(
                    width: smallIconSize, "assets/svg/icons/subs_off.svg")),
            activeIcon: SizedBox(
                height: smallIconSize,
                child: SvgPicture.asset(
                    width: smallIconSize, "assets/svg/icons/subs_on.svg")),
            label: "구독",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: smallIconSize,
              child: SvgPicture.asset(
                  width: smallIconSize, "assets/svg/icons/library_off.svg"),
            ),
            activeIcon: SizedBox(
              height: smallIconSize,
              child: SvgPicture.asset(
                  width: smallIconSize, "assets/svg/icons/library_on.svg"),
            ),
            label: "라이브러리",
          ),
        ],
      ),
    );
  }
}

class BtmSheet extends StatelessWidget {
  const BtmSheet({super.key});
  final double listPadding = 20;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 500,
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(listPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("만들기", style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(listPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.shortcut_sharp,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 10),
                    ],
                  ),
                  const Text("Shorts 동영상 만들기"),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
