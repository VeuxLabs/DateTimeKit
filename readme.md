# DateTimeKit Overview
DateTimeKit is a Swift library that provides simple, easy-to-use date, time and timezone manipulation.  The ideas behind DateTimeKit are quite heavily influenced by the [JodaTime](http://www.joda.org/joda-time/) library.

DateTimeKit removes the dependence on `NSDate` and `NSCalendar` and provides a new set of objects in their place. 

## Instant
An instant represents a moment on the datetime continuum. Under the covers, just like `NSDate`, it represents the number of milliseconds since the *reference date (1st Jan 1970)*.  It is totally independent of timezone.

```
let now = Instant()
println(now.description)   // 2015-03-18 05:13:43 +0000

```

If you want to convert a Date object to Instant you should call this method:
```
let now = Date()
let instant = Instant,init(now)
println(now.description)   // 2015-03-18 05:13:43 +0000

```

## Zone
A zone is a representation of a specific timezone. It can be constructed using a timezone abbreviation, name or an absolute number of hours/minutes/seconds.

```
let sydneyZone = Zone("Australia/Sydney")!
let utcZone    = Zone.utc()
let randomZone = Zone("-12:46")!

```

## DateTime
A `DateTime` object is a combination of a specific `instant` and `zone`, and is generally what people perceive as a date and time based on their wall-clock in their specific time zone.

```
let now = Instant()

let sydneyZone = Zone("Australia/Sydney")!
let parisZone  = Zone("Europe/Paris")!

let sydneyTime = DateTime(now, sydneyZone)
println(sydneyTime)       // 2015-03-06 19:02:28.662 - Australia/Sydney (GMT+11) offset 39600 (Daylight)

let parisTime = sydneyTime.inZone(parisZone)
println(parisTime)        // 2015-03-06 09:02:28.662 - Europe/Paris (GMT+1) offset 3600

```

## Weeks Methods
Is import to get the first and last day of a specific `DateTime` for that this library has the following methods:

These methods get the initial  and end day of the week using Sunday always as the first day of the week

```
let zone = Zone()
let customDate = DateTime(2016 , 05, 15, 02, 20, 0, 0, zone)!

let firstDateOfTheWeekForAnSpecificDate = customDate.getFirstDayOfTheWeek()
print(firstDateOfTheWeekForAnSpecificDate.description)       // 2016-05-15 00:00:00 - America/Costa_Rica (CST) offset -21600

let lastDateOfTheWeekForAnSpecificDate = customDate.getLastDayOfTheWeek()
print(lastDateOfTheWeekForAnSpecificDate.description)        // 2016-05-21 23:59:59.59 - America/Costa_Rica (CST) offset -21600

```

These methods get the initial and end day of the week using the current calendar, for example if the device has configured the region in CR the first day should be Monday and the last day should be Sunday, if the device has configured the region in the United States the first should be Sunday and the last day Saturday

```
//Region: Costa Rica
let zone = Zone()
let customDate = DateTime(2016 , 05, 18, 02, 20, 0, 0, zone)!

let firstDateOfTheWeekForAnSpecificDate = getFirstDayOfTheWeekUsingTheCurrentCalendar()
print(firstDateOfTheWeekForAnSpecificDate.description)       // 2016-05-16 00:00:00 - America/Costa_Rica (CST) offset -21600

let lastDateOfTheWeekForAnSpecificDate = customDate.getLastDayOfTheWeekUsingTheCurrentCalendar()
print(lastDateOfTheWeekForAnSpecificDate.description)        // 2016-05-22 23:59:59.59 - America/Costa_Rica (CST) offset -21600

```

In the others cases when the initial day is different of Monday or Sunday the initial day must be configured Sunday.


## Days Methods
Is import to know what is the day number of the specific date for that this library has the following method
```
let zone = Zone()
let customDate = DateTime(2016 , 05, 15, 02, 20, 0, 0, zone)!
let dayOfTheWeek = customDate.getDayOfTheWeek()
print(dayOfTheWeek)        // Sunday

let firstMillisecondOfDay = customDate.getFirstMillisecondOfDay()
print(firstMillisecondOfDay.description)       // 1466732025000

let lastMillisecondOfDay = customDate.getLastMillisecondOfDay()
print(lastMillisecondOfDay.description)        // 1466322025000
```

## Months Methods
Import to know what the first and last millisecond for the current month.
```
let firstMillisecondOfMonth = customDate.getFirstMillisecondOfMonth()

print(firstMillisecondOfMonth.description)      // 1466732025000

let lastMillisecondOfMonth = customDate.getLastMillisecondOfMonth()
print(lastMillisecondOfMonth.description)        // 1466322025000
```

## Duration
A duration is a explicit length of time that can be measured in seconds (or part thereof). For example, 2 hours can be represented as 7200 seconds.

```
// current time in user's default timezone
let now = DateTime()
println(now)          // 2015-03-18 16:20:24.157 - Australia/Sydney (GMT+11) offset 39600 (Daylight)

let dt1 = now + Duration(7200)
println(dt1)          // 2015-03-18 18:20:24.157 - Australia/Sydney (GMT+11) offset 39600 (Daylight)"

let dt2 = now + 2.hours
println(dt2)          // 2015-03-18 18:20:24.157 - Australia/Sydney (GMT+11) offset 39600 (Daylight)"
```

## Period
A period is a conceptual length of time that may vary slightly depending on which date it is applied to. For example, the specific length of “2 months and 2 days” varies depending on what month it is being applied to.

```
// current time in user's default timezone
let now = DateTime()
println(now)          // 2015-03-18 16:28:07.845 - Australia/Sydney (GMT+11) offset 39600 (Daylight)

let dt1 = now + Period(0, 2, 2)
println(dt1)          // 2015-05-20 16:28:07.845 - Australia/Sydney (GMT+11) offset 39600 (Daylight)
```

## Clock
All of the above examples work just fine, but if you are creating date/time objects representing the “current” time by using the default constructors, then it gets a bit tricky to test because the system clock is obviously continually advancing.

If you need to test your temporal logic, it is often useful to be able to provide an alternate provider of the "current" time. The `Clock` protocol and its various implementations give you the flexibility to provide alternative implementations.

If you don’t provide a clock to the various constructors, then the `SystemClock` implementation will be used, which always returns the current system time.

```
let clock = SystemClock()
let now = Instant(clock)     // this is equivalent to calling Instant()
```

However, sometimes you might want to be able to test code based on a specific date. A `FixedClock` always returns exactly the same instant:

```
// normal application code would be something like:
let clock = SystemClock()

// but test case code would something like:
let someInstant = ...
let someTimezone = ...
let clock = FixedClock(someInstant, someTimeZone)

// then by using dependency injection, or passing the clock around in your application code,
// you can provide sensible behaviour during normal execution and test case execution
let now = Instant(clock)
```

Using a `Clock` instance when creating your “current” date/time objects gives you much better testability.

# Installation

## Copy and Paste
The simplest, but not necessarily best, way to install DateTimeKit is perform the following steps:

* Clone or checkout the project from github into a folder somewhere
* Drag `DateTimeKit.xcodeproj` from the Finder into your project
* Add `DateTimeKit.framework` to your target’s *Linked Frameworks and Libraries* (be sure to pick the correct iOS or OS X framework depending on what sort of app you are writing)
* Rebuild your project

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate DateTimeKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'DateTimeKit', :git => 'https://github.com/edwardaux/DateTimeKit.git'
```

Then, run the following command:

```bash
$ pod install
```

## Carthage
Still to come

# Feedback
Feel free to ask questions, raise issues or create pull requests. More than happy to receive feedback on new features or how I might have done things better.

I’m contactable via [twitter](https://twitter.com/edwardaux) or [email](mailto:craig@blackdogfoundry.com).

# Contributors

* Zacharias J. Beckman [email](mailto:zbeckman@HyraxLLC.com) [fork](https://github.com/zbeckman/DateTimeKit)

### Some other libraries:
DateTimeKit was also inspired by other works.
Some links:
* [JodaTime](http://www.joda.org/joda-time)
* [SwiftDate](https://github.com/malcommac/SwiftDate)
* [AFDateHelper](https://github.com/melvitax/AFDateHelper)
* [Timepiece](https://github.com/naoty/Timepiece)
* [MSDateFormatter](https://github.com/Namvt/MSDateFormatter)
