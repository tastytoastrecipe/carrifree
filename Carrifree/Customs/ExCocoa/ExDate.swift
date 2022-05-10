//
//  ExDate.swift
//  CarrifreeStorage
//
//  Created by plattics-kwon on 2021/01/11.
//

import Foundation

extension Date {
    
    var localDate: Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else { return self }
        return localDate
    }
    
    var timestamp: Int64 {
        return Int64(timeIntervalSince1970)
    }
    
    var timestampString: String {
        return "\(Int64(timeIntervalSince1970))"
    }
    
//    func localDate2() -> Date {
//        let nowUTC = Date()
//        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
//        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else { return self }
//
//        return localDate
//    }
    
    // MARK: - 특정 연도, 월, 일 구함
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
    
    // 해당 연도에서 모든 주말을 구한다
    var weekendsInYear: [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        
        // DateComponents 생성시 timeZone 반드시 넣어야함!!
        let timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.range(of: .day, in: .year, for: self)?.compactMap {
            guard let date = DateComponents(calendar: calendar, timeZone: timeZone, year: year, day: $0).date, calendar.isDateInWeekend(date) else {
                return nil
            }
            return date
        } ?? []
    }
    
    // 해당 월의 모든 날을 구한다
    var allDayInMonth: [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        
        // DateComponents 생성시 timeZone 반드시 넣어야함!!
        let timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.range(of: .day, in: .month, for: self)?.compactMap {
            guard let date = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: $0).date else {
                return nil
            }
            return date
        } ?? []
    }
    
    // 해당 월의 모든 주말을 구한다
    var weekendsInMonth: [Date] {
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        
        // DateComponents 생성시 timeZone 반드시 넣어야함!!
        let timeZone = TimeZone(abbreviation: "UTC")!
        return calendar.range(of: .day, in: .month, for: self)?.compactMap {
            guard let date = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: $0).date, calendar.isDateInWeekend(date) else {
                return nil
            }
            return date
        } ?? []
    }
    
    // 해당 월의 모든 특정 요일을 구한다
    /*
    func getWeekdaysInMonth(weekday: Weekday) -> [Date] {
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        
        var dates: [Date] = []
        
        // DateComponents 생성시 timeZone 반드시 넣어야함!!
        let timeZone = TimeZone(abbreviation: "UTC")!
        dates = calendar.range(of: .day, in: .month, for: self)?.compactMap {
            
            let dateComponents = DateComponents(calendar: calendar, timeZone: timeZone, year: year, month: month, day: $0)
            let componentWeekDay = calendar.dateComponents(in: timeZone, from: dateComponents.date ?? Date()).weekday
            if componentWeekDay == weekday.rawValue {
                return dateComponents.date
            } else {
                return nil
            }
        
        } ?? []
        
        return dates
    }
    */
    
    // MARK: - 일 or 월의 첫째 날(시간), 마지막 날(시간) 추출
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
    
    // MARK: - Date format
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var orderDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMdd HH:mm"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    var simpleDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:SS"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var onlyDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var onlyTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public func toString() -> String {
        return dateFormatter.string(from: self as Date)
    }
    
    public func toSimpleString() -> String {
        return simpleDateFormatter.string(from: self as Date)
    }
    
    public func toOrderDateString() -> String {
        return orderDateFormatter.string(from: self as Date)
    }
    
    public func toOnlyDateString() -> String {
        return onlyDateFormatter.string(from: self as Date)
    }

    public func toOnlyTimeString() -> String {
        return onlyTimeFormatter.string(from: self as Date)
    }
}
