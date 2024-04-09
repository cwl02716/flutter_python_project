import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum CurrentMethod { prompt, start, reset, history }

class ChatSerivce extends ChangeNotifier {
// @app.route('/prompt', methods=['POST'])
// @app.route('/start', methods=['POST'])
// @app.route('/reset', methods=['POST'])
// @app.route('/history', methods=['GET'])
  String url = 'http://127.0.0.1:9999/';
  String message = '';
  String aiMessage = '';
  String conversation = '';
  String rules = '';
  bool needInit = true;
  bool loading = false;

  Future<void> firstChat() async {
    http.Response responseRecord;
    http.Response responseInit;
    bool hasRecord = true;
    needInit = false;
    try {
      loading = true;
      notifyListeners();

      debugPrint("=======================>" + url + "history");

      responseRecord = await http.get(Uri.parse(url + 'history'), headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      });

      debugPrint('After firstChat init api');
      debugPrint('responseRecord: ${responseRecord.body}');

      if (!jsonDecode(responseRecord.body)['messages'].isEmpty) {
        var temp = jsonDecode(responseRecord.body);
        for (var element in temp['messages']) {
          String aSentance = element['content'];
          aSentance.replaceAll('!', '!\n');
          aSentance.replaceAll('。', '。\n');
          if (!aSentance.contains('從現在起你是一位說書人，你要生成一份遊戲背景與規則')) {
            conversation += element['content'];
          }
        }
        loading = false;
        notifyListeners();
      } else {
        hasRecord = false;
      }
    } catch (e) {
      debugPrint("There is errors happend at firstChat init: ${e.toString()}");
      hasRecord = false;
    }
    if (!hasRecord) {
      try {
        loading = true;
        notifyListeners();

        debugPrint("=======================>" + url + "start");

        responseInit = await http.post(Uri.parse(url + 'start'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Access-Control-Allow-Origin': '*'
            },
            body: jsonEncode({'prompt': ''}));

        debugPrint(responseInit.body);

        aiMessage = jsonDecode(responseInit.body)['response'];
        conversation += aiMessage;

        loading = false;
        notifyListeners();
      } catch (e) {
        debugPrint(
            "There is errors happend at firstChat start: ${e.toString()}");
      }
    }
  }

  Future<void> nextChat() async {
    http.Response response;
    if (message != "reset") {
      try {
        loading = true;
        notifyListeners();

        debugPrint(message);

        debugPrint("=======================>" + url + "prompt");

        response = await http.post(Uri.parse(url + 'prompt'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Access-Control-Allow-Origin': '*'
            },
            body: jsonEncode({'prompt': '\n' + message}));
        debugPrint(response.body);

        aiMessage = jsonDecode(response.body)['response'];
        conversation += aiMessage;

        loading = false;
        message = '';
        notifyListeners();
      } catch (e) {
        debugPrint("There is errors happend at nextChat: ${e.toString()}");
      }
    } else {
      try {
        loading = true;
        notifyListeners();
        debugPrint("=======================>" + url + "reset");

        response = await http.post(Uri.parse(url + 'reset'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Access-Control-Allow-Origin': '*'
            },
            body: jsonEncode({'prompt': message}));
        debugPrint(response.body);

        conversation = '';
        loading = false;
        message = '';
        notifyListeners();
      } catch (e) {
        debugPrint("There is errors happend at nextChat: ${e.toString()}");
      }
    }
  }
}
