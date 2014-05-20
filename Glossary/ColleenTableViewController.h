//
//  ColleenTableViewController.h
//  Glossary
//
//  Created by Minwoo Jeon on 5/9/14.
//  Copyright (c) 2014 Keith Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UYLTextCell.h"

@interface ColleenTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableDictionary *sourceData;
@property (nonatomic, strong) NSArray *sortedKeys;
@property (nonatomic, strong) UYLTextCell *prototypeCell;
@end
