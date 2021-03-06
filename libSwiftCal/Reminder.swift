//
//  ListItem.swift
//  libSwiftCal
//
//  Created by Stefan Arambasich on 9/15/14.
//  
//  Copyright (c) 2014 Stefan Arambasich. All rights reserved.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import EventKit

/**
    Defines a VTODO calendar component.

    This object describes a to-do event that is part of a VCALENDAR
    component. "Reminder" is interchangable with "to-do" unless
    specifically noted.

    :URL: https://tools.ietf.org/html/rfc5545#section-3.6.2
*/
public class Reminder: CalendarObject {
    public enum Status: String {
        case NeedsAction = "NEEDS-ACTION"
        case Completed = "COMPLETED"
        case InProcess = "IN-PROCESS"
        case Canceled = "CANCELLED"
    }
    
    public struct AccessClass {
        public static let Public = "PUBLIC"
        public static let Private = "PRIVATE"
        public static let Confidential = "CONFIDENTIAL"
    }
    ///    In the case of an iCalendar object that specifies a
    ///    "METHOD" property, this property specifies the date and time that
    ///    the instance of the iCalendar object was created.  In the case of
    ///    an iCalendar object that doesn't specify a "METHOD" property, this
    ///    property specifies the date and time that the information
    ///    associated with the calendar component was last revised in the
    ///    calendar store.
    public var dateTimestamp: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kDTSTAMP, SerializationKeys.PropertyValKey: NSDate()])
    /// Unique identifier
    public var uid: ReminderProperty! = ReminderProperty() {
        didSet {
            if let newId = uid.stringValue {
                id = newId
            }
        }
    }
    
    /// The access classification (or visibility) of the reminder
    public var accessClass: ReminderProperty! = ReminderProperty()
    /// The datetime the reminder was completed or nil if it isn't
    public var completed: ReminderProperty! = ReminderProperty()
    /// The datetime this object was created in the calendar store
    public var createdTime: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kCREATED, SerializationKeys.PropertyValKey: NSDate()])
    /// A description of this reminder (longer than its summary)
    public var desc: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kDESCRIPTION, SerializationKeys.PropertyValKey: ""])
    /// The datetime this reminder should start
    public var start: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kDTSTART, SerializationKeys.PropertyValKey: NSDate().dateByAddingTimeInterval(Conversions.Time.SecondsInADay)])
    /// The GPS coordinate of this location
    public var geo: Geo! = Geo()
    /// The datetime this reminder was last modified
    public var lastModified: ReminderProperty! = ReminderProperty()
    /// A description of the intended venue for this reminder
    public var location: ReminderProperty! = ReminderProperty()
    /// The person who created this reminder
    public var organizer: Organizer! = Organizer()
    
    /// This property is used by an assignee or delegatee of a
    /// to-do to convey the percent completion of a to-do to the
    /// "Organizer".
    public var percentComplete: ReminderProperty! = ReminderProperty()
    /// Describes this reminder's relative priority as an integer
    public var priority: ReminderProperty! = ReminderProperty()
    /// used in conjunction with the "UID" and
    /// "SEQUENCE" properties to identify a specific instance of a
    /// recurring "VEVENT", "VTODO", or "VJOURNAL" calendar component.
    /// The property value is the original value of the "DTSTART" property
    /// of the recurrence instance.
    public var recurrenceID: ReminderProperty! = ReminderProperty()
    /// The current integer sequence of revisions of this item
    public var sequence: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kSEQUENCE, SerializationKeys.PropertyValKey: 0])
    /// Overall status or progress for this reminder
    public var status: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kSTATUS, SerializationKeys.PropertyValKey: kNEEDS_ACTION])
    
    /// A short summary or description of this reminder
    public var summary: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kSUMMARY, SerializationKeys.PropertyValKey: ""])
    /// A pointer to a URL representation of this object
    public var URL: ReminderProperty! = ReminderProperty()
    
    /// Defines a rule or repeating pattern for
    /// recurring events, to-dos, journal entries, or time zone
    /// definitions.
    public var rrule: RecurrenceRule! = RecurrenceRule()
    
    /// Defines a datetime of when this reminder is due
    public var due: ReminderProperty! = ReminderProperty(dictionary: [SerializationKeys.PropertyKeyKey: kDUE, SerializationKeys.PropertyValKey: NSDate().dateByAddingTimeInterval(Conversions.Time.SecondsInADay)])
    /// Defines a duration after the start time for which this reminder is valid
    public var duration: Duration!
    
    /// Items attached to this reminder
    public var attachments = [Attachment]()
    /// Attendees assigned to this reminder
    public var attendees = [Attendee]()
    /// A list of categories (strings) that describe this reminder
    public var categories = [ReminderProperty]()
    /// A list of comments (strings) about this reminder
    public var comments = [ReminderProperty]()
    /// A list of contacts (strings) attached to this reminder
    public var contacts = [ReminderProperty]()
    
    /// Exceptions to recurring datetimes
    public var exceptions = [ExceptionDate]()
    /// Whether the request was successful or otherwise impacted
    public var requestStatus = [RequestStatus]()
    /// Associated calendar objects
    public var related = [ReminderProperty]() // TODO: weak ref
    /// A list of resources (string) required for this reminder
    public var resources = [ReminderProperty]()
    
    /// A list of recurrence dates for this reminder object
    private var _recurrenceDates = [RecurrenceDate]()
    public var recurrenceDates: [RecurrenceDate] {
        get {
            return _recurrenceDates
        } set {
            _recurrenceDates = newValue
        }
    }
    /// Non-standard "X-" properties
    public var xProperties = [GenericProperty]()
    /// IANA-registered property names
    public var IANAProperties = [IANAProperty]()
    
    /// A list of alarm components associated with this reminder
    public var alarms = [Alarm]()
    
    // ***
    
    public override func generateUUID(format: String? = nil) {
        super.generateUUID(format: format)
        
        self.uid.key = kUID
        self.uid.stringValue = self.id
    }
    
    /// Returns the reminder status as a value of `Reminder.Status`
    public var reminderStatus: Status? {
        get {
            if let s = self.status.stringValue {
                let wsp = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                if let st = Status(rawValue: self.status.stringValue!.stringByTrimmingCharactersInSet(wsp)) {
                    return st
                }
            }
            
            return nil
        } set {
            self.status.stringValue = newValue!.rawValue
        }
    }
    
    public required init() {
        super.init()
    }
    
    
    // MARK: - CalendarType
    public override func serializeToiCal() -> String {
        var result = String()
        
        result += kBEGIN + kCOLON + kVTODO + kCRLF
        
        result += model__serializeiCalChildren(self)
        
        result += kEND + kCOLON + kVTODO + kCRLF
        
        return result
    }
    
    
    // MARK: - Hashable
    public override var hashValue: Int {
        get {
            return model__defaultHash(model: self)
        }
    }
    
    
    // MARK: - NSCoding
    public required init(coder aDecoder: NSCoder) {
        super.init()
        
        nscoder__initWithCoder(aDecoder, mirror: reflect(self), onObject: self)
    }
    
    
    // MARK: - Serializable
    public override var serializationKeys: [String] {
        get {
            return super.serializationKeys + [kDTSTAMP, kUID, kCLASS, kCOMPLETED, kCREATED, kDESCRIPTION,
                kDTSTART, kGEO, kLAST_MODIFIED, kLOCATION, kORGANIZER, kPERCENT_COMPLETE, kPRIORITY,
                kRECURRENCE_ID, kSEQUENCE, kSTATUS, kSUMMARY, kURL, kRRULE, kDUE, kDURATION, kATTACH,
                kATTENDEE, kCATEGORIES, kCOMMENT, kCONTACT, SerializationKeys.ExceptionDatesKey,
                kREQUEST_STATUS, kRELATED, kRESOURCES, SerializationKeys.RecurrenceDatesKey,
                SerializationKeys.XPropertiesKey, SerializationKeys.IANAPropertiesKey,
                SerializationKeys.AlarmsKey]
        }
    }
    
    public required init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        
        if let rDateArr = dictionary[SerializationKeys.RecurrenceDatesKey] as? [[String : AnyObject]] {
            var inRDates = [RecurrenceDate]()
            for dict in rDateArr {
                let r = RecurrenceDate(dictionary: dict)
                inRDates.append(r)
            }
            
            self.recurrenceDates = inRDates
        }
        
        if let exDateArr = dictionary[SerializationKeys.ExceptionDatesKey] as? [[String : AnyObject]] {
            var inExDates = [ExceptionDate]()
            for dict in exDateArr {
                let r = ExceptionDate(dictionary: dict)
                inExDates.append(r)
            }
            
            self.exceptions = inExDates
        }
    }
    
    public override func toDictionary() -> [String : AnyObject] {
        var result = [String: AnyObject]()

        serializable__addToDict(&result, mirror: reflect(self), onObject: self)
        
        return result
    }
}