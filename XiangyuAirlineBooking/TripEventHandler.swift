//
//  TripEventHandler.swift
//  XiangyuAirlineBooking
//
//  Created by revenue on 24/12/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import Foundation
import Combine
import Intents

extension Notification.Name {
    static let tripViewNotification = Notification.Name("tripViewNotification")
    static let tripFlightDidCancelNotification = Notification.Name("tripFlightDidCancelNotification")
    static let seatAssignedNotification = Notification.Name("seatAssignedNotification")
}

class TripEventHandler {
    private let refreshEvent: AnyCancellable
    private let flightCancell: AnyCancellable
    private let seatAssigned: AnyCancellable
    
    
    init() {
        refreshEvent = NotificationCenter.default.publisher(for: .tripViewNotification).sink { (notification) in
            (notification.object as! Booking).addTrip()
        }
        
        flightCancell = NotificationCenter.default.publisher(for: .tripFlightDidCancelNotification).sink { (notification) in
            
        }
        
        seatAssigned = NotificationCenter.default.publisher(for: .seatAssignedNotification).sink { (notification) in
                   
        }
    }
    
}


extension Booking {
     func addTrip() {
        let reservations: [INReservation] = flights.reduce(into: []) { (result, flight) in
            var aResult = result
            let inFlight = IntentModel.makeFlight(flightDepartureDateComponents: flight.depatureDate,
                                                  flightBoardingDateComponents: flight.boardingDate,
                                                  flightArrivalDateComponents: flight.arrivalDate)
            
            return aResult.append(contentsOf: inFlight.makeReservationsForPax(self, checkInValidDuration: flight.checkinValidDuration))
        }
        
        
        /// PNR as container reference
        let reservationContainerReference = INSpeakableString(vocabularyIdentifier: pnr,
                                                              spokenPhrase: tripDescription,
                                                              pronunciationHint: nil)
        
        Server.sharedInstance.reservationContainersDictionary[reservationContainerReference] = reservations
    }
    
}
