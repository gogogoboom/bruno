// @dart=2.9

import 'package:bruno/src/components/selection/bean/brn_selection_common_entity.dart';
import 'package:bruno/src/components/selection/brn_selection_util.dart';
import 'package:bruno/src/constants/brn_asset_constants.dart';
import 'package:bruno/src/theme/configs/brn_selection_config.dart';
import 'package:bruno/src/utils/brn_tools.dart';
import 'package:bruno/src/utils/css/brn_css_2_text.dart';
import 'package:flutter/material.dart';

typedef void ItemSelectFunction(BrnSelectionEntity entity);

// ignore: must_be_immutable
class BrnSelectionCommonItemWidget extends StatelessWidget {
  final BrnSelectionEntity item;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final bool isCurrentFocused;
  final bool isFirstLevel;

  final bool isMoreSelectionListType;

  final ItemSelectFunction itemSelectFunction;

  BrnSelectionConfig themeData;

  BrnSelectionCommonItemWidget({
    @required this.item,
    this.backgroundColor,
    this.isFirstLevel = false,
    this.isMoreSelectionListType = false,
    this.itemSelectFunction,
    this.selectedBackgroundColor,
    this.isCurrentFocused,
    this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    var checkbox;
    if (!item.isUnLimit() &&
        (item.children == null || item.children.length == 0)) {
      if (item.isInLastLevel() && item.hasCheckBoxBrother()) {
        checkbox = Container(
          padding: EdgeInsets.only(left: 6),
          width: 21,
          child: (item.isSelected)
              ? BrunoTools.getAssetImageWithBandColor(
                  BrnAsset.iconMultiSelected)
              : BrunoTools.getAssetImage(BrnAsset.iconUnSelect),
        );
      } else {
        checkbox = Container();
      }
    } else {
      checkbox = Container();
    }

    return GestureDetector(
      onTap: () {
        if (itemSelectFunction != null) {
          itemSelectFunction(item);
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            color: getItemBGColor(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: Expanded(
                          child: Text(
                            item.title,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            textAlign: isFirstLevel ? TextAlign.center : TextAlign.start,
                            style: getItemTextStyle(),
                          ),
                        ),
                      ),
                      checkbox
                    ],
                  ),
                  Visibility(
                    visible: !BrunoTools.isEmpty(item.subTitle),
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: item.isInLastLevel() ? 21 : 0),
                      child: BrnCSS2Text.toTextView(
                        item.subTitle ?? '',
                        defaultStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            color: themeData.commonConfig.colorTextSecondary),
                        // maxLines: 1,
                        // textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
              visible: !item.isInLastLevel() && getSelectedCount(item) > 0,
              child: Container(
                margin: EdgeInsets.all(8),
                width: 5,
                height: 5,
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: themeData.commonConfig.brandPrimary,
                ),
              ))
        ],
      ),
    );
  }

  Color getItemBGColor() {
    if (isCurrentFocused) {
      return this.selectedBackgroundColor;
    } else {
      return this.backgroundColor;
    }
  }

  bool isHighLight(BrnSelectionEntity item) {
    if (item.isInLastLevel()) {
      if (item.isUnLimit()) {
        return isCurrentFocused;
      } else {
        return item.isSelected;
      }
    } else {
      return isCurrentFocused;
    }
  }

  bool isBold(BrnSelectionEntity item) {
    if (isHighLight(item)) {
      return true;
    } else {
      return item.hasCheckBoxBrother() && item.selectedList().length > 0;
    }
  }

  TextStyle getItemTextStyle() {
    if (isHighLight(item)) {
      return themeData.itemSelectedTextStyle.generateTextStyle();
    } else if (isBold(item)) {
      return themeData.itemBoldTextStyle.generateTextStyle();
    }
    return themeData.itemNormalTextStyle.generateTextStyle();
  }

  String getSelectedItemCount(BrnSelectionEntity item) {
    String itemCount = "";
    if ((BrnSelectionUtil.getTotalLevel(item) < 3 || !isFirstLevel) &&
        item.children != null) {
      int count =
          item.children.where((f) => f.isSelected && !f.isUnLimit()).length;
      if (count > 1) {
        return '($count)';
      } else if (count == 1 && item.hasCheckBoxBrother()) {
        return '($count)';
      } else {
        var unLimited =
            item.children.where((f) => f.isSelected && f.isUnLimit()).toList();
        if (unLimited.length > 0) {
          return '(全部)';
        }
      }
    }
    return itemCount;
  }

  int getSelectedCount(BrnSelectionEntity item) {
    int count = 0;
    if(isFirstLevel) {
      for(var e in item.children) {
        if(e.children.isNotEmpty) {
          count += e.children.where((f) => f.isSelected && !f.isUnLimit()).length;
        } else {
          count += e.isSelected ? 1 : 0;
        }
      }
    } else {
      if (
      // (BrnSelectionUtil.getTotalLevel(item) < 3 ) &&
      item.children != null) {
        count = item.children.where((f) => f.isSelected && !f.isUnLimit()).length;
      }
    }

    return count;
  }
}
