//
//  InProgressViewController.m
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import "InProgressViewController.h"
#import "Task.h"
#import "DetailsViewController.h"

@interface InProgressViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray<Task*> *todoArray;
@property NSMutableArray<Task*> *filterArray;
@property NSMutableArray * highPriorityTasks;
@property NSMutableArray * mediumPriorityTasks;
@property NSMutableArray * lowPriorityTasks;
@property UIBarButtonItem * filterButton;
@property BOOL didFilterButtonPressed;

@end

@implementation InProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _didFilterButtonPressed = FALSE;
    [self setUpBarButton];
    [self loadTasks];
    [self filterTasks];
    [self checkTableOrImage];
    [_tableView reloadData];
}

-(void)setUpBarButton{
    self.tabBarController.navigationItem.title = @"In Progress";
    _filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"line.3.horizontal.decrease.circle.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTapped)];
    self.tabBarController.navigationItem.rightBarButtonItem.hidden = FALSE;
    self.tabBarController.navigationItem.rightBarButtonItem = _filterButton;
}
-(void)loadTasks{
    NSError * error;
    NSData * savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
    if(savedData!= nil){
        NSSet * set = [NSSet setWithArray:@[[NSMutableArray class],[Task class]]];
        _todoArray = (NSMutableArray*) [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
    }
}

-(void)filterButtonTapped{
    _didFilterButtonPressed = !_didFilterButtonPressed;
    if (_didFilterButtonPressed) {
        _highPriorityTasks = [NSMutableArray new];
        _mediumPriorityTasks = [NSMutableArray new];
        _lowPriorityTasks = [NSMutableArray new];
        for (Task *task in _filterArray) {
            switch (task.priority) {
                case 0:
                    [_lowPriorityTasks addObject:task];
                    break;
                case 1:
                    [_mediumPriorityTasks addObject:task];
                    break;
                case 2:
                    [_highPriorityTasks addObject:task];
                    break;
                default:
                    break;
            }
        }
    } else {
        [self filterTasks];
    }
    [_tableView reloadData];
}

-(void)checkTableOrImage{
    if(_filterArray.count == 0){
        _tableView.hidden = TRUE;
        _imgView.hidden = FALSE;
        _imgView.image = [UIImage imageNamed:@"progress"];
    } else {
        _tableView.hidden = FALSE;
        _imgView.hidden = TRUE;
        
    }
}

- (void)filterTasks {
    _filterArray = [NSMutableArray new];
    for (Task *task in _todoArray) {
        if (task.type == 1) {
            [_filterArray addObject:task];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _didFilterButtonPressed ? 3 : 1;;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_didFilterButtonPressed) {
        switch (section) {
            case 0:
                return _lowPriorityTasks.count;
            case 1:
                return _mediumPriorityTasks.count;
            case 2:
                return _highPriorityTasks.count;
            default:
                return 0;
        }
    } else {
        return _filterArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Task *task;
    if (_didFilterButtonPressed) {
        switch (indexPath.section) {
            case 0:
                task = _lowPriorityTasks[indexPath.row];
                break;
            case 1:
                task = _mediumPriorityTasks[indexPath.row];
                break;
            case 2:
                task = _highPriorityTasks[indexPath.row];
                break;
            default:
                break;
        }
    } else {
        task = _filterArray[indexPath.row];
    }
    
    switch (task.priority) {
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
    cell.textLabel.text = task.title;
    cell.imageView.tintColor = [UIColor systemIndigoColor];
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_didFilterButtonPressed) {
        switch (section) {
            case 0:
                return @"Low";
            case 1:
                return @"Medium";
            case 2:
                return @"High";
            default:
                return @"";
        }
    }
    return @"";
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_didFilterButtonPressed){
        return nil;
    } else {
        Task *task = _filterArray[indexPath.row];
        UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
            [self editTask:task atIndex:indexPath.row];
            completionHandler(YES);
        }];
        editAction.backgroundColor = [UIColor systemMintColor];
        
        
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
            [self deleteTask:task atIndex:indexPath.row];
        }];
        deleteAction.backgroundColor = [UIColor systemRedColor];
        UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[editAction, deleteAction]];
        return actions;
    }
    
}

- (void)editTask:(Task *)task atIndex:(NSInteger)index {
    int todoIndex = (int)[_todoArray indexOfObject:task];
     DetailsViewController * detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Details"];
    detailsVC.editingTask = task;
    detailsVC.editing = TRUE;
    detailsVC.objectIndex = todoIndex;
    detailsVC.pusher = @"inprogress";
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
