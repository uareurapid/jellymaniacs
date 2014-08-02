//
//  MyStoreTableViewCell.m
//  JellyCrush
//
//  Created by Paulo Cristo on 30/07/14.
//  Copyright (c) 2014 PC Dreams Software. All rights reserved.
//

#import "MyStoreTableViewCell.h"



@implementation MyStoreTableViewCell

@synthesize smashBombLocker,darkJellyLocker,blueJellyLocker,redJellyLocker,greenJellyLocker,yellowJellyLocker,pinkJellyLocker;

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
