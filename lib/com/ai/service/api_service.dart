import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';

class APIService {
  final _API_KEY = "";

  Future<Map<String, dynamic>> analyseReportText(
      List<Map<String, String>> messages) async {
    String result = "";
    bool isError = true;
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_API_KEY}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        "messages": messages,
        // "messages": [
        //   {"role": "system", "content": "Analyse this medical report"},
        //   {"role": "system", "content": prompt}
        // ],
        // 'max_tokens': 50, // Number of tokens in the response
        "temperature": 0.7,
      }),
    );

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body);
        result = data['choices'][0]['message']['content'];
        isError = false;
        break;
      case 400:
        result = "Unexpected Error Occured";
        break;
      case 401:
        result = "Error Occured while Analysing";
        break;
      case 429:
        result =
            "You are sending too much messages in a short period of time, please wait";
        break;
      case 500:
        result = "Unexpected Error Occured";
        break;
      case 503:
        result = "Service Unavailable";
        break;
      case 504:
        result = "Timeout";
        break;
      default:
        result = "Unexpected Error Occured";
        break;
    }

    return {"message": result, "error": isError};
  }
}
