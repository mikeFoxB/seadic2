import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/wordpair.dart';
import '../../models/wordpairs.dart';

class Services  {
  //
  static List<Wordpair>? wps;
  static var url1 = Uri.parse('http://foxacc.com/9/dicet.html');
  static var url2 = Uri.parse('http://foxacc.com/9/dicte.html');
  static var url3 = Uri.parse('http://foxacc.com/9/dicce.html');
  static var url4 = Uri.parse('http://foxacc.com/9/diccegb.html');
  static Future<List<List<String>>> splitChinese (int cntChinese) async{
    //print(url3);
   Uri url=url3;
    if (cntChinese==1) {  //big5
      url=url3;
    }
    else {
      url=url4;
    }

    String str='';
    List<List<String>> resultAll=[];
    List<String> resultNow=[];
    try {
    final response = await http.get(url);
    if (200 == response.statusCode) {
     // print(response.statusCode);
     // print(response.body);
      str=utf8.decode(response.bodyBytes);
      print(str);
      str=str.substring(1);
      str=str.substring(0,str.length-1);
      var mlist=str.split('},{');

      print(mlist);
      int cnt=0;
      int nmax=mlist.length;
      int nstarten=0;
      int nstartth=0;
      int nlenval=0;
      String cstarten='"en":"';
      String cstartth=',"th":"';
      String cen='';
      String cth='';

      for (var str in mlist) {
        ++cnt;
        if (cnt==1){
          str=str.substring(1);
        }
        else if (nmax==cnt){
          str=str.substring(0,str.length-1);
        }
        print(str);
        nstarten=str.indexOf(cstarten);
        print(nstarten);
        nstarten=nstarten+cstarten.length;
        print(nstarten);
        nstartth=str.indexOf(cstartth);
        print(nstartth);
        nlenval=nstartth- nstarten;
        print(nlenval);
        cen=str.substring(nstarten,nstartth-1);
        print(cen);
        cth=str.substring(nstartth+cstartth.length);
        cth=cth.substring(0,cth.length-1);
        print(cth);
        resultNow=[cen,cth];
        resultAll.add(resultNow);
      }
      return resultAll;
    } else {
      return resultAll;
    }
  } catch (e) {
   return resultAll;
  }
  }
  static Future<Wordpairs> getWordpairs(int cnt) async {
    try {
     // print('getwps');
      var url;
      if (cnt==1){
        url=url1;
      }
      else if (cnt==2) {
        url=url2;
      }
      else if (cnt==3) {
        url=url3;
      }
      print(url);
      final response = await http.get(url);
      //print(response.body);
      //print(utf8.decode(response.bodyBytes));
      //print(response.statusCode);
      //final jsonResponse = json.decode(response.body);// alien characters for thai, use utf8.decode(response.bodyBytes
      //final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      //print(jsonResponse);
      //print(response.statusCode);
      if (200 == response.statusCode) {
        //print(response.statusCode);
        //print(response.body);
        Wordpairs wps = parseWordpares(utf8.decode(response.bodyBytes));
        //Wordpairs wps = parseWordpares(response.body);
        print('length .......');
        print(wps.wordpairs.length);
        print('length above');
        return wps;
      } else {
        Wordpairs wps = new Wordpairs(wordpairs:[]);
        return wps; // we are returning empty wp list
        // Handle these as you want...
      }
    } catch (e) {
      Wordpairs wps = new Wordpairs(wordpairs:[]);
      return wps;
    }
  }

  static Wordpairs parseWordpares(String responseBody) {
    print('passed in...');
    print(responseBody);
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    //final parsed = json.decode(responseBody);
    print('parsed...');
    print(parsed);
    List<Wordpair> wps =
    parsed.map<Wordpair>((json) => Wordpair.fromJson(json)).toList();
    print(wps);
    Wordpairs a = new Wordpairs(wordpairs:wps);
    return a;
  }
}