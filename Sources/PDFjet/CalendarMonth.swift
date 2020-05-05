/**
 *  CalendarMonth.swift
 *
Copyright (c) 2018, Innovatics Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and / or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
import Foundation


public class CalendarMonth {

    var f1: Font?
    var f2: Font?

    var x1: Float = 75.0
    var y1: Float = 75.0
    var dx: Float = 23.0
    var dy: Float = 20.0

    let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    //            1     2     3     4     5     6     7     // DAY_OF_WEEK

    var days_in_month: Int?
    var day_of_week: Int?


    public init(_ f1: Font, _ f2: Font, _ year: Int, _ month: Int) {
        self.f1 = f1
        self.f2 = f2
        days_in_month = getDaysInMonth(year, month - 1)
        let calendar = Calendar.current
        let components = DateComponents(
                calendar: calendar, year: year, month: month, day: 0)
        day_of_week = calendar.component(.weekday, from: components.date!)
    }


    public func setHeadFont(_ font: Font) {
        self.f1 = font
    }


    public func setBodyFont(_ font: Font) {
        self.f2 = font
    }


    public func setLocation(_ x: Float, _ y: Float) {
        self.x1 = x
        self.y1 = y
    }


    public func setCellWidth(_ width: Float) {
        self.dx = width
    }


    public func setCellHeight(_ height: Float) {
        self.dy = height
    }


    public func drawOn(_ page: Page) {
        for row in 0..<7 {
            for col in 0..<7 {
                if row == 0 {
                    let offset = (dx - f1!.stringWidth(days[col])) / 2
                    let text = TextLine(f1!, days[col])
                    text.setLocation(x1 + Float(col)*dx + offset, x1 + Float(row)*dy)
                    text.drawOn(page)
                    // Draw the line separating the title from the dates.
                    let line = Line(
                            x1,
                            y1 + dx/4,
                            x1 + 7*dx,
                            y1 + dx/4)
                    line.setWidth(0.5)
                    line.drawOn(page)
                }
                else {
                    let day_of_month = ((7*row + col) - 6) - day_of_week!
                    if day_of_month > 0 && day_of_month <= days_in_month! {
                        let s1 = String(day_of_month)
                        let offset = (dx - f2!.stringWidth(s1)) / 2
                        let text = TextLine(f2!, s1)
                        text.setLocation(x1 + Float(col)*dx + offset, y1 + Float(row)*dy)
                        text.drawOn(page)

                        page.setPenWidth(1.5)
                        page.setPenColor(Color.blue)
                        page.drawEllipse(x1 + Float(col)*dx + dx/2, y1 + Float(row)*dy - dy/5, 8.0, 8.0)
                    }
                }
            }
        }
    }


    private func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }


    private func getDaysInMonth(
            _ year: Int,
            _ month: Int) -> Int {
        let daysInFebruary = isLeapYear(year) ? 29 : 28
        let daysInMonth = [31, daysInFebruary, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return daysInMonth[month]
    }

}
