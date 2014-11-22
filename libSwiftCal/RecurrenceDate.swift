//
//  RecurrenceDate.swift
//  MyList
//
//  Created by Stefan Arambasich on 10/15/14.
//  Copyright (c) 2014 Stefan Arambasich. All rights reserved.
//

import Foundation

public class RecurrenceDate: Property {
    var date: NSDate?
    var dateTime: NSDate?
    var timePeriod: NSTimeInterval?
    var timeZone: NSTimeZone?

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
    }
}