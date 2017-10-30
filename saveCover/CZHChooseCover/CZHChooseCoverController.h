//
//  CZHChooseCoverController.h
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface CZHChooseCoverController : UIViewController
///本地视频路径
@property (nonatomic, copy) NSURL *videoPath;
///封面回调
@property (nonatomic, copy) void (^coverImageBlock)(UIImage *coverImage);
@end
