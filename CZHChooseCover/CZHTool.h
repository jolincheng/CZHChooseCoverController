//
//  CZHTool.h
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CZHTool : NSObject
//获取视频的大小和时间
+ (NSDictionary *)getLocalVideoSizeAndTimeWithSourcePath:(NSString *)path;
//吧mov视频转换成mp4格式
+ (void)convertMovTypeIntoMp4TypeWithSourceUrl:(NSURL *)sourceUrl convertSuccess:(void (^)(NSURL *path))convertSuccess;
//创建视频存放文件夹
+ (void)createVideoFolderIfNotExist;
//颜色转换图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end
