//
//  DoneViewController.m
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import "DoneViewController.h"
#import "Task.h"
#import "DetailsViewController.h"

@interface DoneViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray<Task*> *todoArray;
@property NSMutableArray<Task*> *filterArray;
@end

@implementation DoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Done";
    self.tabBarController.navigationItem.rightBarButtonItem.hidden = TRUE;
    [self loadTasks];
    [self filterTasks];
    [self checkTableOrImage];
    [_tableView reloadData];
}

-(void)loadTasks{
    NSError * error;
    NSData * savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
    if(savedData!= nil){
        NSSet * set = [NSSet setWithArray:@[[NSMutableArray class],[Task class]]];
        _todoArray = (NSMutableArray*) [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
    }
}
-(void)checkTableOrImage{
    if(_filterArray.count == 0){
        _tableView.hidden = TRUE;
        _imgView.hidden = FALSE;
        _imgView.image = [UIImage imageNamed:@"done"];
    } else {
        _tableView.hidden = FALSE;
        _imgView.hidden = TRUE;
    }
}

- (void)filterTasks {
    _filterArray = [NSMutableArray new];
    for (Task *task in _todoArray) {
        if (task.type == 2) {
            [_filterArray addObject:task];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filterArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    switch (_filterArray[indexPath.row].priority) {
        case 0:
            cell.imageView.image = ([[UIImage imageNamed:@"low"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
            break;
        case 1:
            cell.imageView.image = ([[UIImage imageNamed:@"medium"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
            break;
        case 2:
            cell.imageView.image = ([[UIImage imageNamed:@"high"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
            break;
            
        default:
            break;
    }
    cell.imageView.tintColor = [UIColor systemTealColor];
    cell.textLabel.text = _filterArray[indexPath.row].title;
    
    
    return cell;
    
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task *task = _filterArray[indexPath.row];
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit"
        handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self editTask:task atIndex:indexPath.row];
        completionHandler(YES);
    }];
    editAction.backgroundColor = [UIColor systemMintColor];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete"
        handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self deleteTask:task atIndex:indexPath.row];
    }];
    deleteAction.backgroundColor = [UIColor systemRedColor];
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[editAction, deleteAction]];
    return actions;
}

- (void)editTask:(Task *)task atIndex:(NSInteger)index {
    int todoIndex = (int)[_todoArray indexOfObject:task];
    DetailsViewController * detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Details"];
    detailsVC.editingTask = task;
    detailsVC.editing = TRUE;
    detailsVC.objectIndex = todoIndex;
    detailsVC.pusher = @"done";
    [self.navigationController pushViewController:detailsVC animated:TRUE];
}

- (void)deleteTask:(Task *)task atIndex:(NSInteger)index {
    int todoIndex = (int)[_todoArray indexOfObject:task];
    [_todoArray removeObjectAtIndex:todoIndex];
    [self saveTasks];
    [self filterTasks];
    [self checkTableOrImage];
    [_tableView reloadData];
}

- (void)saveTasks {
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_todoArray requiringSecureCoding:NO error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"tasks"];
    
}


@end
