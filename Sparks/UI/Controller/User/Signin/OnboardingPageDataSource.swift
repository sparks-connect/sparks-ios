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
    private(set) var image: UIImage
}

struct OnboardingPageDataSource {
    static let items = [
        OnboardingPageDataItem(title: "Select the audience", desc: "Specify the filter criteria to deliver your message", image: #imageLiteral(resourceName: "page1")),
        OnboardingPageDataItem(title: "Write a letter", desc: "Create a meaningful message", image: #imageLiteral(resourceName: "page2")),
        OnboardingPageDataItem(title: "Send it", desc: "Deliver your message to someone", image: #imageLiteral(resourceName: "page3"))
    ]
}
