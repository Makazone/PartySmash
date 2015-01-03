//
//  User.swift
//  PartySmash
//
//  Created by Makar Stetsenko on 03.01.15.
//  Copyright (c) 2015 PartySmash. All rights reserved.
//

import Foundation

class User: PFUser, PFSubclassing {
    override class func load() {
        self.registerSubclass()
    }
}