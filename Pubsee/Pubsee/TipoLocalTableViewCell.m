//
//  TipoLocalTableViewCell.m
//  Onrange
//
//  Created by Thiago Castro on 15/05/14.
//  Copyright (c) 2014 Thiago Castro. All rights reserved.
//

#import "TipoLocalTableViewCell.h"

@implementation TipoLocalTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
