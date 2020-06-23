import 'dart:convert';

import 'package:http/http.dart' as http;
import '../lib/validartor.dart';

void main(List<String> args) async {
  String url = 'https://jsonplaceholder.typicode.com/users';
  var response = await http.get(url);

  var body = json.decode(response.body);
  var validator = ListValidatorRule<dynamic>(
      elementRule: MapValidatorRule({
    'id': NumberValidatorRule(),
    'name': NumberValidatorRule(),
    'username': StringValidatorRule(),
    'email': StringValidatorRule(),
    'address': MapValidatorRule({
      'street': StringValidatorRule(),
      'suite': StringValidatorRule(),
      'city': StringValidatorRule(),
      'zipcode': StringValidatorRule(inputTypes: [InputType.numeric]),
      'geo': BasicMapValidatorRule(allowedKeys: ['lat', 'lon'])
    }),
    'phone': StringValidatorRule(),
    'website': StringValidatorRule(),
    'company': MapValidatorRule({
      'name': StringValidatorRule(),
      'catchPhrase': StringValidatorRule(),
      'bs': StringValidatorRule(),
    })
  }));

  print(validator.validate(body));
}
