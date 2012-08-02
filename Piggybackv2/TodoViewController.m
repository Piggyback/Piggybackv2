//
//  TodoViewController.m
//  Piggybackv2
//
//  Created by Michael Gao on 7/31/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "TodoViewController.h"
#import "PBMusicTodo.h"
#import "PBMusicActivity.h"
#import "PBMusicItem.h"

@interface TodoViewController ()

@property (nonatomic, strong) NSArray *todosToDisplay;

@end

@implementation TodoViewController

@synthesize tableView = _tableView;
@synthesize todosToDisplay = _todosToDisplay;

#pragma mark - Getters & Setters
- (void)setTodosToDisplay:(NSArray *)todosToDisplay {
    if (_todosToDisplay != todosToDisplay) {
        _todosToDisplay = todosToDisplay;
        [self.tableView reloadData];
    }
}

#pragma mark - Private helper methods
- (void)loadObjectsFromDataStore {
    NSFetchRequest* request = [PBMusicTodo fetchRequest];
    //    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"referralDate" ascending:NO];
    //    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    self.todosToDisplay = [PBMusicTodo objectsWithFetchRequest:request];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.todosToDisplay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"todoTableCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PBMusicTodo *todo = [self.todosToDisplay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", todo.musicActivity.musicItem.songTitle];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjectsFromDataStore];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
