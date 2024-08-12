//
//  DetailsViewController.m
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import "DetailsViewController.h"
#import "Task.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegment;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property Task * task;
@property NSMutableArray<Task*> * tasksArr;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_editing && self.editingTask != nil) {
        _titleTextField.text = _editingTask.title;
        _descriptionTextView.text = _editingTask.desc;
        _prioritySegment.selectedSegmentIndex = _editingTask.priority;
        _typeSegment.selectedSegmentIndex = _editingTask.type;
        _datePicker.date = _editingTask.date;
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    _task = [Task new];
    _tasksArr = [NSMutableArray new];
    [self handleTypeSegmentController];
    if ([_pusher isEqualToString:@"done"]) {
        _titleTextField.enabled = false;
        _descriptionTextView.userInteractionEnabled = false;
        _prioritySegment.enabled = false;
        _typeSegment.enabled = false;
        _datePicker.enabled = false;
    }
}
-(void)handleTypeSegmentController{
    if (!_editing) {
        [_typeSegment setEnabled:NO forSegmentAtIndex:1];
        [_typeSegment setEnabled:NO forSegmentAtIndex:2];
    } else {
        if ([_pusher isEqualToString:@"inprogress"]) {
                [_typeSegment setEnabled:NO forSegmentAtIndex:0]; // Enable segment 0
                [_typeSegment setEnabled:YES forSegmentAtIndex:1];
                [_typeSegment setEnabled:YES forSegmentAtIndex:2];
            } else if ([_pusher isEqualToString:@"done"]) {
                [_typeSegment setEnabled:NO forSegmentAtIndex:0];
                [_typeSegment setEnabled:NO forSegmentAtIndex:1];
                [_typeSegment setEnabled:YES forSegmentAtIndex:2];
            } else {
                [_typeSegment setEnabled:YES forSegmentAtIndex:0];
                [_typeSegment setEnabled:YES forSegmentAtIndex:1];
                [_typeSegment setEnabled:NO forSegmentAtIndex:2];
            }
    }
}
- (IBAction)donePressed:(id)sender {
    if(!_editing){
        [self addNew];
    } else if ([_pusher isEqualToString:@"done"]){
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        _editingTask.title = _titleTextField.text;
        _editingTask.desc = _descriptionTextView.text;
        _editingTask.priority = (int)_prioritySegment.selectedSegmentIndex;
        _editingTask.type = (int)_typeSegment.selectedSegmentIndex;
        _editingTask.date = _datePicker.date;
        NSError * error;
        NSData * savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
        if(savedData!= nil){
            NSSet * set = [NSSet setWithArray:@[[NSMutableArray class],[Task class]]];
            _tasksArr = (NSMutableArray*) [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        }
        NSMutableArray *mutableTasks = [_tasksArr mutableCopy];
        mutableTasks[_objectIndex] = _editingTask;
        
        NSData * archivedData = [NSKeyedArchiver archivedDataWithRootObject:mutableTasks requiringSecureCoding:YES error:&error];

        [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:@"tasks"];
        
        [self editDoneAlert];
    }
}
-(void)addNew{
    if(_titleTextField.text.length > 0){
        _task = [Task new];
        _task.title = _titleTextField.text;
        _task.desc = _descriptionTextView.text;
        _task.priority = (int)_prioritySegment.selectedSegmentIndex;
        _task.type = (int)_typeSegment.selectedSegmentIndex;
        _task.date = _datePicker.date;
        
        NSError * error;
        NSData * savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
        if(savedData!= nil){
            NSSet * set = [NSSet setWithArray:@[[NSMutableArray class],[Task class]]];
            _tasksArr = (NSMutableArray*) [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
        }
        NSMutableArray *mutableTasks = [_tasksArr mutableCopy];
        [mutableTasks addObject:_task];
        
        NSData * archivedData = [NSKeyedArchiver archivedDataWithRootObject:mutableTasks requiringSecureCoding:YES error:&error];

        [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:@"tasks"];
        
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        [self failedError];
    }
}

-(void)editDoneAlert{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Confirm edits" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:TRUE completion:nil];
}

-(void)failedError{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Enter Task Name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:TRUE completion:nil];
}


@end
