import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:sentora_base/navigator/NavigatorBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class IntroPage extends StatefulWidget {
  final List<Slide> Function(BuildContext context) slides;
  final Widget mainPage;
  final Color topBarColor;
  final Color bottomBarColor;

  IntroPage({
    @required this.slides,
    this.topBarColor,
    this.bottomBarColor,
    this.mainPage,
  });

  @override
  State<StatefulWidget> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() async{
    await ConstantsBase.setKeyValue(ConstantsBase.introShownKey, "1");
    if(widget.mainPage == null) {
      NavigatorBase.pop();
    } else {
      NavigatorBase.pushReplacement(widget.mainPage);
    }
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: ConstantsBase.yellowShade500Color,
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: ConstantsBase.yellowShade500Color,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: ConstantsBase.yellowShade500Color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.topBarColor,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: widget.bottomBarColor,
        child: Container(height: 10,),
      ),
      body :  SafeArea(
        child: IntroSlider(
          // List slides
          slides: widget.slides(context),

          // Skip button
          renderSkipBtn: this.renderSkipBtn(),
          colorSkipBtn: Color(0x33000000),
          highlightColorSkipBtn: Color(0xff000000),

          // Next button
          renderNextBtn: this.renderNextBtn(),

          // Done button
          renderDoneBtn: this.renderDoneBtn(),
          onDonePress: this.onDonePress,
          colorDoneBtn: Color(0x33000000),
          highlightColorDoneBtn: Color(0xff000000),

          // Dot indicator
          colorDot: Color(0x33D02090),
          colorActiveDot: ConstantsBase.yellowShade500Color,
          sizeDot: 13.0,

          // Show or hide status bar
          shouldHideStatusBar: false,
          backgroundColorAllSlides: Colors.grey,
        )
      ),
    );
  }
}