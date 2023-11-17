//  Price Allman
//  searchAddressViewController.swift
//  Shortcut


import UIKit
import MapKit
import CoreLocation
import MapboxMaps
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation

// Protocol for passing map items between view controllers
// protocol- blueprint of methods and properties
protocol MapPlaceDelegate: class {
    // Function to pass a map item and its index
    func passMapLocation(_ mapPlace: MKMapItem, at index: Int)
}

// Main view controller for address selection
class searchAddressViewController: UIViewController {
    // Outlets to connect UI elements from the storyboard
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchSuggestionsTV: UITableView!
    @IBOutlet weak var currentAddressLbl: UILabel!
    @IBOutlet weak var addressSaverBtn: UIButton!
    // Action when the "Save Address" button is pressed
    @IBAction func saveAddress(_ sender: UIButton) {
        // Check if there's a chosen map place
        if let mapPlace = currentMapPlace {
            // Pass the mapPlace to the delegate and perform a back segue
            mapPlaceDelegate?.passMapLocation(mapPlace, at: addressIndex)
        }
        // Pop the view controller to go back
        navigationController?.popViewController(animated: true)
    }
    // Delegate to handle passing map items
    weak var mapPlaceDelegate: MapPlaceDelegate?
    // Variables to store current address information
    var addressIndex : Int!
    var currentMapPlace : MKMapItem! {
        didSet {
            // When the current chosen map place is set, enable the save button
            if addressSaverBtn != nil {
            enableButton(addressSaverBtn)
            }
        }
    }
    // Instances for search, location, and gestures
    private lazy var searchBarCompleter = MKLocalSearchCompleter()
    private var results = [MKLocalSearchCompletion]()
    private let locationManager = CLLocationManager()
    private var tapGestureRecognizer = UITapGestureRecognizer()
    private var doubleTap = UITapGestureRecognizer()
    
    // Function called when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize the view and set up UI elements
        // Check the current address index and set the navigation title accordingly
        if addressIndex == 0 {
            navigationController?.topViewController?.navigationItem.title = "Starting Location"
        }
        else {
            navigationController?.topViewController?.navigationItem.title = "Address Number\(addressIndex as Int)"
        }
        // If there's a previously chosen map place, update the view
        if currentMapPlace != nil {
           updateCurrentLocation(at: currentMapPlace.placemark.coordinate, with: currentMapPlace.name!)
        }
        // Set the navigation delegate
        navigationController?.delegate = self as? UINavigationControllerDelegate
        // Configure search bar and completer
        searchAndCompletion()
        // Configure the table view for address suggestions
        assembleTV()
        // Configure the location manager for user location
        configureLM()
        // Hide the keyboard when tapping around the view
        self.hideKeyboardWhenTappedOutside()
        // Update and configure the "Save Address" button
        updateAddressLbl()
        disableButton(addressSaverBtn)
        addressSaverBtn.layer.cornerRadius = 4.0
        // Set up gesture recognitions for map interaction
        configureGestureRecognition()
    }
    
    // Function to reverse geocode a coordinate into a placemark
    func getPlacemarkt(_ coordinate: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Create a CLLocation object from the given coordinate
        let givenLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // Create a geocoder for reverse geocoding
        let coreLocationGeocoder = CLGeocoder()
        // Look up the location and pass it to the completion handler
        coreLocationGeocoder.reverseGeocodeLocation(givenLocation,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                // If geocoding is successful, get the first placemark and pass it
                                                let firstPlacemark = placemarks?[0]
                                                completionHandler(firstPlacemark)
                                            }
                                            else {
                                                // An error occurred during geocoding, so pass nil to the completion handler
                                                completionHandler(nil)
                                            }
        })
        
    }
    
    /**
 
     Switch between the table view and the map view.
 */
    
    func switchView() {
        searchSuggestionsTV.isHidden = !searchSuggestionsTV.isHidden
        mapView.isHidden = !mapView.isHidden
    }
    
    // Function to launch a search request with a completion
    func MKsearchRequest(with completion: MKLocalSearchCompletion) {
        let localSearchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: localSearchRequest)
        search.start { (response, error) in
            if let searchResponse = response?.mapItems[0].placemark {
                // Set the search bar text to the completion title and update the current address
                self.searchBar.text = completion.title
                self.updateCurrentLocation(at: searchResponse.coordinate, with: searchResponse.name!)
            }
            
        }
    }
    
    // Function to update the current address and associated map item
    func updateCurrentLocation(at coordinates: CLLocationCoordinate2D, with title: String) {
        // Show the location on the map with a pin
        showLocation(at: coordinates, with: title)
        // Create a new MKMapItem with the updated coordinate and title
        currentMapPlace = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        currentMapPlace?.name = title
        // Update the label displaying the current address
        updateAddressLbl()
    }
    
    /**
     
     Replace the pin according to the new chosen address.
 */
    func showLocation(at coordinates: CLLocationCoordinate2D, with title: String) {
        // Remove any existing annotations from the map
        mapView.removeAnnotations(mapView.annotations)
        // Set the center and span of the map's visible region
        let mapCenter = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        // Set the span of the map's visible region
        let mapSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // Set map's visible region
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        // Set the map's visible region to the new coordinates
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude)
        mapAnnotation.title = title
        mapView.addAnnotation(mapAnnotation)
    }
    
    // Function to configure the search bar and completer
    func searchAndCompletion() {
        // Set the search bar delegate to self, allowing this class to respond to search bar events.
        searchBar.delegate = self
        // Set the search bar completer delegate to self, allowing this class to respond to completer events.
        searchBarCompleter.delegate = self
        // Set a placeholder text for the search bar.
        searchBar.placeholder = "Search for a location"
    }
    
    // Function to configure the table view for address suggestions
    func assembleTV() {
        // Set the data source for the search suggestions table view to self.
        searchSuggestionsTV.dataSource = self
        // Set the delegate for the search suggestions table view to self.
        searchSuggestionsTV.delegate = self
        // Hide the extra empty cells in the table view.
        searchSuggestionsTV.tableFooterView = UIView()
        // Initially, hide the search suggestions table view.
        searchSuggestionsTV.isHidden = true
    }
    
    // Function to configure the location manager for user location services
    func configureLM() {
        // Set the delegate for the location manager to self, allowing this class to respond to location manager events.
        locationManager.delegate = self
        // Request authorization to use location services when the app is in use.
        locationManager.requestWhenInUseAuthorization()
        // Check if location services are enabled, and if so, set the desired accuracy and request the user's location.
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
    }
    
    
    
    // Function to configure gesture recognition for map interaction
    func configureGestureRecognition() {
        // Configure a single-tap gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.mapTapped(sender:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGestureRecognizer)
        // Configure a double-tap gesture recognizer
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    // Function to update the text and appearance of the current address label
    func updateAddressLbl() {
        // Create a paragraph style for centered alignment
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        // Create a paragraph style for left-aligned text
        let leadingParagraphStyle = NSMutableParagraphStyle()
        leadingParagraphStyle.alignment = .left
        // Create a bold font with a specified font size
        let bold = UIFont.boldSystemFont(ofSize: searchAddressViewController.defaultSearchResultTitleSize)
        // Define attributes for the attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle : centeredParagraphStyle,
            .foregroundColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
            // Use the bold font with the specified size
            .font : bold
        ]
        
        // Create a mutable attributed string with the initial text
        let currentAttributedString = NSMutableAttributedString(string: "Current address:\n\n \(currentMapPlace?.name ?? "")", attributes: attributes)
        // Create a normal font with the same font size
        let normal = UIFont.systemFont(ofSize: searchAddressViewController.defaultSearchResultTitleSize)
        // Apply the normal font to the first 15 characters (excluding the line breaks)
        currentAttributedString.addAttribute(NSAttributedString.Key.font, value: normal, range: NSMakeRange(0, 15))
        // Set the maximum number of lines for the label
        currentAddressLbl.numberOfLines = 4
        // Set the line break mode to wrap words
        currentAddressLbl.lineBreakMode = .byWordWrapping
        // Assign the attributed text to the current address label
        currentAddressLbl.attributedText = currentAttributedString
    }
}

// Conformance to UISearchBarDelegate for handling search bar interactions
extension searchAddressViewController: UISearchBarDelegate {
    // Called when the search bar begins editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchSuggestionsTV.isHidden {
            switchView()
        }
    }

    // Called when the search button is clicked
    func searchBtnClicked(_ searchBar: UISearchBar) {
        if !results.isEmpty {
            // Retrieve the first auto-completion result
            let searchSuggestion = results[0]
            // Launch a search request with the selected completion
            MKsearchRequest(with: searchSuggestion)
        }
        view.endEditing(true)
        if !searchSuggestionsTV.isHidden {
            switchView()
        }
    }
    
    // Called when the search bar text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Check if the search suggestions table view is hidden, and if so, toggle its visibility.
        if searchSuggestionsTV.isHidden {
            switchView()
        }
        // Check if the entered search text is not empty.
        if !searchText.isEmpty {
            // Update the search completer's query with the entered text
            searchBarCompleter.queryFragment = searchText
        }
    }
}

// Conformance to UITableViewDelegate and UITableViewDataSource for handling table view data
extension searchAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Number of sections in the table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    // Create and configure table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable table view cell with the specified identifier for the given index path.
        let TVcell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        // Get the search result for the current row.
        let searchResult = results[indexPath.row]
        // Set the attributed text for the main title with highlighted ranges
        TVcell.textLabel?.attributedText = NSAttributedString.highlightedText(searchResult.title, ranges: searchResult.titleHighlightRanges, fontSize: searchAddressViewController.defaultSearchResultTitleSize)
        // Set the attributed text for the detail subtitle with highlighted ranges.
        TVcell.detailTextLabel?.attributedText = NSAttributedString.highlightedText(searchResult.subtitle, ranges: searchResult.subtitleHighlightRanges, fontSize: searchAddressViewController.defaultSearchResultSubtitleSize)
        // Return the configured table view cell.
        return TVcell
    }
    
    // Handle table view row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the selected row with animation.
        tableView.deselectRow(at: indexPath, animated: true)
        // Retrieve the selected search completion for the selected row.
        let TVcompletion = results[indexPath.row]
        // Launch a search request with the selected completion
        MKsearchRequest(with: TVcompletion)
        // End editing to dismiss the keyboard.
        view.endEditing(true)
        // Switch the view back to its initial state.
        switchView()
        
    }
    
    // Conformance to UIScrollViewDelegate for handling the beginning of scroll view dragging
    func scrollViewDrag(_ scrollView: UIScrollView) {
        // This function is called when the user starts dragging the scroll view. It is used to dismiss the keyboard.
        view.endEditing(true)
    }
}

// Conformance to MKLocalSearchCompleterDelegate for handling search completions
extension searchAddressViewController: MKLocalSearchCompleterDelegate {
    // Called when the search scompleter updates results
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Update the search results with the results from the completer
        results = completer.results
        // Reload the suggestions table view to display the updated results
        searchSuggestionsTV.reloadData()
    }
    // Called when the search completer encounters an error
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Print the error message to the console
        print(error.localizedDescription)
    }
}

// Extension for creating attributed text with highlighted ranges
extension NSAttributedString {
    static func highlightedText(_ text: String, ranges: [NSValue], fontSize: CGFloat) -> NSAttributedString {
        // Create an attributed string with the specified text
        let attributedText = NSMutableAttributedString(string: text)
        // Create a font with the given font size
        var stringFont = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        // Scale the font using the body text style
        stringFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: stringFont)
        // Apply the font to the entire text
        attributedText.addAttribute(.font, value: stringFont, range: NSMakeRange(0, text.count))
        // Create a bold font with the same font size
        let stringBold = UIFont.boldSystemFont(ofSize: fontSize)
        // Iterate through the provided ranges and apply the bold font to those ranges
        for value in ranges {
            attributedText.addAttribute(.font, value: stringBold, range: value.rangeValue)
        }
        return attributedText
    }
}

// Conformance to CLLocationManagerDelegate for handling location updates and errors
extension searchAddressViewController: CLLocationManagerDelegate {
    // Called when the location manager receives location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentMapPlace == nil {
            // Retrieve the user's current location coordinates
            let userLocationCoordinate = locations[0].coordinate
            // Obtain the placemark for the user's location
            getPlacemarkt(userLocationCoordinate, completionHandler: { (placemark) in
                if let userLocationPlacemark = placemark {
                    // Update the current address with the user's location and placemark information
                    self.updateCurrentLocation(at: userLocationCoordinate, with: "\(userLocationPlacemark.name ?? "") ")
                }
            })
            
        }
    }
    
    // Called when the location manager encounters an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Print the error message to the console
        print("Error \(error)")
    }
    
}

// Conformance to UIGestureRecognizerDelegate for gesture recognition
extension searchAddressViewController: UIGestureRecognizerDelegate {
    // Implement the gesture recognizer delegate method for recognizing gestures
    func addressChooserGestureRecognizer(_ addressChooserGestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Don't recognize a single tap until a double-tap fails.
        if addressChooserGestureRecognizer == self.tapGestureRecognizer &&
            otherGestureRecognizer == self.doubleTap {
            return true
        }
        return false
    }
    
    // This function is called when the user taps on the map.
    @objc func mapTapped(sender: UITapGestureRecognizer) {
        // Place a pin where the user tapped on the map.
        switch sender.state {
            
        // Check if the tap gesture has ended.
        case .ended:
            // Clear the search bar text to provide visual feedback.
            searchBar.text = ""
            // Get the location where the user tapped on the map.
            let tappedLocation = sender.location(in: mapView)
            // Convert the tap location to geographical coordinates.
            let tappedLocationCoordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
            getPlacemarkt(tappedLocationCoordinate, completionHandler: { (placemark) in
                // If a placemark is obtained for the tap location:
                if let tappedLocationPlacemark = placemark {
                    // Update the current address with the tap location's information.
                    self.updateCurrentLocation(at: tappedLocationCoordinate, with: "\(tappedLocationPlacemark.name ?? "") ")
                }
            })
        // For other states of the gesture, do nothing.
        default: break
        }
    }
}

// Extension for defining default search result title and subtitle font sizes
extension searchAddressViewController {
    static let defaultSearchResultTitleSize: CGFloat = 17.0
    static let defaultSearchResultSubtitleSize: CGFloat = 12.0
}

// Extension for UIViewController to hide the keyboard when tapped outside
extension UIViewController {
    // This function adds a tap gesture recognizer to hide the keyboard when tapping outside of text input fields.
    func hideKeyboardWhenTappedOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // This function is called to dismiss the keyboard when tapped outside of text input fields.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

