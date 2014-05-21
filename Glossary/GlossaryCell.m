//
//  GlossaryCell.m
//  Glossary
//
//  Created by Minwoo Jeon on 5/6/14.
//  Copyright (c) 2014 Minwoo Jeon. All rights reserved.
//


#import "GlossaryCell.h"

@implementation GlossaryCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.termLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.termLabel.frame);
    self.defLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.defLabel.frame);
}

@end