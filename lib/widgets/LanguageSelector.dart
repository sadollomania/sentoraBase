import 'package:flutter/material.dart';
import 'package:sentora_base/events/LocaleChangedEvent.dart';
import 'package:sentora_base/lang/SentoraLocaleConfig.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';

class LanguageSelector extends StatefulWidget{
  final String titleStr;

  LanguageSelector({
    @required this.titleStr,
  });

  @override
  State<StatefulWidget> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String selectedLng = ConstantsBase.getKeyValue(ConstantsBase.localeKey);

  @override
  Widget build(BuildContext context) {
    return Row(
          children: <Widget>[
            SizedBox(
              width: 75,
              child: Text(widget.titleStr),
            ),
            SizedBox(width: 2,),
            Expanded(
              child:Container(
                height: 65,
                  child:DropdownButton<String>(
                    isExpanded: true,
                    value: selectedLng,
                    onChanged: (String newValue) async{
                      setState(() {
                        selectedLng = newValue;
                      });
                      await ConstantsBase.setKeyValue(ConstantsBase.localeKey, selectedLng);
                      ConstantsBase.eventBus.fire(LocaleChangedEvent(Locale(selectedLng)));
                      return;
                    },
                    items : ConstantsBase.localeConfig.map<DropdownMenuItem<String>>((SentoraLocaleConfig cfg){
                      return DropdownMenuItem<String>(
                        value: cfg.locale.languageCode,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                            child:Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),height: 60, width:120, child:ConstantsBase.convertLanguageCodeToImage(cfg.locale.languageCode)),
                                  Expanded(child:Container(decoration: new BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: new BorderRadius.all(const Radius.circular(10.0))), child:Center(child:Text(ConstantsBase.convertLanguageCodeToTitle(cfg.locale.languageCode),style: TextStyle(fontSize: 20),)))),
                                ]
                            )
                        ),
                      );
                    }
                    ).toList(),
                  )
              )
            )
          ],
    );
  }
}