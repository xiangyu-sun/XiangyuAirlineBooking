/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A server that vends SiriKit objects.
 */

import Foundation
import Intents
import Contacts

let calendar = Calendar(identifier: .gregorian)

struct Booking {
    struct Flight {
        
        struct Passenger: Hashable {
            let firstName: String
            let lastName: String
            
            var fullName : String {
                return firstName + lastName
            }
        }
        
        let depatureDate: DateComponents
        let departureTimeZone: TimeZone
        let boardingDate: DateComponents
        let arrivalDate: DateComponents
        let arrivalTimeZome: TimeZone
        let pax: [Passenger]
        
        var checkinValidDuration: INDateComponentsRange {
            let checkStartDateComponents = calendar.components(inTimeZone: departureTimeZone,
                                                               byAdding: DateComponents(hour: -24),
                                                               to: depatureDate)!
            let checkEndDateComponents = calendar.components(inTimeZone: departureTimeZone,
                                                             byAdding: DateComponents(hour: -1),
                                                             to: depatureDate)!
            return INDateComponentsRange(start: checkStartDateComponents, end: checkEndDateComponents)
            
        }
    }
    let tripDescription: String
    let pnr: String
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
        
        
        // second flight
        let originTimeZone2ndFlight = TimeZone(identifier: "America/Los_Angeles")!
        
        let twoDayAfterTomorrowDateComponents = calendar.components(inTimeZone: originTimeZone2ndFlight,
                                                                    byAdding: DateComponents(day: 2),
                                                                    to: calendar.date(from: tomorrowDateComponents)!)!
        
        // Flight departs tomorrow at 10 am:
        var flightDepartureDateComponents2ndFlight = twoDayAfterTomorrowDateComponents
        flightDepartureDateComponents2ndFlight.hour = 14
        flightDepartureDateComponents2ndFlight.minute = 0
        flightDepartureDateComponents2ndFlight.timeZone = originTimeZone2ndFlight
        
        // Flight boarding tomorrow at 8:30 am:
        var flightBoardingDateComponents2ndFlight = twoDayAfterTomorrowDateComponents
        flightBoardingDateComponents2ndFlight.hour = 12
        flightBoardingDateComponents2ndFlight.minute = 30
        flightBoardingDateComponents2ndFlight.timeZone = originTimeZone2ndFlight
        
        
        // Flight arrives 9 hours and 35 minutes after departure:
        let destinationTimeZone2ndFlight = TimeZone(identifier: "Asian/Abu_Dhabi")!
        let flightArrivalDateComponents2ndFlight = calendar.components(inTimeZone: destinationTimeZone2ndFlight,
                                                                  byAdding: DateComponents(hour: 9, minute: 35),
                                                                  to: calendar.date(from: flightDepartureDateComponents)!)!
        
        
        
        
        let bookings = [Booking(tripDescription: "Trip to San Francisco",
                                pnr: "JUI9US",
                                flights: [Booking.Flight(depatureDate: tomorrowDateComponents,
                                                         departureTimeZone: originTimeZone,
                                                         boardingDate: flightBoardingDateComponents,
                                                         arrivalDate: flightArrivalDateComponents,
                                                         arrivalTimeZome: destinationTimeZone,
                                                         pax: [Booking.Flight.Passenger(firstName: "John", lastName: "Appleseed"),
                                                               Booking.Flight.Passenger(firstName: "Jane", lastName: "Appleseed")])]),
                        Booking(tripDescription: "Trip to Dubai",
                        pnr: "X8UY78",
                        flights: [Booking.Flight(depatureDate: flightDepartureDateComponents2ndFlight,
                                                 departureTimeZone: originTimeZone2ndFlight,
                                                 boardingDate: flightBoardingDateComponents2ndFlight,
                                                 arrivalDate: flightArrivalDateComponents2ndFlight,
                                                 arrivalTimeZome: destinationTimeZone2ndFlight,
                                                 pax: [Booking.Flight.Passenger(firstName: "Jane", lastName: "Appleseed")])]),
        ]
        
        
        refreshTrips(bookings: bookings)
    }
    
    
    /**
          * The two flights where booked together and share a booking number. Since there are two passengers, you should donate two reservations
          * sharing the same booking number.
          *
          * - Note: Be sure to specify an identifier that is unique within your app for every INReservation object you intend to donate.
          *         Your app may be launched with an INGetReservationDetailsIntent containing this INSpeakableString in the
          *         reservationItemReferences array.
          */
         
    fileprivate func refreshTrips(bookings: [Booking]) {
        bookings.forEach(addTrip(_:))
    }
    
    fileprivate func addTrip(_ booking: Booking) {
        let reservations: [INReservation] = booking.flights.reduce(into: []) { (result, flight) in
            var aResult = result
            let inFlight = IntentModel.makeFlight(flightDepartureDateComponents: flight.depatureDate,
                                                  flightBoardingDateComponents: flight.boardingDate,
                                                  flightArrivalDateComponents: flight.arrivalDate)
            
            return aResult.append(contentsOf: inFlight.makeReservationsForPax(booking, checkInValidDuration: flight.checkinValidDuration))
        }
        
        
        /// PNR as container reference
        let reservationContainerReference = INSpeakableString(vocabularyIdentifier: booking.pnr,
                                                              spokenPhrase: booking.tripDescription,
                                                              pronunciationHint: nil)
        
        reservationContainersDictionary[reservationContainerReference] = reservations
    }
    
    func deleteTrip(_ booking: Booking) {
        
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
