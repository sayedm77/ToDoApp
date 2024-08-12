//
//  Task.h
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject <NSCoding, NSSecureCoding>

@property NSString * title, *desc;
@property int priority, type;
@property NSDate* date;

@end

NS_ASSUME_NONNULL_END
