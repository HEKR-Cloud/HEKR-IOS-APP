//
//  MainTableViewCell.h
//  Hekr
//
//  Created by Michael Scofield on 2015-06-25.
//  Copyright (c) 2015 Michael Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@interface MainTableViewCell : SWTableViewCell
@property(weak)IBOutlet UIImageView *productIcon;
@property(weak)IBOutlet UILabel *switchs;
@property(weak)IBOutlet UILabel *switchsStatus;
@property(weak)IBOutlet UILabel *productName;
@property(strong)UIView *whiteRoundedCornerView;
@property(assign)CGPoint toucheBegiPoint;
@end
