//
//  IntentModel.swift
//  XiangyuAirlineBooking
//
//  Created by revenue on 15/12/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import Foundation
import Intents

class IntentModel {
    static func makeFlight(flightDepartureDateComponents: DateComponents,
                           flightBoardingDateComponents: DateComponents,
                           flightArrivalDateComponents: DateComponents) -> INFlight{
        
        /**
         * The reserved flight departs from OSL airport and arrives at SFO airport.
         *
         * - Note: If you don't know both the IATA and ICAO code, it's OK to only use one of them.
         * - Note: If you don't know the terminal or gate, it's OK to set them to nil.
         */
        let departureAirport = INAirport(name: "Dubai International", iataCode: "DXB", icaoCode: nil)
        let departureAirportGate = INAirportGate(airport: departureAirport, terminal: "3", gate: nil)
        let arrivalAirport = INAirport(name: nil, iataCode: "SFO", icaoCode: nil)
        let arrivalAirportGate = INAirportGate(airport: arrivalAirport, terminal: "1", gate: nil)
        
        /**
         * The reservation is for flight XX 815.
         *
         * - Note: Specify only the flight number in the flightNumber parameter, exluding the IATA or ICAO code.
         */
        let flight = INFlight(airline: INAirline(name: "Xiangyu Airline", iataCode: "XXX", icaoCode: nil),
                              flightNumber: "815",
                              boardingTime: INDateComponentsRange(start: flightBoardingDateComponents, end: flightDepartureDateComponents),
                              flightDuration: INDateComponentsRange(start: flightDepartureDateComponents, end: flightArrivalDateComponents),
                              departureAirportGate: departureAirportGate,
                              arrivalAirportGate: arrivalAirportGate)
        
        return flight
    }
}


extension INFlight {
    fileprivate static let bookingTime = Date(timeIntervalSince1970: 1_559_554_860)
    /**
     * Provide a user activity for checking in. Siri may display this as a suggested shortcut at an opportune time
     * that falls within the validDuration. When pressed, your app is expected to handle being launched with the specified
     * user activity and display the check-in flow to the user.
     *
     * - Note: If the user has already checked in for this reservation, do not attach a check in activity. If the reservation
     *         is being shown as a result of the user checking in, donate again without the check in activity.
     * - Note: The user activity title is what's being displayed to the user as the title of the suggested shortcut.
     * - Note: Make sure you specify what keys from the userInfo dictionary your app needs to be able to successfully start the
     *         check-in flow.
     */
    func makeReservationAction(pnr: String, checkInValidDuration: INDateComponentsRange) -> INReservationAction {
        let checkInActivity = NSUserActivity(activityType: "com.example.apple-samplecode.Siri-Event-Suggestions.check-in")
        checkInActivity.title = "Check in for flight \(airline.iataCode!) \(flightNumber)"
        checkInActivity.userInfo = ["bookingNumber": pnr]
        checkInActivity.requiredUserInfoKeys = ["bookingNumber"]
        checkInActivity.webpageURL = URL(string: "http://sample.example/checkin?bookingNumber=\(pnr)")
        
        
        let checkInAction = INReservationAction(type: .checkIn, validDuration: checkInValidDuration, userActivity: checkInActivity)
        
        return checkInAction
    }
    
    
    func makeReservationsForPax(_ pax: [Booking.Passenger], pnr: String, checkInValidDuration: INDateComponentsRange) ->  [INFlightReservation] {
        return pax.map { (passenger) in
            
            let reference = INSpeakableString(vocabularyIdentifier: String(passenger.hashValue),
                                              spokenPhrase: "Flight to San Francisco (\(passenger.firstName))",
                                              pronunciationHint: nil)
            
            let flightReservation = INFlightReservation(itemReference: reference,
                                                        reservationNumber: pnr,
                                                        bookingTime: INFlight.bookingTime,
                                                        reservationStatus: .confirmed,
                                                        reservationHolderName: passenger.firstName,
                                                        actions: [makeReservationAction(pnr: pnr, checkInValidDuration: checkInValidDuration)],
                                                        reservedSeat: nil,
                                                        flight: self)
            return flightReservation
        }
        
        
    }
}
