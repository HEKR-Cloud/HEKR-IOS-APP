//
//  MainTableViewCell.m
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
//    self.contentView.backgroundColor = [UIColor clearColor];
    self.whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height,FULL_WIDTH,0.5)];
    self.whiteRoundedCornerView.backgroundColor =[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
//    self.whiteRoundedCornerView.layer.masksToBounds = NO;
//    self.whiteRoundedCornerView.layer.cornerRadius = 3.0;
//    self.whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
//    self.whiteRoundedCornerView.layer.shadowOpacity = 0.5;
   // [self addSubview:self.whiteRoundedCornerView];
    //[self sendSubviewToBack:self.whiteRoundedCornerView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint position = [[[event allTouches] anyObject] locationInView:self.whiteRoundedCornerView];
    self.toucheBegiPoint = position;
}
@end
