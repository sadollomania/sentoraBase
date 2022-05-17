import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentora_base/data/DBHelperBase.dart';
import 'package:sentora_base/utils/ConstantsBase.dart';
import 'package:sentora_base/widgets/SntIconButton.dart';

class DBBackupRestore extends StatefulWidget{
  final Future<void> Function(BuildContext context)? afterRestoreDb;
  final String Function(BuildContext context) titleStr;
  final String Function(BuildContext context) backupStr;
  final String Function(BuildContext context) restoreStr;
  final String Function(BuildContext context) dbRestoredStr;
  final String Function(BuildContext context) dbBackedUpStr;

  DBBackupRestore({
    required this.titleStr,
    required this.backupStr,
    required this.restoreStr,
    required this.dbRestoredStr,
    required this.dbBackedUpStr,
    this.afterRestoreDb,
  });

  @override
  State<StatefulWidget> createState() => _DBBackupRestoreState();
}

class _DBBackupRestoreState extends State<DBBackupRestore> {
  Future<void> _openFileExplorerForDBRestore(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false,);
      if(null != result && result.paths.isNotEmpty) {
        String _path = result.paths.first!;
        await DBHelperBase.instance.restoreDB(_path);
        await DBHelperBase.instance.getDb();
        await widget.afterRestoreDb?.call(context);
        ConstantsBase.showToast(context, widget.dbRestoredStr(context));
      }
    } on PlatformException catch (e) {
      debugPrint("Unsupported operation" + e.toString());
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.titleStr(context)),
            ),
          ),
          SizedBox(width: 10,),
          SntIconButton(
              caption: widget.backupStr(context),
              color: ConstantsBase.transparentColor,
              icon: Icons.file_download,
              onTap: () async{
                String backupPath = await DBHelperBase.instance.backupDB();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.dbBackedUpStr(context) + " : " + backupPath),));
              }
          ),
          SizedBox(width: 10,),
          SntIconButton(
              caption: widget.restoreStr(context),
              color: ConstantsBase.transparentColor,
              icon: Icons.file_upload,
              onTap: () async{
               await _openFileExplorerForDBRestore(context);
               return;
              }
          ),
        ],
      ),
    );
  }
}