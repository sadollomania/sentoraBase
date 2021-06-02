import 'package:flutter/material.dart';
import 'package:sentora_base/model/MenuButtonConfig.dart';
import 'package:sentora_base/model/StateData.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/pages/BasePage.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

abstract class ButtonNavPage extends BasePage {
  final double screenWidthRatio;

  ButtonNavPage({
    @required String Function(StateData stateData) pageTitle,
    @required List<MenuButtonConfig> Function(StateData stateData) menuConfig,
    String Function(StateData stateData) popText,
    String Function(StateData stateData) popTitle,
    String Function(StateData stateData) popCancelTitle,
    String Function(StateData stateData) popOkTitle,
    List<String> Function(StateData stateData) loadStateHeaders,
    void Function(StateData stateData) loadHeadersInitStateFunction,
    void Function(StateData stateData) initStateFunction,
    void Function(StateData stateData) disposeFunction,
    this.screenWidthRatio = 0.8,
  })  :
  assert(menuConfig != null),
  assert(screenWidthRatio != null),
  assert((loadStateHeaders == null && loadHeadersInitStateFunction == null) || (loadStateHeaders != null && loadHeadersInitStateFunction != null)),
  super(
    pageTitle : pageTitle,
    popText : popText,
    popTitle : popTitle,
    popCancelTitle : popCancelTitle,
    popOkTitle : popOkTitle,
    initialTag : (stateData) => {
      "screenWidthRatio" : screenWidthRatio,
      "loadState" : 0,
      "loadStateHeaders" : [],
    },
    initStateFunction : initStateFunction,
    didChangeDependenciesFunction : (stateData) {
      stateData.tag["loadStateHeaders"] = loadStateHeaders?.call(stateData) ?? [];
      loadHeadersInitStateFunction?.call(stateData);
    },/*
    afterRender : (stateData) {
      loadHeadersInitStateFunction?.call(stateData);
    },*/
    disposeFunction : disposeFunction,
    body : (stateData) {
      return Container(
          alignment: Alignment(0.0, 0.0),
          child: stateData.tag["loadState"] < stateData.tag["loadStateHeaders"].length ? Container(alignment: Alignment.center, child:Text(stateData.tag["loadStateHeaders"][stateData.tag["loadState"]])) : LayoutBuilder(
            builder: (context, constraint){
              return Container(
                width: constraint.biggest.width * stateData.tag["screenWidthRatio"],
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: menuConfig(stateData).map<List<Widget>>((menuButtonConfig){
                      List<Widget> retList = [];
                      retList.add(
                        MenuButton(
                          title : menuButtonConfig.title,
                          iconData: menuButtonConfig.iconData,
                          image: menuButtonConfig.image,
                          iconColor: menuButtonConfig.iconColor,
                          iconFlex: menuButtonConfig.iconFlex,
                          textFlex: menuButtonConfig.textFlex,
                          fontSize: menuButtonConfig.fontSize,
                          onPressed: () async{
                            if(menuButtonConfig.onPressed != null) {
                              await menuButtonConfig.onPressed(context, stateData.scaffoldKey);
                            } else {
                              await NavigatorBase.push(menuButtonConfig.navPage);
                            }
                            return;
                          }
                        )
                      );
                      retList.add(SizedBox(height: 10,));
                      return retList;
                    }).toList().expand((i) => i).toList()
                  )
                ),
              );
            },
          )
      );
    }
  );
}