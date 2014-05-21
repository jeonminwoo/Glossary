//
//  GlossaryCell.h
//  Glossary
//
//  Created by Minwoo Jeon on 5/6/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface GlossaryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *termLabel;
@property (nonatomic, weak) IBOutlet UILabel *defLabel;

@end