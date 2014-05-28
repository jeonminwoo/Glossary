//
//  CODATableViewController.m
//  Glossary
//
//  Created by Minwoo Jeon on 5/28/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//

#import "CODATableViewController.h"

@interface CODATableViewController ()

@end

@implementation CODATableViewController
{
}

@synthesize sourceData;
@synthesize sortedKeys;
@synthesize prototypeCell;
@synthesize searchResults;

static NSString *UYLCellIdentifier = @"UYLTextCell";

- (NSMutableDictionary *)sourceData
{
    if (!sourceData)
    {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"CODA" ofType:@"plist"];
        
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


- (GlossaryCell *)prototypeCell
{
    if (!prototypeCell)
    {
        prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:UYLCellIdentifier];
    }
    return prototypeCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
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
    GlossaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:UYLCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[GlossaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UYLCellIdentifier];
    }
    
    [self configureCell:cell tableView:tableView forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[GlossaryCell class]])
    {
        GlossaryCell *textCell = (GlossaryCell *)cell;
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
