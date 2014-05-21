//
//  GlossaryTableViewController.h
//  Glossary
//
//  Created by Minwoo Jeon on 5/6/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlossaryCell.h"

@interface GlossaryTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableDictionary *sourceData;
@property (nonatomic, strong) NSArray *sortedKeys;
@property (nonatomic, strong) GlossaryCell *prototypeCell;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSArray *alphabetsArray;
@end
