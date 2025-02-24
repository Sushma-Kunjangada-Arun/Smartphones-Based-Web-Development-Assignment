//
//  MainView.swift
//  EmptyApp
//
//  Created by Sushma K A on 2/23/25.
//  Copyright © 2025 rab. All rights reserved.
//

import UIKit

class MainView: UIView {
    
    weak var delegate: NavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "🌍 Welcome to Trip Planner ✈️"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: 40)
        addSubview(titleLabel)

        let manageDestinationsButton = createButton(title: "📍 Manage Destinations", action: #selector(openDestinations), yPos: 200)
        let manageTripsButton = createButton(title: "🛄 Manage Trips", action: #selector(openTrips), yPos: 260)

        addSubview(manageDestinationsButton)
        addSubview(manageTripsButton)
    }
    
    func createButton(title: String, action: Selector, yPos: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 50, y: yPos, width: UIScreen.main.bounds.width - 100, height: 50)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func openDestinations() {
            delegate?.navigateToDestinationView()
        }

        @objc func openTrips() {
            delegate?.navigateToTripView()
        }
}
