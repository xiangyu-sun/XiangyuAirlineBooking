//
//  ActivityHandler.swift
//  XiangyuAirlineBooking
//
//  Created by 孙翔宇 on 28/11/2019.
//  Copyright © 2019 孙翔宇. All rights reserved.
//

import Foundation
import Intents

final class ActivityHandler: ObservableObject {
    let showReservationPub = NotificationCenter.default.publisher(for: .showReservation)
    let startReservationCheckInPub = NotificationCenter.default.publisher(for: .startReservationCheckIn)
    
    @Published var reservationItemReferences: [INSpeakableString]?
    @Published var reservationContainerReference: INSpeakableString?
    @Published var singleReservation: Bool = false
    @Published var containerReservations: Bool = false
    @Published var reservation: INReservation?
    @Published var reservations:[INReservation]?
    @Published var showCheckAlert = false
    @Published var bookingNumber: String?
    
    init() {
        showReservationPub.sink { (notification) in
            guard let userActivity = notification.object as? NSUserActivity else {
                return
            }
            self.handleShowReservationNotification(withUserActivity: userActivity)
        }
        
        startReservationCheckInPub.sink { (notification) in
            guard let userActivity = notification.object as? NSUserActivity else {
                return
            }
            if let userInfo = userActivity.userInfo {
                if let bookingNumber = userInfo["bookingNumber"] as? String{
                    //self.navigationController?.popToRootViewController(animated: false)
                    self.bookingNumber = bookingNumber
                    self.showCheckAlert = true
                }
            }
        }
    }
    
    fileprivate func handleShowReservationNotification(withUserActivity userActivity: NSUserActivity) {
        guard let intent = userActivity.interaction?.intent as? INGetReservationDetailsIntent else {
            return
        }
        
        guard let reservationItemReferences = intent.reservationItemReferences else {
            return
        }
        
        self.reservationItemReferences = reservationItemReferences
        singleReservation = false
        containerReservations = false
        
        if reservationItemReferences.count == 1, let reservationItemReference = reservationItemReferences.first {
            guard let reservation = Server.sharedInstance.reservation(withItemReference: reservationItemReference) else {
                singleReservation = false
                return
            }
            self.reservation = reservation
        }
            
            // The app was launched with multiple items in the reservationItemReferences array indicating we should show a group
            // of reservations. Use the reservationContainerReference property to figure out what group to show.
        else if let reservationContainerReference = intent.reservationContainerReference {
            guard let reservations = Server.sharedInstance.reservations(inReservationContainer: reservationContainerReference) else {
                return
            }
            self.reservations = reservations
            containerReservations = true
        }
    }
}
