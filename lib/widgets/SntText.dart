import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SntText extends AutoSizeText {
   static Map<String, AutoSizeGroup> _autoSizeGroups = Map<String, AutoSizeGroup>();
   static AutoSizeGroup getGroup(String groupId) {
      if(!_autoSizeGroups.containsKey(groupId)) {
          _autoSizeGroups[groupId] = AutoSizeGroup();
      }
      return _autoSizeGroups[groupId]!;
   }
   static void clearGroups() {
      _autoSizeGroups.clear();
   }

  const SntText(
      String data, {
      Key? key,
      Key? textKey,
      TextStyle? style,
      StrutStyle? strutStyle,
      double? minFontSize,
      double? maxFontSize,
      double? stepGranularity,
      List<double>? presetFontSizes,
      AutoSizeGroup? group,
      TextAlign? textAlign,
      TextDirection? textDirection,
      Locale? locale,
      bool? softWrap,
      bool? wrapWords,
      TextOverflow? overflow,
      Widget? overflowReplacement,
      double? textScaleFactor,
      int? maxLines,
      String? semanticsLabel,
      })  : super(
        data,
          key : key,
          textKey : textKey,
          style : style,
          strutStyle : strutStyle,
          minFontSize : minFontSize ?? 12,
          maxFontSize : maxFontSize ?? double.infinity,
          stepGranularity : stepGranularity ?? 1,
          presetFontSizes : presetFontSizes,
          group : group,
          textAlign : textAlign,
          textDirection : textDirection,
          locale : locale,
          softWrap : softWrap,
          wrapWords : wrapWords ?? true,
          overflow : overflow,
          overflowReplacement : overflowReplacement,
          textScaleFactor : textScaleFactor,
          maxLines : maxLines,
          semanticsLabel : semanticsLabel,
      );

  const SntText.rich(
        TextSpan textSpan, {
        Key? key,
        Key? textKey,
        TextStyle? style,
        StrutStyle? strutStyle,
        double? minFontSize,
        double? maxFontSize,
        double? stepGranularity,
        List<double>? presetFontSizes,
        AutoSizeGroup? group,
        TextAlign? textAlign,
        TextDirection? textDirection,
        Locale? locale,
        bool? softWrap,
        bool? wrapWords,
        TextOverflow? overflow,
        Widget? overflowReplacement,
        double? textScaleFactor,
        int? maxLines,
        String? semanticsLabel,
      }) : super.rich(
        textSpan,
        key : key,
        textKey : textKey,
        style : style,
        strutStyle : strutStyle,
        minFontSize : minFontSize ?? 12,
        maxFontSize : maxFontSize ?? double.infinity,
        stepGranularity : stepGranularity ?? 1,
        presetFontSizes : presetFontSizes,
        group : group,
        textAlign : textAlign,
        textDirection : textDirection,
        locale : locale,
        softWrap : softWrap,
        wrapWords : wrapWords ?? true,
        overflow : overflow,
        overflowReplacement : overflowReplacement,
        textScaleFactor : textScaleFactor,
        maxLines : maxLines,
        semanticsLabel : semanticsLabel,
      );
}