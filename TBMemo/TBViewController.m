//
//  TBViewController.m
//  TBMemo
//
//  Created by tanB on 6/24/13.
//  Copyright (c) 2013 tanB. All rights reserved.
//

#import "TBViewController.h"
#import "TBMemoViewController.h"
#import "TBStoreManager.h"
#import "Memo.h"

NSString * const cellIdentifier = @"Cell";
NSString * const segueIdentiferShowDetail = @"showDetail";

@interface TBViewController ()
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@end



@implementation TBViewController

#pragma mark - view life sycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fetchedResultsController.delegate = self;
    
    self.title = @"TBMemo";
    UIBarButtonItem *backButton = [UIBarButtonItem new];
    backButton.title = @"Back";
    self.navigationItem.backBarButtonItem = backButton;
    
    CGRect accessoryViewRect = {0, self.navigationController.navigationBar.bounds.size.height - 1, self.view.bounds.size.width, 1};
    UIView *accessoryView = [[UIView alloc] initWithFrame:accessoryViewRect];
    accessoryView.layer.shadowColor = [UIColor colorWithRed:1.000 green:0.273 blue:0.000 alpha:1.000].CGColor;
    accessoryView.layer.shadowOpacity = 1;
    accessoryView.layer.shadowRadius = 3;
    accessoryView.layer.shadowOffset = CGSizeMake(0, 1);
    accessoryView.layer.shouldRasterize = YES;
    accessoryView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    accessoryView.backgroundColor = [UIColor redColor];
    self.navigationController.navigationBar.layer.shadowOpacity = 0;
    [self.navigationController.navigationBar addSubview:accessoryView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self.tableView reloadData];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:segueIdentiferShowDetail]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Memo *selectedObject =
        [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setMemoItem:selectedObject];
    }
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:segueIdentiferShowDetail sender:cell];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;

        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - misc
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Memo *memo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = memo.title;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy HH:mm"];
    cell.detailTextLabel.text = [formatter stringFromDate:memo.updatedAt];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.657 alpha:1.000];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
}

#pragma mark - coredata accessor
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    TBStoreManager *storeManager = [TBStoreManager sharedManager];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Memo"
                                              inManagedObjectContext:storeManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"updatedAt"
                                ascending:NO];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:storeManager.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"TBMemoCache"];
    
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - memory
- (void)dealloc
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}
    

@end
