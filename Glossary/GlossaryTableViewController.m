//
//  GlossaryTableViewController.m
//  Glossary
//
//  Created by Minwoo Jeon on 5/6/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//

#import "GlossaryTableViewController.h"
#import "GlossaryCell.h"

@interface GlossaryTableViewController ()

@end

@implementation GlossaryTableViewController
{
}

@synthesize sourceData;
@synthesize sortedKeys;
@synthesize prototypeCell;
@synthesize searchResults;
@synthesize alphabetsArray;

static NSString *UYLCellIdentifier = @"UYLTextCell";

- (NSMutableDictionary *)sourceData
{
    if (!sourceData)
    {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"airline" ofType:@"plist"];
        NSString *path2 = [[NSBundle mainBundle]pathForResource:@"colleen" ofType:@"plist"];
        NSString *path3 = [[NSBundle mainBundle]pathForResource:@"CODA" ofType:@"plist"];
        NSString *path4 = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"plist"];
        
        NSDictionary *colleenDict = [[NSDictionary alloc] initWithContentsOfFile:path2];
        NSDictionary *codaDict = [[NSDictionary alloc] initWithContentsOfFile:path3];
        NSDictionary *airlineDict = [[NSDictionary alloc] initWithContentsOfFile:path4];
        
        sourceData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        [sourceData addEntriesFromDictionary:colleenDict];
        [sourceData addEntriesFromDictionary:codaDict];
        [sourceData addEntriesFromDictionary:airlineDict];
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

    [self.searchDisplayController.searchBar becomeFirstResponder];
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
        return [self.sortedKeys count];
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


//Alphabet Index

- (NSArray *)alphabetsArray
{
    if (!alphabetsArray)
    {
        alphabetsArray = [[NSArray alloc] initWithObjects:@"{search}",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    }
    return alphabetsArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [self.alphabetsArray count];
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.alphabetsArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
     NSArray *dataArray = self.sortedKeys;
     for (int i = 0; i< [dataArray count]; i++) {
         NSString *letterString = [[dataArray objectAtIndex:i] substringToIndex:1];
         
         if ([letterString isEqualToString:title]) {
             NSIndexPath *indexSection = [NSIndexPath indexPathForRow:i inSection:0];
             [self.tableView reloadData];
             [self.tableView scrollToRowAtIndexPath:indexSection atScrollPosition:UITableViewScrollPositionTop animated:YES];
             NSLog(@"title:%@, i:%d",title, i);
             return indexSection.row;
         }
     }
     return 0;
}

@end
