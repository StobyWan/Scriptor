//
//  NSDate+Utilities.h
//  Scriptor
//
//  Created by Bryan Stober on 1/14/14.
//  Copyright (c) 2014 Bryan Stober. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE        60
#define D_HOUR          3600
#define D_DAY           86400
#define D_WEEK          604800
#define D_YEAR          31556926

@interface NSDate (Utilities)

// Relative dates from the current date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSUInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSUInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSUInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSUInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSUInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSUInteger) dMinutes;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
@property (NS_NONATOMIC_IOSONLY, getter=isToday, readonly) BOOL today;
@property (NS_NONATOMIC_IOSONLY, getter=isTomorrow, readonly) BOOL tomorrow;
@property (NS_NONATOMIC_IOSONLY, getter=isYesterday, readonly) BOOL yesterday;
- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
@property (NS_NONATOMIC_IOSONLY, getter=isThisWeek, readonly) BOOL thisWeek;
@property (NS_NONATOMIC_IOSONLY, getter=isNextWeek, readonly) BOOL nextWeek;
@property (NS_NONATOMIC_IOSONLY, getter=isLastWeek, readonly) BOOL lastWeek;
- (BOOL) isSameYearAsDate: (NSDate *) aDate;
@property (NS_NONATOMIC_IOSONLY, getter=isThisYear, readonly) BOOL thisYear;
@property (NS_NONATOMIC_IOSONLY, getter=isNextYear, readonly) BOOL nextYear;
@property (NS_NONATOMIC_IOSONLY, getter=isLastYear, readonly) BOOL lastYear;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;

// Adjusting dates
- (NSDate *) dateByAddingDays: (NSUInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSUInteger) dDays;
- (NSDate *) dateByAddingHours: (NSUInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSUInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSUInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSUInteger) dMinutes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *dateAtStartOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

@end
