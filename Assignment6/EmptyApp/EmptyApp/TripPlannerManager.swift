//
//  TripPlannerManager.swift
//  EmptyApp
//
//  Created by Sushma K A on 2/23/25.
//  Copyright © 2025 rab. All rights reserved.
//

import Foundation

// Handling Enum
enum TripPlannerError: Error {
    case destinationNotFound
    case tripNotFound
    case tripAlreadyStarted
    case destinationHasLinkedTrips
    case emptyFields
    case invalidDestination

    var localizedDescription: String {
        switch self {
        case .destinationNotFound:
            return "Destination not found"
        case .tripNotFound:
            return "Trip not found"
        case .tripAlreadyStarted:
            return "Cannot delete this trip. It has already started!"
        case .destinationHasLinkedTrips:
            return "Cannot delete this destination. There are trips linked to it!"
        case .emptyFields:
            return "All fields must be filled"
        case .invalidDestination:
            return "Invalid Destination ID. Please select a valid destination!"
        }
    }
}

// Destination Model
struct Destination {
    let id: Int
    var city: String
    let country: String
}

// Trip Model
struct Trip {
    let id: Int
    let destination_id: Int
    var title: String
    let start_date: String
    var end_date: String
    var description: String
}

class TripPlannerManager {
    static var destinations: [Destination] = []
    static var trips: [Trip] = []

    // **Generate Next Destination ID**
    private static func generateNextDestinationID() -> Int {
        return (destinations.map { $0.id }.max() ?? 0) + 1
    }

    // **Generate Next Trip ID**
    private static func generateNextTripID() -> Int {
        return (trips.map { $0.id }.max() ?? 0) + 1
    }

    static func addDestination(id: Int, city: String, country: String) -> Result<Destination, TripPlannerError> {
        if city.isEmpty || country.isEmpty {
            return .failure(.emptyFields)
        }

        // Ensure ID does not already exist
        if destinations.contains(where: { $0.id == id }) {
            return .failure(.invalidDestination)
        }

        let newDestination = Destination(id: id, city: city, country: country)
        destinations.append(newDestination)
        return .success(newDestination)
    }

    // **Get All Destinations**
    static func getDestinations() -> [Destination] {
        return destinations
    }

    // **Update Destination (Only the city can be updated)**
    static func updateDestination(id: Int, newCity: String) -> Result<Bool, TripPlannerError> {
        if newCity.isEmpty {
            return .failure(.emptyFields)
        }

        if let index = destinations.firstIndex(where: { $0.id == id }) {
            destinations[index].city = newCity
            return .success(true)
        }
        
        return .failure(.destinationNotFound)
    }

    // **Delete Destination (Only if no linked trips exist)**
    static func deleteDestination(id: Int) -> Result<Bool, TripPlannerError> {
        if trips.contains(where: { $0.destination_id == id }) {
            return .failure(.destinationHasLinkedTrips)
        }

        if let index = destinations.firstIndex(where: { $0.id == id }) {
            destinations.remove(at: index)
            return .success(true)
        }

        return .failure(.destinationNotFound)
    }

    // **Add a New Trip**
    static func addTrip(title: String, startDate: String, endDate: String, description: String, destinationID: Int) -> Result<Trip, TripPlannerError> {
        if title.isEmpty || startDate.isEmpty || endDate.isEmpty || description.isEmpty {
            return .failure(.emptyFields)
        }

        guard destinations.contains(where: { $0.id == destinationID }) else {
            return .failure(.invalidDestination)
        }

        let newID = generateNextTripID()
        let newTrip = Trip(id: newID, destination_id: destinationID, title: title, start_date: startDate, end_date: endDate, description: description)
        trips.append(newTrip)
        return .success(newTrip)
    }

    // **Get All Trips**
    static func getTrips() -> [Trip] {
        return trips
    }

    // **Update Trip (Only title, end_date, and description can be updated)**
    static func updateTrip(id: Int, newTitle: String?, newEndDate: String?, newDescription: String?) -> Result<Bool, TripPlannerError> {
        if let index = trips.firstIndex(where: { $0.id == id }) {
            if let title = newTitle, !title.isEmpty {
                trips[index].title = title
            }
            if let endDate = newEndDate, !endDate.isEmpty {
                trips[index].end_date = endDate
            }
            if let description = newDescription, !description.isEmpty {
                trips[index].description = description
            }
            return .success(true)
        }
        return .failure(.tripNotFound)
    }

    // **Delete Trip (Only if it hasn't started)**
    static func deleteTrip(id: Int) -> Result<Bool, TripPlannerError> {
        if let index = trips.firstIndex(where: { $0.id == id }) {
            let trip = trips[index]
            let currentDate = getCurrentDate()

            if currentDate >= trip.start_date {
                return .failure(.tripAlreadyStarted)
            }

            trips.remove(at: index)
            return .success(true)
        }

        return .failure(.tripNotFound)
    }

    // **Helper function to get the current date in "YYYY-MM-DD" format**
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
