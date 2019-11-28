//
//  ReservationsListView.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 27/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import SwiftUI
import Intents

struct ReservationsListView: View {
    var reservationContainerReference: INSpeakableString?
    @State var reservations: [INReservation] = []
    
    var body: some View {
        
        List(reservations, id: \.self) { reservation in
            NavigationLink(destination: ReservationDetailView(reservationContainerReference: self.reservationContainerReference, reservation: reservation as INReservation?)){
                Text(reservation.itemReference.spokenPhrase)
            }
        }.navigationBarTitle(Text(reservationContainerReference?.spokenPhrase ?? "" ))
        .onAppear {
            if let reservationContainerReference = self.reservationContainerReference {
                if let reservations = Server.sharedInstance.reservations(inReservationContainer: reservationContainerReference) {
                    self.reservations = reservations
                    
                    // Donate the reservations when the user sees them
                    self.donateReservations()
                }
            }
        }
        
    }
    
    
    // MARK: - Helpers
    
    func donateReservations() {
        guard let reservationContainerReference = reservationContainerReference, !reservations.isEmpty else {
            return
        }
        
        let intent = INGetReservationDetailsIntent(reservationContainerReference: reservationContainerReference,
                                                   reservationItemReferences: nil)
        
        let intentResponse = INGetReservationDetailsIntentResponse(code: .success, userActivity: nil)
        intentResponse.reservations = reservations
        
        let interaction = INInteraction(intent: intent, response: intentResponse)
        interaction.donate { error in
            if let error = error {
                print(error)
            }
        }
    }
}

struct ReservationsListView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationsListView()
    }
}
