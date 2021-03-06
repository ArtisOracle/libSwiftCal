//
//  Calendar.swift
//  libSwiftCal
//
//  Created by Stefan Arambasich on 10/20/14.
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

public var DefaultCalendar: Calendar {
    get {
        let kDefault = NSLocalizedString("Default", comment: "")
        let cal = Calendar(dictionary: [kUID: kDefault, kX_WR_CALNAME: kDefault])
        return cal
    }
}

/**
    Defines a VCALENDAR calendar component.

    This object describes a calendar object, a collection of calendaring
    and scheduling information.

    This class features an iCalendar parser which takes an input string
    and receives callbacks when an item in the iCalendar file is matched.
    Use this to parse and create new instances of calendar objects.

    :URL: https://tools.ietf.org/html/rfc5545#section-3.4
*/
public class Calendar: CalendarObject, ParserObserver {
    /// Non-standard unique identifier for the calendar (alias for `CalendarObject.id`)
    public var calendarIdentifier: String {
        get {
            return self.id
        } set {
            self.id = newValue
        }
    }
    
    /// Only supports the "GREGORIAN" calendar
    public internal(set) var calscale = CalendarProperty(dictionary: [SerializationKeys.PropertyKeyKey: kCALSCALE, SerializationKeys.PropertyValKey: Constants.CalScaleGregorian])
    /// Defines the iCalendar object method associated with the calendar object
    public internal(set) var method: CalendarProperty = CalendarProperty()
    /// Specifies the identifier for the product that created the iCalendar object.
    public internal(set) var prodID = CalendarProperty(dictionary: [SerializationKeys.PropertyKeyKey: kPRODID, SerializationKeys.PropertyValKey: Constants.libSwiftCalProdID])
    /// The calendar's required version
    public internal(set) var version = CalendarProperty(dictionary: [SerializationKeys.PropertyKeyKey: kVERSION, SerializationKeys.PropertyValKey: Constants.iCalendarVersion])
    /// Non-standard calendar name (`X-WR-CALNAME`)
    public internal(set) var calName = GenericProperty(dictionary: [SerializationKeys.PropertyKeyKey: kX_WR_CALNAME, SerializationKeys.PropertyValKey: ""])
    /// Non-standard calendar description (`X_WR_CALDESC`)
    public internal(set) var calDesc = GenericProperty(dictionary: [SerializationKeys.PropertyKeyKey: kX_WR_CALDESC, SerializationKeys.PropertyValKey: ""])
    
    /// List of VTODO components belonging to this calendar
    public var reminders = [Reminder]()
    
    /// UID (alias for `calendarIdentifier`
    public var uid: String {
        get {
            return self.calendarIdentifier
        } set {
            self.calendarIdentifier = newValue
        }
    }
    
    /**
        Returns a new representation of a VCALENDAR object and beings parsing the inputted
        string value.
    
        If the number of items in the calendar becomes large, this method will take a 
        while to run, so perhaps a best practice is to run this on a background thread 
        and call back to main when the parsing finishes (this method returns).
    
        Upon failure, returns nil as well as an `NSError` pointer to the caller describing the
        issue. Most likely, there is something wrong in your calendar file such that it
        doesn't quite fit the parsing grammar.
    
        :param: s The string to parse from iCalendar into libSwiftCal.
    */
    public init?(stringToParse s: String, inout error: NSError?) {
        super.init()
        self.parser = CalParser(delegate: self)
        let str = s.unfoldiCalendarString()
        self.parser.parseString(str, error: &error)
        if error != nil {
            return nil
        }
    }
    
    public required init() {
        super.init()
    }
    
    
    // MARK: - CalendarType
    public override func serializeToiCal() -> String {
        var result = String()
        
        result += kBEGIN + kCOLON + kVCALENDAR + kCRLF
        
        result += model__serializeiCalChildren(self)
        
        result += kEND + kCOLON + kVCALENDAR + kCRLF
        
        return result
    }

    
    // MARK: - NSCoding
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // MARK: - Serializable
    public required init(dictionary: [String : AnyObject]) {
        super.init(dictionary: dictionary)
        
        if let uid = dictionary[kUID] as? String {
            self.uid = uid
        }
    }
    
    public override var serializationKeys: [String] {
        get {
            return super.serializationKeys + [kCALSCALE, kMETHOD, kPRODID, kVERSION, kX_WR_CALNAME, kX_WR_CALDESC, SerializationKeys.RemindersKey]
        }
    }
    
    // Parsing
    private var parser: CalParser! = CalParser()
    private var currentTodoDict: [String : AnyObject]?
    private var currentAlarmDict: [String : AnyObject]?
    private var currentTodoXProps: [[String : AnyObject]]?
    private var currentAlarmXProps: [[String : AnyObject]]?
    private var currentAlarms: [[String : AnyObject]]?
    private var currentRdates: [[String : AnyObject]]?
    private var currentExdates: [[String : AnyObject]]?
}

extension Calendar {
    private func emptyParserFields() {
        currentTodoDict?.removeAll()
        currentTodoDict = nil
        currentTodoXProps?.removeAll()
        currentTodoXProps = nil
        currentAlarmDict?.removeAll()
        currentAlarmDict = nil
        currentAlarmXProps?.removeAll()
        currentAlarmXProps = nil
        currentAlarms?.removeAll()
        currentAlarms = nil
        currentRdates?.removeAll()
        currentRdates = nil
        currentExdates?.removeAll()
        currentExdates = nil
    }
    
    // MARK: - ParserObserver
    public func parser(key: String!, didMatchCalprops value: PropertyMatch!) {
        model__setValue(value.toDictionary(), forSerializationKey: key, model: self)
    }
    
    public func parser(key: String!, willMatchTodoc value: String!) {
        currentTodoDict = [String : AnyObject]()
    }
    
    public func parser(key: String!, didMatchTodoprop value: PropertyMatch!) {
        if key == kRRULE || key == kRDATE || key == kEXDATE || key == kGEO {
            return
        }
        
        let k = key as NSString
        if k.isXValue() {
            if currentTodoXProps == nil {
                currentTodoXProps = [[String : AnyObject]]()
            }
            
            currentTodoXProps!.append(value.toDictionary() as! [String : AnyObject])
        } else {
            currentTodoDict![key] = value.toDictionary()
        }
    }
    
    public func parser(key: String!, didMatchRrule value: PropertyMatch!) {
        var dict = value.toDictionary()
        var strVal = value.value as! String
        let rules = strVal.componentsSeparatedByString(kSEMICOLON)
        for r in rules {
            let split = r.componentsSeparatedByString(kEQUALS)
            let k = split.first! as String
            let val = split.last! as String
            var vals: [AnyObject] = val.componentsSeparatedByString(kCOMMA)
            if vals.count > 1 {
                for i in 0 ..< vals.count {
                    let v: AnyObject = toTypeFromString(vals[i] as! String)
                    vals[i] = v
                }
                
                dict[k] = vals
            } else {
                if k != kFREQ && k != kUNTIL && k != kCOUNT && k != kINTERVAL && k != kWKST {
                    dict[k] = [toTypeFromString(val)]
                } else {
                    dict[k] = toTypeFromString(val)
                }
            }
        }
        
        currentTodoDict![key] = dict
    }
    
    public func parser(key: String!, didMatchGeo value: PropertyMatch!) {
        let g = Geo()
        let comps = (value.value as! String).componentsSeparatedByString(";")
        if comps.count == 2 {
            let lat = (comps[0] as NSString).doubleValue
            let lon = (comps[1] as NSString).doubleValue
            
            if lat != 0.0 && lon != 0.0 {
                currentTodoDict![kGEO] = [SerializationKeys.PropertyKeyKey: kGEO, SerializationKeys.PropertyValKey: value.value as! String]
            }
        }
    }
    
    public func parser(key: String!, willMatchRdate value: String!) {
        if currentRdates == nil { currentRdates = [[String : AnyObject]]() }
    }
    
    public func parser(key: String!, didMatchRdate value: PropertyMatch!) {
        var dates = [NSDate]()
        var dateTimes = [NSDate]()
        var timePers = [[String : AnyObject]]()
        
        var finalRdateDict = value.toDictionary() as! [String : AnyObject]
        if let strVal = value.value as? String {
            // RDATE;VALUE=PERIOD:19960403T020000Z/19960403T040000Z,19960404T010000Z/PT3H
            // RDATE:19970714T123000Z
            // RDATE;VALUE=DATE:19970101,19970120,19970217
            
            let rDateComponents = strVal.componentsSeparatedByString(kCOMMA)
            for rDateComp in rDateComponents {
                if !rDateComp.contains("/") {
                    if let dt = NSDate.parseDate(rDateComp) {
                        dateTimes.append(dt)
                    } else if let d = NSDate.parseDate(rDateComp, format: DateFormats.ISO8601Date) {
                        dates.append(d)
                    }
                } else {
                    var timePeriodDict = [String : AnyObject]()
                    
                    let split = rDateComp.componentsSeparatedByString("/")
                    
                    if let sd = NSDate.parseDate(split.first!) {
                        timePeriodDict[TimePeriod.SerializationKeys.Start] = sd
                    }
                    
                    if let ed = NSDate.parseDate(split.last!) {
                        timePeriodDict[TimePeriod.SerializationKeys.End] = ed
                    } else {
                        let dur = Duration(string: split.last!)
                        let dic = dur.toDictionary()
                        timePeriodDict[TimePeriod.SerializationKeys.Duration] = dur.toDictionary()
                    }
                    
                    timePers.append(timePeriodDict)
                }
            }
        } else if let d = value.value as? NSDate {
            let s = d.valueForCalendarComponentUnit(NSCalendarUnit.CalendarUnitSecond)
            let m = d.valueForCalendarComponentUnit(NSCalendarUnit.CalendarUnitMinute)
            let h = d.valueForCalendarComponentUnit(NSCalendarUnit.CalendarUnitHour)
            
            if s == 0 && m == 0 && h == 0 { // I.e. we have no time info
                dates.append(d)
            } else {
                dateTimes.append(d)
            }
        }
        
        if dates.count > 0 {
            finalRdateDict[kDATE] = dates
        } else if dateTimes.count > 0 {
            finalRdateDict[kDATE_TIME] = dateTimes
        } else if timePers.count > 0 {
            finalRdateDict[kPERIOD] = timePers
        }
        
        if currentTodoDict![kRDATE] == nil {
            currentTodoDict![kRDATE] = [[String : AnyObject]]()
        }
        
        currentRdates!.append(finalRdateDict)
    }
    
    public func parser(key: String!, willMatchExdate value: String!) {
        if currentExdates == nil { currentExdates = [[String : AnyObject]]() }
    }
    
    public func parser(key: String!, didMatchExdate value: PropertyMatch!) {
        var exdate = [String : AnyObject]()
        var dateTimes = [NSDate]()
        var dates = [NSDate]()
        
        if let exDateValueStr = value.value as? String {
            let dateStrs = exDateValueStr.componentsSeparatedByString(",")
            
            for dateStr in dateStrs {
                if let dt = NSDate.parseDate(dateStr) {
                    var newExdate = value.toDictionary() as! [String : AnyObject]
                    dateTimes.append(dt)
                } else if let d = NSDate.parseDate(dateStr, format: DateFormats.ISO8601Date) {
                    var newExdate = value.toDictionary() as! [String : AnyObject]
                    dates.append(d)
                }
            }
        } else if let d = value.value as? NSDate {
            if !d.hasTimeComponent() {
                dates.append(d)
            } else {
                dateTimes.append(d)
            }
        }
        
        if dates.count > 0 {
            exdate[kDATE] = dates
        } else if dateTimes.count > 0 {
            exdate[kDATE_TIME] = dateTimes
        }
        
        if currentTodoDict![kEXDATE] == nil {
            currentTodoDict![kEXDATE] = [[String : AnyObject]]()
        }
        
        currentExdates!.append(exdate)
    }
    
    public func parser(key: String!, willMatchAlarmc value: String!) {
        if currentAlarms == nil {
            currentAlarms = [[String : AnyObject]]()
        }
        
        currentAlarmDict = [String : AnyObject]()
    }
    
    public func parser(key: String!, didMatchAlarmprop value: PropertyMatch!) {
        let k = key as NSString
        if k.isXValue() {
            if currentAlarmXProps == nil {
                currentAlarmXProps = [[String : AnyObject]]()
            }
            
            currentAlarmXProps!.append(value.toDictionary() as! [String : AnyObject])
        } else {
            currentAlarmDict![key] = value.toDictionary()
        }
    }
    
    public func parser(key: String!, didMatchAlarmc value: String!) {
        currentAlarmDict![SerializationKeys.XPropertiesKey] = currentAlarmXProps
        currentAlarms!.append(currentAlarmDict!)
        currentAlarmDict = nil
    }
    
    public func parser(key: String!, didMatchTodoc value: String!) {
        currentTodoDict![SerializationKeys.AlarmsKey] = currentAlarms
        currentTodoDict![SerializationKeys.RecurrenceDatesKey] = currentRdates
        currentTodoDict![SerializationKeys.ExceptionDatesKey] = currentExdates
        currentTodoDict![SerializationKeys.XPropertiesKey] = currentTodoXProps
        let newTodoc = Reminder(dictionary: self.currentTodoDict!)
        self.reminders.append(newTodoc)
        emptyParserFields()
    }
}