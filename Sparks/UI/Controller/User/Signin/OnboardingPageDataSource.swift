//
//  OnboardingPageDataSource.swift
//  Sparks
//
//  Created by Irakli Vashakidze on 14.07.21.
//  Copyright © 2021 AppWork. All rights reserved.
//

import UIKit

struct OnboardingPageDataItem {
    private(set) var title: String
    private(set) var desc: String
}

struct OnboardingPageDataSource {
    static let items = [
        OnboardingPageDataItem(title: "Find Travelmates",
                               desc: "Explore travellers in your desired region or anywhere in the world. Connect, chat, share photos and more ..."),
        OnboardingPageDataItem(title: "Ready for new trip adventure ?",
                               desc:"Sparks allows you to connect with new people while travelling."),
        OnboardingPageDataItem(title: "Share your upcoming trip with others",
                               desc: "Let the people know about your next trip. You will get notified when someone wants to connect. ")
    ]
}
