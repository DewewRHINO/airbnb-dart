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


void displayResults(dynamic data) {
  final output = querySelector('#output')!;
  output.innerHtml = ''; // Clear any previous results.

  // Check if 'data' is a Map and contains the 'results' key
  if (data is Map<String, dynamic> && data.containsKey('results')) {
    var results = data['results'];
    if (results is List<dynamic>) {
      for (var result in results) {
        if (result is Map<String, dynamic>) {
          // Define a custom NodeValidator that allows certain tags and attributes.
          var validator = NodeValidatorBuilder()
            ..allowHtml5()
            ..allowElement('a', attributes: ['href'])
            ..allowElement('img', attributes: ['src', 'alt', 'width']);

          // Creating the HTML elements for the response, then adding them to the page.
          var resultDiv = DivElement()
            ..classes.add('result')
            ..setInnerHtml('''
              <img src="${result['images'][0]}" alt="Property Image">
              <div class="container">
                <h4><b>${result['name']}</b></h4>
                <p>${result['type']} - ${result['city']}</p>
                <p>Persons: ${result['persons']}, Bedrooms: ${result['bedrooms']}, Bathrooms: ${result['bathrooms']}</p>
                <p>Rating: ${result['rating'] ?? 'No rating available'}, Reviews: ${result['reviewsCount']}</p>
                <a href="${result['url']}" target="_blank">View on Airbnb</a>
                <p>Price per night: ${result['price']['rate']} ${result['price']['currency']}</p>
            ''', treeSanitizer: NodeTreeSanitizer.trusted);

          // Append the resultDiv to the output
          output.children.add(resultDiv);
        }
      }
    } else {
      // If 'results' is not a list, handle appropriately (e.g., display an error or a message)
      print('Expected a list of results, but got something else.');
    }
  } else {
    // If the expected key ('results') is not found in the data, handle appropriately
    print('Results key not found in the data');
  }
}

void handleError(dynamic e) {
  // This function would need to handle errors
  window.alert('An error occurred: $e');
}