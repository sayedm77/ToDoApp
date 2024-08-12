//
//  Task.m
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import "Task.h"

@implementation Task

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:_title forKey:@"title"];
    [coder encodeObject:_desc forKey:@"description"];
    [coder encodeInt:_priority forKey:@"priority"];
    [coder encodeInt:_type forKey:@"type"];
    [coder encodeObject:_date forKey:@"date"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _desc = [coder decodeObjectOfClass:[NSString class] forKey:@"description"];
        _priority = [coder decodeIntForKey:@"priority"];
        _type = [coder decodeIntForKey:@"type"];
        _date = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding{
    return TRUE;
}



@end
