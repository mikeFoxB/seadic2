import 'package:flutter/material.dart';
import 'Services.dart';
import '../../models/wordpair.dart';
import '../../models/wordpairs.dart';
import 'DBHelper.dart';
import 'package:wakelock/wakelock.dart';
import 'package:url_launcher/url_launcher.dart';

//var result = await ChineseConverter.convert(text, S2TWp());
//var result = await ChineseConverter.convert(text, TW2Sp());

class GridViewDemo extends StatefulWidget {
  GridViewDemo() : super();

  final String title = "SEA DICTIONARY";

  @override
  GridViewDemoState createState() => GridViewDemoState();
}

class GridViewDemoState extends State<GridViewDemo> {
  //
  int? counter;
  static Wordpairs? wps;
  DBHelper? dbHelper;
  bool? wpsLoaded;
  String? title; // Title for the AppBar where we will show the progress...
  double? percent;
  GlobalKey<ScaffoldState>? scaffoldKey;
  final txtController1 = TextEditingController();
  final resultController1 = TextEditingController();
  String cresult1 = '';
  String cresult2 = '';
  int nlangFrom = 0;
  List<bool> isSelected = [true, true, true];
  bool _lookupDone=true;
  @override
  void initState()  {

    super.initState();
    counter = 0;
    percent = 0.0;
    title = widget.title;
    wpsLoaded = false;
    scaffoldKey = GlobalKey();
    dbHelper = DBHelper();
    showDownloadWarn();

  }
  showDownloadWarn() async {
    bool lEmptyRec = await dbHelper!.tableIsEmpty(1);
    if (lEmptyRec == true) {
      cresult1='There is no dictionary data on your device.\nPlease click the download button at the top of this screen to download the dictionary data first.';
      setState(() {});
    }

  }
  String getsourcelang() {
    String lclang = '';
    if (nlangFrom == 0) {
      lclang = 'English';
    }
    else if (nlangFrom == 1) {
      lclang = 'Thai';
    }
    else if (nlangFrom == 2) {
      lclang = 'Chinese';
    }
    return lclang;
   }

  getTranslate(String cword) async {

    bool lEmptyRec = await dbHelper!.tableIsEmpty(1);
    if (lEmptyRec == true) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('INITIALIZE THE APP'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('There is no dictionary data on this device.'),
                  Text('Please click the download button to download the dictionary data to your device first.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: ()  {
                  Navigator.pop(context, 'ok');
                },
              ),
            ],
          );
        },
      );
    }
    _lookupDone=false;
    setState(() {});
    //await Future.delayed(const Duration(seconds: 2), (){});
    var db = await dbHelper!.db;
    String lcquery1='';
    List<String> cparam1=[''];
    String lcquery2='';
    List<String> cparam2=[''];
    String lcquery3='';
    List<String> cparam3=[''];
    String lcqueryDropTmp='DROP TABLE IF EXISTS tmp_dic;';

    List<String> cskipVal=['?',''];
    String lcqueryEnTh= 'SELECT distinct en as wrd FROM et where th=? union SELECT distinct th as wrd FROM et where en=? union SELECT distinct en as wrd FROM te where th=? union SELECT distinct th as wrd FROM te where en=?';
    List<String> cparamEnTh=[cword, cword,cword, cword];
    print(nlangFrom);
    if (nlangFrom==0){
      //from english to thai
       lcquery1=lcqueryEnTh;
       cparam1=cparamEnTh;
      //from english to chinese
       lcquery3= 'SELECT distinct th as wrd FROM ce where en=?';
       cparam3=[cword];
    }
    else if (nlangFrom==1) {
      // from thai to english
      lcquery1=lcqueryEnTh;
       cparam1=cparamEnTh;
     //from thai to chinese

      lcquery2='CREATE TEMPORARY TABLE tmp_dic AS '+lcqueryEnTh;
      cparam2=cparamEnTh;
      lcquery3= 'select distinct a.th as wrd from ce a inner join tmp_dic t on a.en=t.wrd;';

    }
    else if (nlangFrom==2) {
      // from Chinese to english
      lcquery1='SELECT distinct en as wrd FROM ce where th=?';
      cparam1=[cword];
      // from Chinese to thai
      lcquery2='CREATE TEMPORARY TABLE tmp_dic AS SELECT en  FROM ce where th=?';
      cparam2=[cword];
      lcquery3= '''select distinct a.th as wrd from et a inner join tmp_dic t on upper(a.en)=upper(t.en) union select distinct a.en as wrd from et a inner join tmp_dic t on upper(a.th)=upper(t.en)
          union select distinct a.th as wrd from te a inner join tmp_dic t on upper(a.en)=upper(t.en) union select distinct a.en as wrd from te a inner join tmp_dic t on upper(a.th)=upper(t.en);''';
      //lcquery3= 'select en as wrd from tmp_dic;';
    }
    List<Map> wordlist2=[];
    await db.rawQuery(lcqueryDropTmp);
    List<Map> wordlist1 = await db.rawQuery(lcquery1,cparam1);
    String result1 = '';
    int cnt1 = 0;
    wordlist1.forEach((dbItem) {
      String cwrd = dbItem["wrd"];
      if (cskipVal.contains(cwrd)==false){
      ++cnt1;
      if (cnt1 == 1) {
        result1 = cnt1.toString() + '. ' + cwrd;
      }
      else {
        result1 = result1 + '\n' + cnt1.toString() + '. ' + cwrd;
      }
    }});

    //var batch = db.batch();
    if (lcquery2=='') {
      wordlist2 = await db!.rawQuery(lcquery3, cparam3);
      await db.rawQuery(lcqueryDropTmp);
      /*
      batch.rawQuery(lcquery3, cparam3);
      batch.rawQuery(lcqueryDropTmp);
      var batchResult = await batch.commit();
       */
    }
    else {
      if (lcquery2 != '') {
        await db!.rawQuery(lcquery2, cparam2);
        wordlist2 = await db!.rawQuery(lcquery3);
        await db.rawQuery(lcqueryDropTmp);
        /*batch.rawQuery(lcquery2, cparam2);
        batch.rawQuery(lcquery3);
        batch.rawQuery(lcqueryDropTmp);
        var batchResult = await batch.commit();
        wordlist2=batchResult[2];
        */
      }
    }

    //batch.rawQuery(statement1);
    //batch.rawQuery(statement2);
    //batch.rawQuery(statement3);


    String result2 = '';
    int cnt2 = 0;
    wordlist2.forEach((dbItem) {
      String cwrd = dbItem["wrd"];
      if (cskipVal.contains(cwrd)==false ){
      ++cnt2;
      if (cnt2 == 1) {
        result2 = cnt2.toString() + '. ' + cwrd;
      }
      else {
        result2 = result2 + '\n' + cnt2.toString() + '. ' + cwrd;
      }
    }});


    if (result1 == '') {
      result1 = '--Sorry, no matching words found --';
    }
    print(result1);
    resultController1.text = result1;
    cresult1 = result1;

    if (result2 == '') {
      result2 = '--Sorry, no matching words found --';
    }
    print(result2);
    resultController1.text = result2;
    cresult2 = result2;
    _lookupDone=true;
    setState(() {});
  }
  getWordpairsAll() async {
    print('into dpwnload');

    setState(() {
      counter = 0;
      wpsLoaded = false;
    });
    print('start dowload');

    await getWordpairs(1);
    await getWordpairs(2);
    await getWordpairs(3);
    print('end dowload');
    wpsLoaded = true;
    setState(() {});
  }

  Future getWordpairs(int cnt) async {
    bool lEmptyRec = await dbHelper!.tableIsEmpty(cnt);
    if (lEmptyRec == false) {
      //return;
    }
    if (cnt==1 || cnt==2){ // || or,   && and
    var allWps = await Services.getWordpairs(cnt);
     await dbHelper?.truncateTable(cnt);
     await insertSingle(cnt,allWps);
    }
    else if (cnt==3){ //chinese
      await dbHelper?.truncateTable(cnt);
      var allWps1 = await Services.splitChinese(1); //big5
      await  insertChinese(allWps1);
      var allWps2 = await Services.splitChinese(2); //gb
      await  insertChinese(allWps2);
    }

  }

  trancatetblall() async {
    /*
    bool lEmptyRec = await dbHelper!.tableIsEmpty(3);

    if (lEmptyRec == false) {
      //return;
    }
    */

    //dbHelper?.truncateTable(3);
    //return;
    await dbHelper?.close();
    await dbHelper?.deleteDB();
   // dbHelper?.truncateTable(1);
    //dbHelper?.truncateTable(2);
    print('deleted');
    dbHelper = DBHelper();
  }

  insertSingle(int cnt, Wordpairs wps) async{
    print('insert into ....');
    print(cnt);
    counter=0;
    for (int i=0;i< wps!.wordpairs.length;i++){
      Wordpair a = wps!.wordpairs[i!];
    await dbHelper?.save(cnt, a);
      counter = counter! + 1;
      percent = ((counter! / wps!.wordpairs.length) * 100) /
          100; // percent from 0 to 1...
      if (counter! >= wps!.wordpairs.length) {
        // when inserting is done
        setState(() {
          wpsLoaded = true;
          percent = 0.0;
          title = '${widget.title} [$counter]';
        });
        return;
      }
      setState(() {
        title = 'Loading...$counter';
      });
    }
    }

  insertChinese(List<List<String>> mlist) async{
    print('insertChinese ....');

    counter=0;
    for (var wp in mlist) {
      print(wp);
      await dbHelper?.insertChineseOnePair(wp);
      counter = counter! + 1;
      percent = ((counter! / mlist.length) * 100) /
          100; // percent from 0 to 1...
      if (counter! >= mlist.length) {
        // when inserting is done
        setState(() {
          wpsLoaded = true;
          percent = 0.0;
          title = '${widget.title} [$counter]';
        });
        return;
      }
      setState(() {
        title = 'Loading...$counter';
      });
    }
  }

  Future<void> _showDialogDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CAUTION!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This will delete all dictionary data from your device.'),
                Text('You will not be able to look up for words any more until you download the data again.'),
                Text('Are you sure you want to proceed with this action?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.pop(context, 'Yes');
                await trancatetblall();
                await _showDialogCompleted(2);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, 'No');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogDownload() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('CONFIRM'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This will download dictionary data into your device, so that you could start to use this dictionary.'),
                Text('Are you sure you want to proceed with this action?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.pop(context, 'Yes');
                Wakelock.enable();
                await getWordpairsAll();
                await _showDialogCompleted(1);
                Wakelock.disable();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, 'No');
              },
            ),
          ],
        );
      },
    );
  }
  String getacton(int actid){
      String ctxtaction;
    if (actid==1){
      ctxtaction ='Downloading dictionary data has completed successfully.\nYou can start to look up words now.';
    }
    else {
      ctxtaction='Deleting dictionary data has completed successfully.\nIf you need to look up words, please click the download button to download the dictionary data first.';
    }
    return ctxtaction;
  }
  Future<void> _showDialogCompleted(int actid) async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ACTION COMPLETED'),
          content: SingleChildScrollView(
            child: ListBody(
              children:  <Widget>[
                Text(getacton(actid)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.pop(context, 'Yes');

              },
            ),

          ],
        );
      },
    );
  }

  Future<void> _showDialogEmptyWord() async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('EMPTY WORD'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please input a word to look up first.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: ()  {
                Navigator.pop(context, 'ok');

              },
            ),
          ],
        );
      },
    );
  }
  // We will create a GridView to show the Data...
  // Before that we will create the class from each Cell in the GridView
  // Add a Gridview to the UI

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(title!),
            // Add action buttons in the AppBar
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.file_download),
                tooltip: 'Download dictionary data',
                onPressed: () async {
                  await _showDialogDownload();
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_forever),
                tooltip: 'Delete dictionary data',
                onPressed: () async{
                  await _showDialogDelete();
                },
              ),
            ],
          ),
          body: Column(

              children: <Widget>[
                LinearProgressIndicator(
                  value: percent,
                ),
                Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(2),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          nlangFrom=0;
                          setState(() {});
                          },
                        child: const Text('English'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(2),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          nlangFrom=1;
                          setState(() {});
                        },
                        child: const Text('Thai'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(2),
                          primary: Colors.white,
                          textStyle: const TextStyle(fontSize: 12),
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () {
                          nlangFrom=2;
                          setState(() {});
                        },
                        child: const Text('Chinese'),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '  From: '+getsourcelang(),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ]),
                Row(
                          children: [
                      Flexible(
                          child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter a word to look up'
                              ),
                              controller: txtController1
                          )),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          if (txtController1.text==''){
                             await _showDialogEmptyWord();
                              return;
                             }
                          getTranslate(txtController1.text);
                        },

                      ),
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: ()  {
                                txtController1.text='';
                                resultController1.text = '';
                                cresult1 = '';
                                cresult2 = '';
                                setState(() {});
                              },

                            ),
                    ]
                ),

                SizedBox(height: 10),

                Expanded(

                  child: SingleChildScrollView(
//scrollable Text - > wrap in SingleChildScrollView -> wrap that in Expanded

                    child:  _lookupDone ? Container(
                      alignment: Alignment.topLeft,
                      child:  Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SelectableText(
                          cresult1+'\n\n'+cresult2,
                          textAlign: TextAlign.left,
                          onTap: () => print('Tapped'),
                          toolbarOptions: ToolbarOptions(copy: true, selectAll: true,),
                          showCursor: true,
                          cursorWidth: 2,
                          cursorColor: Colors.red,
                          cursorRadius: Radius.circular(5),
                        ),
                      )
                    ):
                    Container(
                    alignment: Alignment.center,
                    child:   CircularProgressIndicator(),)
                  ),
                ),
              ]
          ),

        bottomNavigationBar: BottomAppBar(
         child:  Container(
                 decoration: new BoxDecoration(color: Colors.blue),
             height: 35,
                     child: Padding(
                       padding: const EdgeInsets.all(4),
                       child: InkWell(
                         child: Text(
                                 'Powered by www.foxacc.com',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                   color: Colors.white,
                                    ),),
                           onTap: () => launch('http://foxacc.com')
                       ),
                     )),
      ),
    ),

    onWillPop: () async {
     return (await showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext c) {
          return AlertDialog(
            title: Text('EXIT'),
            content: Text('Do you really want to exit?'),
            actions: [
              TextButton(
                child: Text('Yes'),
                onPressed: () => Navigator.pop(c, true),
              ),
              TextButton(
                child: Text('No'),
                onPressed: () => Navigator.pop(c, false),
              ),
            ],
          );
        },
      )) ?? false;
    }
    );
  }
}
