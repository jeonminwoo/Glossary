//
//  ColleenTableViewController.m
//  Glossary
//
//  Created by Minwoo Jeon on 5/9/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//

#import "ColleenTableViewController.h"

@interface ColleenTableViewController ()

@end

@implementation ColleenTableViewController
{
}

@synthesize sourceData;
@synthesize sortedKeys;
@synthesize prototypeCell;
@synthesize searchResults;
@synthesize alphabetsArray;

static NSString *CellIdentifier = @"UYLTextCell";

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


- (GlossaryCell *)prototypeCell
{
    if (!prototypeCell)
    {
        prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
    }
    else
    {
        return [[self.sourceData allKeys]count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GlossaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[GlossaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell tableView:tableView forRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[GlossaryCell class]])
    {
        GlossaryCell *textCell = (GlossaryCell *)cell;
        NSString *key;
        NSString *value;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            key = [searchResults objectAtIndex:indexPath.row];
            value = [self.sourceData objectForKey:key];
        }
        else
        {
            key = [self.sortedKeys objectAtIndex:indexPath.row];
            value = [self.sourceData objectForKey:key];
        }
        textCell.termLabel.text = key;
        textCell.defLabel.text = value;
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

#pragma mark - Search function

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

#pragma mark - Alphabet Index

- (NSArray *)alphabetsArray
{
    if (!alphabetsArray)
    {
        NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:0];
        for (int i=0; i< self.sortedKeys.count; i++)
        {
            NSString *firstletter=[[self.sortedKeys objectAtIndex:i]substringToIndex:1];  //modifying the statement to first letter
            if (![temp containsObject:firstletter])  //checking the array if the modified statement already exists in array
            {
                [temp addObject:firstletter];
            }
        }
        [temp sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];   //sorting array in ascending array
        //[temp insertObject:@"{search}" atIndex:0];
        alphabetsArray = temp;
    }
    return alphabetsArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.alphabetsArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString: @"{search}"])
    {
        NSIndexPath *indexSection = [NSIndexPath indexPathForRow:0 inSection:0];
        //[self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:indexSection atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NSLog(@"title:%@, i:%d",title, 0);
        return 0;
    }
    else
    {
        NSArray *dataArray = self.sortedKeys;
        for (int i = 0; i< [dataArray count]; i++)
        {
            NSString *letterString = [[dataArray objectAtIndex:i] substringToIndex:1];
            if ([letterString isEqualToString:title])
            {
                if (i <= ([dataArray count]-5))
                {
                    NSIndexPath *indexSection = [NSIndexPath indexPathForRow:i inSection:0];
                    //[self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:indexSection atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    NSLog(@"title:%@, i:%d",title, i);
                    return indexSection.row;
                }
                else
                {
                    NSIndexPath *indexSection = [NSIndexPath indexPathForRow:[dataArray count]-5 inSection:0];
                    //[self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:indexSection atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    NSLog(@"title:%@, i:%d is out of scroll boundary", title, i);
                    return [dataArray count]-5;
                }
            }
        }
    }
    
    NSLog(@"title:%@ not found", title);
    return 0;
}

@end
