import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() {
  querySelector('#title')!.text = 'Airbnb Clone Using Dart';
  final form = querySelector('#searchForm') as FormElement;

  form.onSubmit.listen((Event event) async {

    // Prevent the form from submitting normally
    event.preventDefault();

    // Get the input values from the form
    final stateInput = (querySelector('#state') as InputElement).value!;
    final checkinInput = (querySelector('#checkin') as InputElement).value!;
    final checkoutInput = (querySelector('#checkout') as InputElement).value!;
    final adultsInput = (querySelector('#adults') as InputElement).value!;

   // Get the current date and parse the input dates
    var now = DateTime.now();
    var checkinDate = DateTime.parse(checkinInput);
    var checkoutDate = DateTime.parse(checkoutInput);

    // Check if the input dates are before the current date
    if (checkinDate.isBefore(now) || checkoutDate.isBefore(now)) {
      window.alert('Please enter a future date.');
      return;
    }

    // Prepare the API request options
    final params = {
      'location': stateInput,
      'checkin': checkinInput,
      'checkout': checkoutInput,
      'adults': adultsInput
    };

    // Make the API call
    try {
      final response = await http.get(
        Uri.https('airbnb13.p.rapidapi.com', '/search-location', params),

        headers: {
          'X-RapidAPI-Key': '55a3f1825cmshfc2119b75fe3019p16a37ejsn802c53abf101',
          'X-RapidAPI-Host': 'airbnb13.p.rapidapi.com'
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final data = json.decode(response.body);
        displayResults(data);
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } catch (e) {
      handleError(e);
    }
  });
}