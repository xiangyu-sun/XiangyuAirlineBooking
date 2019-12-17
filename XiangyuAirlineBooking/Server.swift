/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A server that vends SiriKit objects.
 */

import Foundation
import Intents
import Contacts


struct Booking {
    struct Passenger {
        let firstName: String
        let lastName: String
    }
    
    struct Flight {
        let depatureDate: Date
        let departureTimeZone: TimeZone
        let boardingDate: Date
        let arrivalDate: Date
        let arrivalTimeZome: TimeZone
    }
    
    let pnr: String
    let pax: [Passenger]
    let flights: [Flight]
}

class Server {
    static let sharedInstance: Server = {
        let instance = Server()
        instance.createReservations()
        return instance
    }()
    
    fileprivate let bookingTime = Date(timeIntervalSince1970: 1_559_554_860)
    
    fileprivate var reservationContainersDictionary: [INSpeakableString: [INReservation]] = [:]
    
    func reservationContainers() -> [INSpeakableString] {
        return Array(reservationContainersDictionary.keys)
    }
    
    func reservations(inReservationContainer reservationContainer: INSpeakableString) -> [INReservation]? {
        return reservationContainersDictionary[reservationContainer]
    }
    
    func reservation(withItemReference itemReference: INSpeakableString) -> INReservation? {
        for reservationContainer in reservationContainersDictionary.keys {
            let reservations = reservationContainersDictionary[reservationContainer]
            if let reservation = reservations?.first(where: { $0.itemReference == itemReference }) {
                return reservation
            }
        }
        return nil
    }
    
    func reservationContainerReference(forReservationItemReference reservationItemReference: INSpeakableString) -> INSpeakableString? {
        let containerReference = reservationContainersDictionary.first { speakableString, reservations in
            return reservations.contains { $0.itemReference == reservationItemReference }
        }
        return containerReference?.key
    }
    
    fileprivate func createReservations() {
        let calendar = Calendar(identifier: .gregorian)
        let tomorrowDateComponents = DateComponents.dateComponentsForTomorrow(withCalendar: calendar)
        
        // Flight departs tomorrow at 10 am:
        let originTimeZone = TimeZone(identifier: "Europe/Paris")!
        var flightDepartureDateComponents = tomorrowDateComponents
        flightDepartureDateComponents.hour = 10
        flightDepartureDateComponents.minute = 0
        flightDepartureDateComponents.timeZone = originTimeZone
        
        // Flight boarding tomorrow at 8:30 am:
        var flightBoardingDateComponents = tomorrowDateComponents
        flightBoardingDateComponents.hour = 8
        flightBoardingDateComponents.minute = 30
        flightBoardingDateComponents.timeZone = originTimeZone
        
        
        // Flight arrives 9 hours and 35 minutes after departure:
        let destinationTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let flightArrivalDateComponents = calendar.components(inTimeZone: destinationTimeZone,
                                                                  byAdding: DateComponents(hour: 9, minute: 35),
                                                                  to: calendar.date(from: flightDepartureDateComponents)!)!
        
        let bookings = [Booking(pnr: "JUI9US",
                                pax: [Booking.Passenger(firstName: "John", lastName: "Appleseed"), Booking.Passenger(firstName: "Jane", lastName: "Appleseed")],
                                flights: [Booking.Flight(depatureDate: tomorrowDateComponents.date!,
                                                         departureTimeZone: originTimeZone,
                                                         boardingDate: flightBoardingDateComponents.date!,
                                                         arrivalDate: flightArrivalDateComponents.date!,
                                                         arrivalTimeZome: destinationTimeZone)])]
        
        
        createSanFranciscoTripReservation(bookings: bookings)
    }
    
    fileprivate func createSanFranciscoTripReservation(bookings: [Booking]) {
        
        // This marks the start of laying out the datetimes relative to each other. Your app should not need to do this.
        
        let calendar = Calendar(identifier: .gregorian)
        let originTimeZone = TimeZone(identifier: "Europe/Paris")!
        let destinationTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let tomorrowDateComponents = DateComponents.dateComponentsForTomorrow(withCalendar: calendar)
        
        // Flight departs tomorrow at 10 am:
        var flightDepartureDateComponents = tomorrowDateComponents
        flightDepartureDateComponents.hour = 10
        flightDepartureDateComponents.minute = 0
        flightDepartureDateComponents.timeZone = originTimeZone
        
        // Flight boarding tomorrow at 8:30 am:
        var flightBoardingDateComponents = tomorrowDateComponents
        flightBoardingDateComponents.hour = 8
        flightBoardingDateComponents.minute = 30
        flightBoardingDateComponents.timeZone = originTimeZone
        
        
        // Flight arrives 9 hours and 35 minutes after departure:
        let flightArrivalDateComponents = calendar.components(inTimeZone: destinationTimeZone,
                                                              byAdding: DateComponents(hour: 9, minute: 35),
                                                              to: calendar.date(from: flightDepartureDateComponents)!)!
        
        // Check-in for this flight opens 24 hours prior to departure and is open until 1 hour prior to departure.
        let checkStartDateComponents = calendar.components(inTimeZone: originTimeZone,
                                                           byAdding: DateComponents(hour: -24),
                                                           to: flightDepartureDateComponents)!
        let checkEndDateComponents = calendar.components(inTimeZone: originTimeZone,
                                                         byAdding: DateComponents(hour: -1),
                                                         to: flightDepartureDateComponents)!
        let checkInValidDuration = INDateComponentsRange(start: checkStartDateComponents, end: checkEndDateComponents)
        
        // The hotel reservation is for the day the flight arrives with check-in at 3pm
        var hotelCheckInDateComponents = flightArrivalDateComponents
        hotelCheckInDateComponents.hour = 15
        hotelCheckInDateComponents.minute = 0
        
        // The hotel reservation is for 2 nights and check out is at 11 am
        var hotelCheckOutDateComponents = calendar.components(inTimeZone: destinationTimeZone,
                                                              byAdding: DateComponents(day: 2),
                                                              to: hotelCheckInDateComponents)!
        hotelCheckOutDateComponents.hour = 11
        hotelCheckOutDateComponents.minute = 0
        
        // This marks the end of laying out the datetimes relative to each other and start of API usage example
        
        
        
        let flight = IntentModel.makeFlight(flightDepartureDateComponents: flightDepartureDateComponents,
                                            flightBoardingDateComponents: flightBoardingDateComponents,
                                            flightArrivalDateComponents: flightArrivalDateComponents)
        
        
        let pax = ["Johnny Appleseed", "Jane Appleseed"]
        /**
         * The two flights where booked together and share a booking number. Since there are two passengers, you should donate two reservations
         * sharing the same booking number.
         *
         * - Note: Be sure to specify an identifier that is unique within your app for every INReservation object you intend to donate.
         *         Your app may be launched with an INGetReservationDetailsIntent containing this INSpeakableString in the
         *         reservationItemReferences array.
         */
        
        let reservations = flight.makeReservationsForPax(pax, pnr: "XX009", checkInValidDuration: checkInValidDuration)
        
        
        
        /**
         * Donate all three reservations together.
         *
         * - Note: Since all three reservations will end up being donated together, the container reference should be an identifier the app
         *         can use to uniquely identify this group of three reservations. The spoken phrase should also be something that makes
         *         sense to the user as it might be used as a shortcut.
         */
        let reservationContainerReference = INSpeakableString(vocabularyIdentifier: "df9bc3f5",
                                                              spokenPhrase: "Trip to San Francisco",
                                                              pronunciationHint: nil)
        reservationContainersDictionary[reservationContainerReference] = reservations +
            [makeHotelReservation(hotelCheckInDateComponents: hotelCheckInDateComponents,hotelCheckOutDateComponents: hotelCheckOutDateComponents)]
    }
    
    private func makeHotelReservation(hotelCheckInDateComponents: DateComponents, hotelCheckOutDateComponents: DateComponents) -> INLodgingReservation {
        
        /**
         * The hotel was booked together with the flight and shares the same booking number.
         *
         * - Note: If you don't know the coordinate of a location, please use 0,0 to indicate this.
         * - Note: Be sure to specify an identifier that is unique within your app for every INReservation object you intend to donate.
         *         Your app may be launched with an INGetReservationDetailsIntent containing this INSpeakableString in the
         *         reservationItemReferences array.
         */
        let hotelReservationItemReference = INSpeakableString(vocabularyIdentifier: "c7e795f3",
                                                              spokenPhrase: "2 nights at Sample Inn",
                                                              pronunciationHint: nil)
        let hotelAddress = CNMutablePostalAddress()
        hotelAddress.street = "800 John F Kennedy Dr"
        hotelAddress.city = "San Francisco"
        hotelAddress.state = "CA"
        hotelAddress.postalCode = "94121"
        hotelAddress.country = "USA"
        let hotel = CLPlacemark(location: CLLocation(latitude: 0, longitude: 0), name: "Sample Inn", postalAddress: hotelAddress)
        return INLodgingReservation(itemReference: hotelReservationItemReference,
                                    reservationNumber: "SAMPLE-001",
                                    bookingTime: bookingTime,
                                    reservationStatus: .confirmed,
                                    reservationHolderName: "Jane Appleseed",
                                    actions: nil,
                                    lodgingBusinessLocation: hotel,
                                    reservationDuration: INDateComponentsRange(start: hotelCheckInDateComponents,
                                                                               end: hotelCheckOutDateComponents),
                                    numberOfAdults: 1,
                                    numberOfChildren: 0)
    }
}
