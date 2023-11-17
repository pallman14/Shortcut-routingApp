//  Price Allman
//  addLocationsViewController.swift
//  Shortcut


import UIKit
import MapKit

// Conforming to MapPlaceDelegate to receive selected map places from child view controllers
class addLocationsViewController: UIViewController, MapPlaceDelegate {
    // Implementing the method from MapPlaceDelegate to receive selected map places
    func passMapLocation(_ mapPlace: MKMapItem, at index: Int) {
        // Assigning the received mapPlace to the userStops array at the specified index
        userStops[index] = mapPlace
    }
    
    //Mark: - IBOutlet's

    // UITableView to display saved addresses
    @IBOutlet weak var addressesTableView: UITableView!
    // UITextField for selecting the starting point
    @IBOutlet weak var startingAddressTextField: UITextField!
    // UILabel to display the number of addresses
    @IBOutlet weak var addressCounter: UILabel!
    // UIButton to calculate the route
    @IBOutlet weak var findRouteBtn: UIButton!
    // UIButton to add a new address
    @IBOutlet weak var addLocationBtn: UIButton!
    
    // MARK: - Actions
    
    // Action to add a new address
    @IBAction func addAddress(_ sender: UIButton) {
        // Add a new, empty MKMapItem to the userStops array
        userStops.append(MKMapItem())
        // Set the name of the last added map item to "Unknown Location"
        userStops.last?.name = "Unknown Location"
        // Add an empty string to the TVdata array
        TVdata.append("")
    }
    
    // Action to calculate the route
    @IBAction func findRoute(_ sender: UIButton) {
    }
    
    // MARK: - Properties
    
    // The array passed to the routeCalculator, containing all saved places as MKMapItems. Will be passed to the routeCalculator. The starting point is stored at the position 0.
    var userStops = [MKMapItem]() {
        // Enable/disable the buttons depending on the number of places the user has given.
        didSet {
            // If addLocationBtn is enabled and the table view data count is 5, disable the addLocationBtn.
            if addLocationBtn.isEnabled && TVdata.count == 5 {
                disableButton(addLocationBtn)
            }
            // If addLocationBtn is disabled and the table view data count is less than 5, enable the addLocationBtn.
            if !addLocationBtn.isEnabled && TVdata.count < 5 {
                enableButton(addLocationBtn)
            }
            // If findRouteBtn is enabled and the table view data count is 0, disable the findRouteBtn.
            if findRouteBtn.isEnabled && TVdata.count < 1 {
                disableButton(findRouteBtn)
            }
            // If findRouteBtn is disabled, the table view data count is greater than 0, and the starting point has a name, enable the findRouteBtn.
            if !findRouteBtn.isEnabled
                && TVdata.count > 0
                && userStops[0].name != "" {
                enableButton(findRouteBtn)
            }
        }
    }

    
    // The data array for the table view only the names of the saved places.
    var TVdata = [String]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //This method is called to ensure that there's a reserved position for the starting point in the userStops array. It adds an empty MKMapItem to the userStops array at index 0 and sets its name to an empty string if it's currently empty.
        savePositionForStartingLocation()
        // This method is called to set up the configuration for the addressesTableView (a UITableView). It assigns the dataSource and delegate to the view controller (conforming to UITableViewDataSource and UITableViewDelegate), configures layout margins, separator insets, and separator color, and hides the table view's footer.
        assembleTV()
        // Styling the findRouteBtn: The button's appearance is customized by setting its layer.cornerRadius to create rounded corners.
        findRouteBtn.layer.cornerRadius = 4.0
        //The view controller assigns itself as the delegate for the startingAddressTextField. This allows the view controller to control the behavior of the text field, such as responding to user interactions.
        startingAddressTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // If the last item in the userStops array has the name "Unknown Location," it is removed from the array. This check is likely performed to prevent empty or placeholder entries from being displayed in the table view.
        if userStops.last?.name == "Unknown Location" {
            // remove the last address
            userStops.removeLast()
            //remove the last address
            TVdata.removeLast()
        }
        // This method is called to update the text of the addressCounter. The label displays the number of addresses, and this method updates its text to reflect the current count of addresses in the TVdata array.
        updateAddressLbl()
        // This method is called to update the data displayed in the addressesTableView. It ensures that the data in the table view matches the contents of the userStops array. The starting point's name (if not empty) is displayed in the startingAddressTextField, and the names of other places are displayed in the table view cells.
        updateTVdata()
    }
    
    /* Request authorization for local notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in
        DispatchQueue.main.async {
            CLLocationManager().requestWhenInUseAuthorization()
        }
    }*/

    // MARK: - Helper Methods
    
    // Update the table view data according to the userStops array.
    func updateTVdata() {
        // Update starting point text field if available
        if userStops[0].name != "" {
           startingAddressTextField.text = userStops[0].name
        }
        
        // Update table view data with names of saved places
        if !TVdata.isEmpty {
            for index in 1...(userStops.count-1) {
                if let name = userStops[index].name {
                    TVdata[index-1] = name
                }
            }
        }
        addressesTableView.reloadData()
    }
    
    // Reserve a position for the starting point if it's empty
    func savePositionForStartingLocation() {
        if userStops.isEmpty {
            userStops.append(MKMapItem())
            userStops[0].name = ""
        }
    }
    
    // Configure the table view
    func assembleTV() {
        // Set the data source and delegate for the addressesTableView.
        addressesTableView.dataSource = self
        addressesTableView.delegate = self
        // Configure layout margins and separators for the table view cells.
        addressesTableView.layoutMargins = UIEdgeInsets.zero
        addressesTableView.separatorInset = UIEdgeInsets.zero
        // Set the separator color to a specific color.
        addressesTableView.separatorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        // Remove extra table view cell separators by using an empty footer view.
        addressesTableView.tableFooterView = UIView()
    }
    
    // Update the label text displaying the number of addresses
    func updateAddressLbl() {
        // Create a mutable paragraph style to customize text alignment.
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.alignment = .left
        // Define text attributes including paragraph style and text color.
        let paragraphAttributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle : mutableParagraphStyle,
            .foregroundColor : #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        ]
        // Create an attributed string with the specified attributes.
        let totalAttributedString = NSAttributedString(string: "Total Addresses: \(TVdata.count)", attributes: paragraphAttributes)
        // Set the attributed text to the addressCounter
        addressCounter.attributedText = totalAttributedString
    }
    
    // Prepare for segues to child view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                //segue from starting point
            case "startingPointSegue":
                if let seguedToViewController = segue.destination as? searchAddressViewController {
                    // Set the index to 0 for the starting point.
                    seguedToViewController.addressIndex = 0
                    // Pass the currently saved map place (starting point) to the destination view controller.
                    let locationSavedInCell = userStops[0]
                    if userStops[0].name != "" {
                    seguedToViewController.currentMapPlace = locationSavedInCell
                    }
                    // Set the mapPlaceDelegate to this view controller.
                    seguedToViewController.mapPlaceDelegate = self
                }
                //segue from button
            case "addLocationBtnSegue":
                if let seguedToViewController = segue.destination as? searchAddressViewController {
                    // Set the current address index to the count of TVdata (next available index).
                    seguedToViewController.addressIndex = TVdata.count
                    // Set the mapPlaceDelegate to this view controller.
                    seguedToViewController.mapPlaceDelegate = self
                }
                // Segue triggered when selecting an address cell.            case "cellSegue":
                if let cell = sender as? AddressTableViewCell,
                    let indexPath = addressesTableView.indexPath(for: cell),
                    let seguedToViewController = segue.destination as? searchAddressViewController {
                    // Set the current address index to the row index + 1 (excluding the starting point at index 0).
                    seguedToViewController.addressIndex = indexPath.row + 1
                    // Pass the map place saved in the selected cell to the destination view controller.
                    let locationSavedInCell = userStops[indexPath.row+1]
                    seguedToViewController.currentMapPlace = locationSavedInCell
                    // Set the mapPlaceDelegate to this view controller.
                    seguedToViewController.mapPlaceDelegate = self
                    
                }
            // Segue triggered when calculating the route.
            case "findRouteSegue":
                if let seguedToViewController = segue.destination as? mapBoxNavUIController {
                    // Pass the array of saved map items (addresses) to the route calculator view controller.
                    seguedToViewController.mapItems = userStops
                }
                
            default: break
            }
        }
    }
}

// Implementing UITableViewDataSource and UITableViewDelegate for the table view in addLocationsViewController.
extension addLocationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    // Define the number of sections in the table view (typically just one).
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Define the number of rows in the table view, based on the number of items in TVdata.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TVdata.count
    }
    // Define the height for each row in the table view (50 points in this case).
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    // Create and configure a cell for a specific row in the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with the identifier "cellReuseIdentifier."
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath) as! AddressTableViewCell
        // Remove layout margins to avoid unwanted spacing.
        cell.layoutMargins = UIEdgeInsets.zero
        // Set the address label text to the corresponding value from TVdata.
        cell.addressLabel.text = TVdata[indexPath.row]
        return cell
    }
    
    // Handle editing actions for table view cells (e.g., deletion).
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from TVdata and userStops corresponding to the deleted row.
            TVdata.remove(at: indexPath.row)
            // Delete the row from the table view with a fade animation.
            userStops.remove(at: indexPath.row+1)
            // Update the label displaying the number of addresses.
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateAddressLbl()
        }
        else if editingStyle == .insert {
            // Insertion can be handled here if needed.
        }
    }
}


// MARK: - UITextFieldDelegate

// Implementing UITextFieldDelegate to handle user interactions with the text field.
extension addLocationsViewController: UITextFieldDelegate {
    // Handle the user interaction when clicking on the text field.
    // In this case, it performs a segue to the starting point selection screen.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Perform the "startingPointSegue" when the text field is tapped.
        performSegue(withIdentifier: "startingPointSegue", sender: textField)
        // Return false to prevent keyboard input.
        return false
    }
}

// MARK: - UIViewController Extensions

// Extensions for UIViewController to provide common button enabling and disabling functions.
extension UIViewController {
    // Disable a UIButton by setting its isEnabled property to false and changing its appearance.
    func disableButton(_ button: UIButton) {
        button.isEnabled = false
        button.backgroundColor? = UIColor.gray
        button.alpha = 0.2
    }
    
    // Enable a UIButton by setting its isEnabled property to true and restoring its appearance.
    func enableButton(_ button: UIButton) {
        button.isEnabled = true
        button.backgroundColor? = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.alpha = 1
    }
}
