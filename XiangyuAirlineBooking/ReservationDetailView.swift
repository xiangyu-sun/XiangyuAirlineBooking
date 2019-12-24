//
//  ReservationDetailView.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 27/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import SwiftUI
import Intents

struct ReservationDetailView: View {
    
    var reservationContainerReference: INSpeakableString?
    var reservation: INReservation?
    
    var body: some View {
        Text("Reservation Detail").onAppear{
            self.donateReservation()
        }
    }
    func donateReservation() {
          guard let reservation = reservation, let reservationContainerReference = reservationContainerReference else {
              return
          }
        
        
        /* reservationItemReferences empty or with "\(booking.pnr)-\(flightNumber)-\(passenger.fullName)"
         for example when there is only flight flight for checkin
         */
          let intent = INGetReservationDetailsIntent(reservationContainerReference: reservationContainerReference,
                                                     reservationItemReferences: nil)
        
          let intentResponse = INGetReservationDetailsIntentResponse(code: .success, userActivity: nil)
        
          intentResponse.reservations = [reservation]
          let interaction = INInteraction(intent: intent, response: intentResponse)
          interaction.donate { error in
              if let error = error {
                  print(error)
              }
          }
      }
    
}

struct ReservationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationDetailView()
    }
}
