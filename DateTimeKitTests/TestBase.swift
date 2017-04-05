//
//  TestDTBase.swift
//  DateTimeKit
//
//  Created by Craig Edwards
//  Copyright (c) 2015 Craig Edwards. All rights reserved.
//

import Foundation
import XCTest
import DateTimeKit

//func DTAssertNil<T>(_ expression: @autoclosure () -> T?, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssert(expression() == nil, message, file:file, line:line)
//}
//
//func DTAssertNotNil<T>(_ expression: @autoclosure () -> T?, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssert(expression() != nil, message, file:file, line:line)
//}
//
//func DTAssertEqual(_ date: LocalDate, year: Int, month: Int, day: Int, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssertEqual(date.year, year, "Year contains unexpected value", file:file, line:line)
//	XCTAssertEqual(date.month, month, "Month contains unexpected value", file:file, line:line)
//	XCTAssertEqual(date.day, day, "Day contains unexpected value", file:file, line:line)
//}
//
//func DTAssertEqual(_ time: LocalTime, hour: Int, minute: Int, second: Int, millisecond: Int, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssertEqual(time.hour, hour, "Hour contains unexpected value", file:file, line:line)
//	XCTAssertEqual(time.minute, minute, "Minute contains unexpected value", file:file, line:line)
//	XCTAssertEqual(time.second, second, "Second contains unexpected value", file:file, line:line)
//	XCTAssertEqual(time.millisecond, millisecond, "Millisecond contains unexpected value", file:file, line:line)
//}
//
//func DTAssertEqual(_ dateTime: LocalDateTime, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, millisecond: Int, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssertEqual(dateTime.year, year, "Year contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.month, month, "Month contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.day, day, "Day contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.hour, hour, "Hour contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.minute, minute, "Minute contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.second, second, "Second contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.millisecond, millisecond, "Millisecond contains unexpected value", file:file, line:line)
//}
//
//func DTAssertEqual(_ dateTime: DateTime, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, millisecond: Int, message: String = "", file: String = #file, line: UInt = #line) {
//	XCTAssertEqual(dateTime.year, year, "Year contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.month, month, "Month contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.day, day, "Day contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.hour, hour, "Hour contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.minute, minute, "Minute contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.second, second, "Second contains unexpected value", file:file, line:line)
//	XCTAssertEqual(dateTime.millisecond, millisecond, "Millisecond contains unexpected value", file:file, line:line)
//}
