import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:test/test.dart';
import 'package:validartor/common/enums.dart';
import 'package:validartor/common/validation_exception.dart';
import 'package:validartor/validartor.dart';

void main() {
  test('Should validate non nullable map value correctly', () async {
    String url = 'https://jsonplaceholder.typicode.com/users';
    var response = await http.get(url);

    var body = json.decode(response.body);
    var element = body[4];
    var validator = MapValidatorRule({
      'id': NumberValidatorRule(max: 3),
      'username': NumberValidatorRule(),
      'email': StringValidatorRule(),
      'address': MapValidatorRule({
        'street': StringValidatorRule(),
        'suite': StringValidatorRule(),
        'city': StringValidatorRule(),
        'zipcode': StringValidatorRule(inputTypes: [InputType.numeric]),
        'geo': MapValidatorRule({'lat': NullValidatorRule()},
            blacklistedKeys: ["lat"])
      }),
      'phone': StringValidatorRule(),
      'website': StringValidatorRule(),
      'company': MapValidatorRule({
        'name': NumberValidatorRule(),
        'catchPhrase': StringValidatorRule(),
        'bs': StringValidatorRule(),
      })
    }, throwBehaviour: ThrowBehaviour.first);

    try {
      print(validator.validate(element));
    } catch (e, trace) {
      print(e.toString());
      print(trace);
    }
  });
}
