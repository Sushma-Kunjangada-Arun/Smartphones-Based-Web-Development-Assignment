//
//  DestinationView.swift
//  EmptyApp
//
//  Created by Sushma K A on 2/23/25.
//  Copyright © 2025 rab. All rights reserved.
//

import UIKit

class DestinationView: UIView {
    
    weak var delegate: NavigationDelegate?
    
    let destinationIDField = UITextField()
    let cityField = UITextField()
    let countryField = UITextField()
    let destinationsList = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        // Back Button
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.text = "Manage Destinations"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: 50, width: UIScreen.main.bounds.width - 40, height: 40)
        addSubview(titleLabel)

        let fields = [destinationIDField, cityField, countryField]
        let placeholders = ["Enter Destination ID (Optional)", "Enter City", "Enter Country"]
        var yPos: CGFloat = 100

        for (index, field) in fields.enumerated() {
            field.placeholder = placeholders[index]
            field.borderStyle = .roundedRect
            field.frame = CGRect(x: 50, y: yPos, width: 250, height: 40)
            addSubview(field)
            yPos += 50
        }

        let addButton = createButton(title: "Add Destination", action: #selector(addDestination), yPos: yPos, color: .systemGreen)
        let fetchButton = createButton(title: "Fetch Destination", action: #selector(fetchDestination), yPos: yPos + 50, color: .systemGray)
        let updateButton = createButton(title: "Update Destination", action: #selector(updateDestination), yPos: yPos + 100, color: .systemOrange)
        let deleteButton = createButton(title: "Delete Destination", action: #selector(deleteDestination), yPos: yPos + 150, color: .systemRed)
        let displayButton = createButton(title: "Display All Destinations", action: #selector(displayDestinations), yPos: yPos + 200, color: .systemBlue)

        addSubview(addButton)
        addSubview(fetchButton)
        addSubview(updateButton)
        addSubview(deleteButton)
        addSubview(displayButton)

        destinationsList.frame = CGRect(x: 20, y: yPos + 260, width: UIScreen.main.bounds.width - 40, height: 250)
        destinationsList.isEditable = false
        destinationsList.isHidden = true
        addSubview(destinationsList)
    }
    
    @objc func goBack() {
            delegate?.navigateToMainView()
    }

    func createButton(title: String, action: Selector, yPos: CGFloat, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 50, y: yPos, width: 250, height: 40)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    
    @objc func addDestination() {
        guard let city = cityField.text, !city.isEmpty, isValidString(city),
              let country = countryField.text, !country.isEmpty, isValidString(country) else {
            showAlert(title: "Invalid Input", message: "City & Country must be non-empty and contain only letters")
            destinationsList.isHidden = true
            return
        }

        let existingDestinations = TripPlannerManager.getDestinations()
        var newID: Int

        if let idText = destinationIDField.text, let userProvidedID = Int(idText) {
            if existingDestinations.contains(where: { $0.id == userProvidedID }) {
                showAlert(title: "ID Exists", message: "Destination ID already exists. Use a different ID")
                destinationsList.isHidden = true
                return
            }
            newID = userProvidedID
        } else {
            newID = (existingDestinations.map { $0.id }.max() ?? 0) + 1
        }

        let result = TripPlannerManager.addDestination(id: newID, city: city, country: country)

        switch result {
        case .success:
            showAlert(title: "Destination Added", message: "Your destination has been saved")
            clearFields()
            destinationsList.isHidden = true
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @objc func fetchDestination() {
        guard let idText = destinationIDField.text, let id = Int(idText) else {
            showAlert(title: "Invalid ID", message: "Enter a valid Destination ID")
            destinationsList.isHidden = true
            clearFields()
            return
        }

        let destinations = TripPlannerManager.getDestinations()
        guard let destination = destinations.first(where: { $0.id == id }) else {
            showAlert(title: "Not Found", message: "No destination found with this ID")
            destinationsList.isHidden = true
            clearFields()
            return
        }

        cityField.text = destination.city
        countryField.text = destination.country
    }

    @objc func updateDestination() {
        guard let idText = destinationIDField.text, let id = Int(idText),
              let updatedCity = cityField.text, !updatedCity.isEmpty, isValidString(updatedCity) else {
            showAlert(title: "Invalid Input", message: "Please fetch the destination first and update the fields")
            destinationsList.isHidden = true
            return
        }

        let destinations = TripPlannerManager.getDestinations()
        guard let existingDestination = destinations.first(where: { $0.id == id }) else {
            showAlert(title: "Destination Not Found", message: "No destination exists with this ID")
            destinationsList.isHidden = true
            return
        }

        if let updatedCountry = countryField.text, !updatedCountry.isEmpty, updatedCountry != existingDestination.country {
            showAlert(title: "Update Not Allowed", message: "The country cannot be changed")
            destinationsList.isHidden = true
            return
        }

        let result = TripPlannerManager.updateDestination(id: id, newCity: updatedCity)

        switch result {
        case .success:
            showAlert(title: "Destination Updated", message: "Destination details updated successfully.")
            clearFields()
            destinationsList.isHidden = true
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @objc func deleteDestination() {
        guard let idText = destinationIDField.text, let id = Int(idText) else {
            showAlert(title: "Invalid ID", message: "Enter a valid Destination ID to delete")
            destinationsList.isHidden = true
            clearFields()
            return
        }

        let trips = TripPlannerManager.getTrips()
        if trips.contains(where: { $0.destination_id == id }) {
            showAlert(title: "Cannot Delete", message: "Trips are linked to this destination, delete trips first")
            destinationsList.isHidden = true
            clearFields()
            return
        }

        let result = TripPlannerManager.deleteDestination(id: id)

        switch result {
        case .success:
            showAlert(title: "Destination Deleted", message: "The destination has been deleted")
            clearFields()
            destinationsList.isHidden = true
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @objc func displayDestinations() {
        let destinations = TripPlannerManager.getDestinations()
        if destinations.isEmpty {
            showAlert(title: "No Destinations", message: "No destinations have been added yet")
        } else {
            destinationsList.text = destinations.map { "\($0.id): \($0.city), \($0.country)" }.joined(separator: "\n")
            destinationsList.isHidden = false
        }
    }

    func clearFields() {
        cityField.text = ""
        countryField.text = ""
        destinationIDField.text = ""
    }

    func isValidString(_ text: String) -> Bool {
        let regex = "^[A-Za-z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
