//
//  CZHChooseCoverCell.m
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import "CZHChooseCoverCell.h"


@interface CZHChooseCoverCell ()
///<#注释#>
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation CZHChooseCoverCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setView];
        
    }
    return self;
}

- (void)setView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = self.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
}

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = coverImage;
    self.imageView.image = coverImage;
}


@end
