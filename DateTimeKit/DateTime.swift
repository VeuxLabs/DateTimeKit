//
//  DateTime.swift
//  DateTimeKit
//
//  Created by Craig Edwards
//  Copyright (c) 2015 Craig Edwards. All rights reserved.
//

import Foundation

// MARK: - DateTime
/**
 A `DateTime` represents a date and time within a specific timezone. For example, 5th July 2012 at
 10:12:16.123 in Sydney, Australia.
 
 It contains enough information to resolve to a specific `Instant` in the datetime continuum, but is more
 commonly used to represent a date/time that a user perceives on their wall-clock in a specific timezone.
 */

public enum DayOfWeek : Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
}


public struct DateTime {
    fileprivate static let UNITS: NSCalendar.Unit =
        [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond]
    
    /** The wall-clock date/time component */
    public let dateTime: LocalDateTime
    /** The timezone that the dateTime field is representing */
    public let zone: Zone
    private let secondsInADay = 86400

    public var year:        Int { get { return dateTime.date.year } }
    public var month:       Int { get { return dateTime.date.month } }
    public var day:         Int { get { return dateTime.date.day } }
    public var hour:        Int { get { return dateTime.time.hour } }
    public var minute:      Int { get { return dateTime.time.minute } }
    public var second:      Int { get { return dateTime.time.second } }
    public var millisecond: Int { get { return dateTime.time.millisecond } }
    
    /**
     Constructs a `DateTime` using the constituent components. Will fail if any of the input components are out of
     bounds (eg. more than 59 seconds)
     
     - parameter year: The year
     - parameter month: The month (must be between 1 and 12 inclusive)
     - parameter day: The day (must be between 1 and the number of days in the passed month)
     - parameter hour: The hour (must be between 0 and 23 inclusive)
     - parameter minute: The minute (must be between 0 and 59 inclusive)
     - parameter second: The second (must be between 0 and 59 inclusive)
     - parameter millisecond: The hour (must be between 0 and 999 inclusive)
     - parameter zone: The zone that this date/time is in
     - parameter error: An error that will be populated if the initialiser fails
     */
    public init?(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int, _ millisecond: Int = 0, _ zone: Zone, _ error: DateTimeErrorPointer? = nil) {
        if let dateTime = LocalDateTime(year, month, day, hour, minute, second, millisecond, error) {
            self.init(dateTime, zone)
        }
        else {
            return nil
        }
    }
    
    /**
     Constructs a `DateTime` from an input string and a date format (ie. something that NSDateFormatter can parse).
     Optionally, a time zone and locale can be passed and will be used to assist parsing.
     
     - parameter input: The input date string
     - parameter format: The NSDateFormatter-compliant date format string
     - parameter zone: The zone that will be used when parsing (note that if the input date and format contains timezone info, this parameter will be ignored)
     - parameter locale: The locale that will be used when parsing
     - parameter error: An error that will be populated if the initialiser fails
     */
    public init?(input: String, format: String, zone: Zone = Zone.systemDefault(), _ locale: Locale = Locale.autoupdatingCurrent, _ error: DateTimeErrorPointer? = nil) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = zone.timezone as TimeZone!
        dateFormatter.locale = locale
        
        var localError: NSError?
        var date: AnyObject?
        do {
            try dateFormatter.getObjectValue(&date, for: input, range: nil)
            self.init(Instant(date as! Date), zone)
        } catch let error1 as NSError {
            localError = error1
            if error != nil {
                error?.pointee = DateTimeError.unableToParseDate(localError!.localizedDescription)
            }
            return nil
        }
    }
    
    /**
     Constructs a `DateTime` representing the current moment in time in the user's current system clock
     */
    public init() {
        self.init(SystemClock())
    }
    
    /**
     Constructs a `DateTime` representing the current moment in time using the passed clock
     
     - parameter clock: The clock that will be used to provide the current instant
     */
    public init(_ clock: Clock) {
        self.init(LocalDateTime(clock), clock.zone())
    }
    
    /**
     Constructs a `DateTime` from a given instant within a specifed zone.
     
     - parameter instant: The instant in the datetime continuum
     - parameter zone: The zone that is used to determine the wall-clock date and time
     */
    public init(_ instant: Instant, _ zone: Zone) {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = zone.timezone as TimeZone
        let components = (calendar as NSCalendar).components(DateTime.UNITS, from: instant.asNSDate() as Date)
        self.init(LocalDateTime(components.year!, components.month!, components.day!, components.hour!, components.minute!, components.second!, components.nanosecond!/1_000_000)!, zone)
    }
    
    /**
     Constructs a `DateTime` from a local date/time within a specific zone
     
     - parameter dateTime: The local date/time
     - parameter zone: The zone that the local date/time is representing
     */
    public init(_ dateTime: LocalDateTime, _ zone: Zone) {
        self.dateTime = dateTime
        self.zone = zone
    }
    
    /**
     Returns an instant representing the specific moment in time for this object
     */
    public func instant() -> Instant {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = DateComponents()
        components.year = self.dateTime.date.year
        components.month = self.dateTime.date.month
        components.day = self.dateTime.date.day
        components.hour = self.dateTime.time.hour
        components.minute = self.dateTime.time.minute
        components.second = self.dateTime.time.second
        components.nanosecond = self.dateTime.time.millisecond * 1_000_000
        (components as NSDateComponents).timeZone = self.zone.timezone as TimeZone
        
        // note that we can explicitly unwrap because we know the component inputs were
        // valid inside the dateTime object
        return Instant(calendar.date(from: components)!)
    }
    
    /**
     Returns a DateTime with the first millisecond of that day
     */
    public func getFirstMillisecondOfDay() -> DateTime {
        let newDateTime = DateTime(self.year , self.month, self.day, 0, 0, 0, 0, self.zone)
        return newDateTime!
    }
    
    /**
     Returns a DateTime with the last millisecond of that day
     */
    public func getLastMillisecondOfDay() -> DateTime {
        let newDateTime = DateTime(self.year , self.month, self.day, 23, 59, 59, 999, self.zone)
        return newDateTime!
    }
    
    
    /**
     Returns a DateTime with the first millisecond of that month
     */
    public func getFirstMillisecondOfMonth() -> DateTime {
        let newDateTime = DateTime(self.year , self.month, 1, 0, 0, 0, 0, self.zone)
        return newDateTime!
    }
    
    /**
     Returns a DateTime with the last millisecond of that month
     */
    public func getLastMillisecondOfMonth() -> DateTime {
        var newDateTime = DateTime(self.year , self.month + 1, 1, 0, 0, 0, 0, self.zone)
        if self.month == 12 {
            newDateTime = DateTime(self.year + 1 , self.month, 1, 0, 0, 0, 0, self.zone)
        }
        newDateTime = newDateTime!.minus(Duration(1))
        return newDateTime!
    }
    
    /**
     Returns a DayOfWeek representing the specific day for example Sunday == 1, please see the enum in the footer part
     */
    
    public func getDayOfTheWeek() -> DayOfWeek{
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (calendar as NSCalendar).components(.weekday, from: self.instant().asNSDate() as Date)
        return DayOfWeek(rawValue: components.weekday!)!
    }
    
    
    /**
     Returns a DateTime with the first date of the week
     */
    
    public func getFirstDayOfTheWeek() -> DateTime {
        if getDayOfTheWeek() == .sunday  {
            return DateTime(self.year , self.month, self.day, 0, 0, 0, 0, self.zone)!
        }
        var newDateTime = DateTime(self.year , self.month, self.day, 0, 0, 0, 0, self.zone)!
        while newDateTime.getDayOfTheWeek() != .sunday {
            newDateTime = newDateTime.minus(Period(0,0,1))
        }
        return newDateTime;
    }
    
    /**
     Returns a DateTime with the first date of the week in Miliseconds
     */
    public func getFirstDayOfTheWeekInMiliseconds() -> NSNumber{
        return  NSNumber(value: Int64(getFirstDayOfTheWeek().instant().millisecondsSinceReferenceDate) as Int64)
    }
    
    /**
     Returns a DateTime with the Last date of the week
     */
    public func getLastDayOfTheWeek() -> DateTime{
        if getDayOfTheWeek() == .saturday {
            return DateTime(self.year , self.month, self.day, 23, 59, 59, 59, self.zone)!
        }
        var newDateTime = DateTime(self.year , self.month, self.day, 23, 59, 59, 59, self.zone)!
        while newDateTime.getDayOfTheWeek() != .saturday {
            newDateTime = newDateTime.plus(Duration(secondsInADay))
        }
        return newDateTime;
    }
    
    /**
     Returns a DateTime with the last date of the week in Miliseconds
     */
    public func getLastDayOfTheWeekInMiliseconds() -> NSNumber{
        return  NSNumber(value: Int64(getLastDayOfTheWeek().instant().millisecondsSinceReferenceDate) as Int64)
    }
    
    /**
     Converts this zoned date/time to another date/time in a different zone.
     
     - parameter zone: The zone to convert the current date/time to
     - returns: A new `DateTime` object that represent this object's date/time in the new zone
     */
    public func inZone(_ zone: Zone) -> DateTime {
        let instant = self.instant()
        return DateTime(instant, zone)
    }
    
    /**
     Adds a duration to this date/time and returns a new object representing the new date/time.
     
     If a negative duration is passed, the new date/time will be before the current one.
     
     Also available by the `+` operator.
     
     - parameter duration: The duration to be added
     - returns: A new `DateTime` that represents the new moment in the datetime continuum
     */
    public func plus(_ duration: Duration) -> DateTime {
        return DateTime(instant() + duration, self.zone)
    }
    
    /**
     Subtracts a duration from this date/time and returns a new object representing the new date/time.
     
     If a negative duration is passed, the new date/time will be after the current one.
     
     Also available by the `-` operator.
     
     - parameter duration: The duration to be subtracted
     - returns: A new `DateTime` that represents the new moment in the datetime continuum
     */
    public func minus(_ duration: Duration) -> DateTime {
        return DateTime(instant() - duration, self.zone)
    }
    
    /**
     Adds a period to this dateTime and returns a new object representing the new dateTime.
     
     Also available by the `+` operator.
     
     - parameter period: The period to be added
     - returns: A new `DateTime` that represents the new dateTime
     */
    public func plus(_ period: Period) -> DateTime {
        return DateTime(LocalDateTime(self.dateTime.date + period, self.dateTime.time), self.zone)
    }
    
    /**
     Subtracts a period from this dateTime and returns a new object representing the new dateTime.
     
     Also available by the `-` operator.
     
     - parameter period: The period to be subtracted
     - returns: A new `DateTime` that represents the new dateTime
     */
    public func minus(_ period: Period) -> DateTime {
        return DateTime(LocalDateTime(self.dateTime.date - period, self.dateTime.time), self.zone)
    }
    
    // MARK: - Extensions added re: joda-time API (intermediate changes, more to come)
    
    public func withYear(_ year: Int) -> DateTime {
        if let d = DateTime(year, self.month, self.day, self.hour, self.minute, self.second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withMonth(_ month: Int) -> DateTime {
        if let d = DateTime(self.year, month, self.day, self.hour, self.minute, self.second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withDay(_ day: Int) -> DateTime {
        if let d = DateTime(self.year, self.month, day, self.hour, self.minute, self.second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withHour(_ hour: Int) -> DateTime {
        if let d = DateTime(self.year, self.month, self.day, hour, self.minute, self.second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withMinute(_ minute: Int) -> DateTime {
        if let d = DateTime(self.year, self.month, self.day, self.hour, minute, self.second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withSecond(_ second: Int) -> DateTime {
        if let d = DateTime(self.year, self.month, self.day, self.hour, self.minute, second, self.millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withMillisecond(_ millisecond: Int) -> DateTime {
        if let d = DateTime(self.year, self.month, self.day, self.hour, self.minute, self.second, millisecond, self.zone, nil) {
            return d
        } else {
            return self
        }
    }
    
    public func withZone(_ zone: Zone) -> DateTime {
        if let d = DateTime(self.year, self.month, self.day, self.hour, self.minute, self.second, self.millisecond, zone, nil) {
            return d
        } else {
            return self
        }
    }
}

// MARK: - Printable protocol
extension DateTime : CustomStringConvertible {
    public var description: String {
        return "\(self.dateTime.description) - \(self.zone.description)"
    }
}

// MARK: - DebugPrintable protocol
extension DateTime : CustomDebugStringConvertible {
    public var debugDescription: String {
        return self.description
    }
}

// MARK: - Comparable protocol
extension DateTime : Comparable {}
public func ==(lhs: DateTime, rhs: DateTime) -> Bool {
    return lhs.dateTime == rhs.dateTime && lhs.zone == rhs.zone
}
public func <(lhs: DateTime, rhs: DateTime) -> Bool {
    return lhs.instant() < rhs.instant()
}

// MARK: - Operators
public func + (lhs: DateTime, rhs: Duration) -> DateTime {
    return lhs.plus(rhs)
}
public func - (lhs: DateTime, rhs: Duration) -> DateTime {
    return lhs.minus(rhs)
}
public func + (lhs: DateTime, rhs: Period) -> DateTime {
    return lhs.plus(rhs)
}
public func - (lhs: DateTime, rhs: Period) -> DateTime {
    return lhs.minus(rhs)
}
