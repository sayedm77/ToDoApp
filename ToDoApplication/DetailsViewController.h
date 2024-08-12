//
//  DetailsViewController.h
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property Task * editingTask;
@property BOOL editing;
@property int objectIndex;
@property NSString * pusher;

@end

NS_ASSUME_NONNULL_END
