//
//  ColleenTableViewController.m
//  Glossary
//
//  Created by Minwoo Jeon on 5/9/14.
//  Copyright (c) 2014 Keith Harrison. All rights reserved.
//

#import "ColleenTableViewController.h"

@interface ColleenTableViewController ()

@end

@implementation ColleenTableViewController
{
    NSMutableArray *searchResults;
    NSArray *alphabetsArray;
}

@synthesize sourceData;
@synthesize sortedKeys;
@synthesize prototypeCell;

static NSString *UYLCellIdentifier = @"UYLTextCell";

#pragma mark -
#pragma mark === Accessors ===
#pragma mark -

- (NSMutableDictionary *)sourceData
{
    if (!sourceData)
    {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"colleen" ofType:@"plist"];
        
        sourceData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

    }
    return sourceData;
}

- (NSArray *)sortedKeys
{
    if (!sortedKeys)
    {
        sortedKeys = [[self.sourceData allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    }
    return sortedKeys;
}


- (UYLTextCell *)prototypeCell
{
    if (!prototypeCell)
    {
        prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:UYLCellIdentifier];
    }
    return prototypeCell;
}

#pragma mark -
#pragma mark === View Life Cycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    //[self createAlphabetArray];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark === UITableViewDataSource ===
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [[self.sourceData allKeys]count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UYLTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UYLCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UYLTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UYLCellIdentifier];
    }
    
    [self configureCell:cell tableView:tableView forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[UYLTextCell class]])
    {
        UYLTextCell *textCell = (UYLTextCell *)cell;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSString *key = [searchResults objectAtIndex:indexPath.row];
            NSString *value = [self.sourceData objectForKey:key];
            textCell.termLabel.text = key;
            textCell.defLabel.text = value;
        } else {
            NSString *key = [self.sortedKeys objectAtIndex:indexPath.row];
            NSString *value = [self.sourceData objectForKey:key];
            textCell.termLabel.text = key;
            textCell.defLabel.text = value;
        }
        
    }
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.prototypeCell tableView:tableView forRowAtIndexPath:indexPath];
    
    // Need to set the width of the prototype cell to the width of the table view as this will change when the device is rotated.
    
    self.prototypeCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

//Search function

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    NSArray *tempArray = [self.sortedKeys filteredArrayUsingPredicate:resultPredicate];
    searchResults = [NSMutableArray arrayWithArray:tempArray];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}
@end
