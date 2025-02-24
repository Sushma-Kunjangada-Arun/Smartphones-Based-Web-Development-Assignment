//
//  TripView.swift
//  EmptyApp
//
//  Created by Sushma K A on 2/23/25.
//  Copyright © 2025 rab. All rights reserved.
//

import UIKit

class TripView: UIView {
    
    weak var delegate: NavigationDelegate?

    let tripIDField = UITextField()
    let titleField = UITextField()
    let startDateField = UITextField()
    let endDateField = UITextField()
    let descriptionField = UITextField()
    let destinationField = UITextField()
    let tripsList = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.text = "Manage Trips"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: 50, width: UIScreen.main.bounds.width - 40, height: 40)
        addSubview(titleLabel)

        let fields = [tripIDField, titleField, startDateField, endDateField, descriptionField, destinationField]
        let placeholders = ["Enter Trip ID (Optional)", "Enter Trip Title", "Start Date (YYYY-MM-DD)", "End Date (YYYY-MM-DD)", "Trip Description", "Destination ID"]
        var yPos: CGFloat = 100

        for (index, field) in fields.enumerated() {
            field.placeholder = placeholders[index]
            field.borderStyle = .roundedRect
            field.frame = CGRect(x: 50, y: yPos, width: 250, height: 40)
            addSubview(field)
            yPos += 50
        }

        let addButton = createButton(title: "Add Trip", action: #selector(addTrip), yPos: yPos, color: .systemGreen)
        let fetchButton = createButton(title: "Fetch Trip", action: #selector(fetchTripDetails), yPos: yPos + 50, color: .systemGray)
        let updateButton = createButton(title: "Update Trip", action: #selector(updateTrip), yPos: yPos + 100, color: .systemOrange)
        let deleteButton = createButton(title: "Delete Trip", action: #selector(deleteTrip), yPos: yPos + 150, color: .systemRed)
        let displayButton = createButton(title: "Display All Trips", action: #selector(displayTrips), yPos: yPos + 200, color: .systemBlue)

        addSubview(addButton)
        addSubview(fetchButton)
        addSubview(updateButton)
        addSubview(deleteButton)
        addSubview(displayButton)

        tripsList.frame = CGRect(x: 20, y: yPos + 260, width: UIScreen.main.bounds.width - 40, height: 250)
        tripsList.isEditable = false
        tripsList.isHidden = true
        addSubview(tripsList)
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


    @objc func addTrip() {
        guard let title = titleField.text, !title.isEmpty,
              let startDate = startDateField.text, !startDate.isEmpty, isValidDateFormat(startDate),
              let endDate = endDateField.text, !endDate.isEmpty, isValidDateFormat(endDate),
              let description = descriptionField.text, !description.isEmpty,
              let destinationID = Int(destinationField.text ?? "") else {
            showAlert(title: "Invalid Input", message: "Ensure all fields are filled correctly")
            tripsList.isHidden = true
            return
        }

        let destinations = TripPlannerManager.getDestinations()
        guard destinations.contains(where: { $0.id == destinationID }) else {
            showAlert(title: "Destination Not Found", message: "Check the ID and try again")
            tripsList.isHidden = true
            return
        }

        let result = TripPlannerManager.addTrip(title: title, startDate: startDate, endDate: endDate, description: description, destinationID: destinationID)

        switch result {
        case .success:
            showAlert(title: "Trip Added", message: "Your trip has been saved")
            tripsList.isHidden = true
            clearFields()
            
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @objc func fetchTripDetails() {
        guard let tripIDText = tripIDField.text, let tripID = Int(tripIDText) else {
            showAlert(title: "Invalid Input", message: "Enter a valid Trip ID")
            tripsList.isHidden = true
            clearFields()
            return
        }

        let trips = TripPlannerManager.getTrips()
        guard let trip = trips.first(where: { $0.id == tripID }) else {
            showAlert(title: "Trip Not Found", message: "No trip found with this ID")
            tripsList.isHidden = true
            clearFields()
            return
        }

        titleField.text = trip.title
        startDateField.text = trip.start_date
        endDateField.text = trip.end_date
        descriptionField.text = trip.description
        destinationField.text = "\(trip.destination_id)"
    }

    @objc func updateTrip() {
        guard let tripIDText = tripIDField.text, let tripID = Int(tripIDText),
              let updatedTitle = titleField.text, !updatedTitle.isEmpty,
              let updatedEndDate = endDateField.text, !updatedEndDate.isEmpty, isValidDateFormat(updatedEndDate),
              let updatedDescription = descriptionField.text, !updatedDescription.isEmpty else {
            showAlert(title: "Invalid Input", message: "Ensure fields are filled correctly")
            tripsList.isHidden = true
            return
        }

        let trips = TripPlannerManager.getTrips()
        guard let existingTrip = trips.first(where: { $0.id == tripID }) else {
            showAlert(title: "Trip Not Found", message: "No trip exists with this ID")
            tripsList.isHidden = true
            return
        }

        // **Prevent updating Start Date**
        if let newStartDate = startDateField.text, !newStartDate.isEmpty, newStartDate != existingTrip.start_date {
            showAlert(title: "Update Not Allowed", message: "Start date cannot be changed")
            startDateField.text = existingTrip.start_date
            tripsList.isHidden = true
            return
        }

        // **Prevent updating Destination ID**
        if let newDestinationIDText = destinationField.text, let newDestinationID = Int(newDestinationIDText),
           newDestinationID != existingTrip.destination_id {
            showAlert(title: "Update Not Allowed", message: "Destination ID cannot be changed")
            destinationField.text = "\(existingTrip.destination_id)"
            tripsList.isHidden = true
            return
        }

        let result = TripPlannerManager.updateTrip(id: tripID, newTitle: updatedTitle, newEndDate: updatedEndDate, newDescription: updatedDescription)

        switch result {
        case .success:
            showAlert(title: "Trip Updated", message: "The trip has been updated successfully")
            clearFields()
            tripsList.isHidden = true
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }


    @objc func deleteTrip() {
        guard let tripIDText = tripIDField.text, let tripID = Int(tripIDText) else {
            showAlert(title: "Invalid Input", message: "Enter a valid Trip ID to delete")
            tripsList.isHidden = true
            clearFields()
            return
        }

        let result = TripPlannerManager.deleteTrip(id: tripID)

        switch result {
        case .success:
            showAlert(title: "Trip Deleted", message: "The trip has been successfully deleted")
            clearFields()
            tripsList.isHidden = true
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    @objc func displayTrips() {
        let trips = TripPlannerManager.getTrips()
        let destinations = TripPlannerManager.getDestinations()

        if trips.isEmpty {
            showAlert(title: "No Trips", message: "No trips have been added yet")
        } else {
            var text = "Trips:\n"
            for trip in trips {
                if let destination = destinations.first(where: { $0.id == trip.destination_id }) {
                    text += "\(trip.id): \(trip.title) (\(destination.city)) - \(trip.start_date) to \(trip.end_date)\n"
                } else {
                    text += "\(trip.id): \(trip.title) (Unknown Destination) - \(trip.start_date) to \(trip.end_date)\n"
                }
            }
            tripsList.text = text
            tripsList.isHidden = false
        }
    }


    func clearFields() {
        tripIDField.text = ""
        titleField.text = ""
        startDateField.text = ""
        endDateField.text = ""
        descriptionField.text = ""
        destinationField.text = ""
    }

    func isValidDateFormat(_ date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: date) != nil
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
