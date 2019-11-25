import 'package:flutter/material.dart';
import 'package:sentora_base/model/MenuButtonConfig.dart';
import 'package:sentora_base/widgets/MenuButton.dart';

abstract class ButtonNavPage extends StatelessWidget {
  String getPageTitle(BuildContext context);

  List<MenuButtonConfig> getMenuConfig();

  List<Widget> _getMenuItems(BuildContext context) {
    List<Widget> retList = List<Widget>();
    getMenuConfig().forEach((menuButtonConfig){
      retList.add(MenuButton(
          title : menuButtonConfig.title,
          onPressed: menuButtonConfig.onPressed ?? () {
            Navigator.of(context).push(MaterialPageRoute<Null>(builder: (BuildContext context) {
              return menuButtonConfig.navPage;
            }));
          }));
      retList.add(SizedBox(height: 10,));
    });
    return retList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getPageTitle(context)),
      ),
      body:SafeArea(
        child:Container(
          alignment: Alignment(0.0, 0.0),
          child: IntrinsicWidth(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _getMenuItems(context)
            ),
          ),
        ),
      ),
    );
  }
}