//
//  ViewController.m
//  ToDoApplication
//
//  Created by sayed mansour on 12/08/2024.
//

#import "ToDoViewController.h"
#import "Task.h"
#import "DetailsViewController.h"

@interface ToDoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property NSMutableArray<Task*> *todoArray;
@property NSMutableArray<Task*> *filterArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray * searchArray;
@property BOOL isSearched;
@property UIBarButtonItem * addButton;

@end

@implementation ToDoViewController

- (void)viewDidLoad {
    [super viewDidLoad];\
    _isSearched = FALSE;
    _searchArray = [NSMutableArray new];
    _searchBar.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
   
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"Todo Notes";
    [self setUpBarButton];
    [self loadTasks];
    [self filterTasks];
    [self checkTableOrImage];
    [_tableView reloadData];
    
}
-(void)setUpBarButton{
    _addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addButtonTapped)];
    self.tabBarController.navigationItem.rightBarButtonItem.hidden = FALSE;
    self.tabBarController.navigationItem.rightBarButtonItem = _addButton;
}
-(void)addButtonTapped{
    DetailsViewController * taskDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Details"];
    [taskDetailsVC setEditing:NO];
    taskDetailsVC.editing = FALSE;
    [self.navigationController pushViewController:taskDetailsVC animated:TRUE];
}

-(void)loadTasks{
    NSError * error;
    NSData * savedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
    if(savedData!= nil){
        NSSet * set = [NSSet setWithArray:@[[NSMutableArray class],[Task class]]];
        _todoArray = (NSMutableArray*) [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:savedData error:&error];
    }
}
- (void)filterTasks {
    _filterArray = [NSMutableArray new];
    for (Task *task in _todoArray) {
        if (task.type == 0) {
            [_filterArray addObject:task];
        }
    }
}

-(void)checkTableOrImage{
    if(_filterArray.count == 0){
        _tableView.hidden = TRUE;
        _imgView.hidden = FALSE;
        _imgView.image = [UIImage imageNamed:@"todo"];
    } else {
        _tableView.hidden = FALSE;
        _imgView.hidden = TRUE;
    }
}
// searchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
   
    if (searchText.length == 0) {
        _isSearched = FALSE;
    } else {
        _isSearched = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchText];
        _searchArray = [[_filterArray filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    [_tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _isSearched = FALSE;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [_tableView reloadData];
}
// TableView funcs
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearched) {
        return _searchArray.count;
    }
    return _filterArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Task *task;
    if (_isSearched) {
        task = _searchArray[indexPath.row];
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
    cell.imageView.tintColor = [UIColor systemIndigoColor];
    cell.textLabel.text = task.title;
    return cell;
    
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task *task;
    if (_isSearched) {
        task = _searchArray[indexPath.row];
    } else {
        task = _filterArray[indexPath.row];
    }
    
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:@"Edit"
                                                                           handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self editTask:task atIndex:indexPath.row];
        completionHandler(YES);
    }];
    editAction.backgroundColor = [UIColor systemMintColor];
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"Delete"
                                                                             handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self deleteTask:task atIndex:indexPath.row];
    }];
    deleteAction.backgroundColor = [UIColor systemRedColor];
    UISwipeActionsConfiguration *actions = [UISwipeActionsConfiguration configurationWithActions:@[editAction, deleteAction]];
    return actions;
}
- (void)editTask:(Task *)task atIndex:(NSInteger)index {
    int todoIndex = (int)[_todoArray indexOfObject:task];
    DetailsViewController * taskDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Details"];
    taskDetailsVC.editingTask = task;
    taskDetailsVC.editing = TRUE;
    taskDetailsVC.objectIndex = todoIndex;
    [self.navigationController pushViewController:taskDetailsVC animated:TRUE];
}

- (void)deleteTask:(Task *)task atIndex:(NSInteger)index {
    int todoIndex = (int)[self.todoArray indexOfObject:task];
    [self.todoArray removeObjectAtIndex:todoIndex];
    [self saveTasks];
    [self filterTasks];
    [self checkTableOrImage];
    [self.tableView reloadData];
}

- (void)saveTasks {
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.todoArray requiringSecureCoding:NO error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"tasks"];
}


@end
