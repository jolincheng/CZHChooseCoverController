//
//  UIButton+Extension.h
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)

+ (UIButton *)czh_buttonWithTarget:(id)target action:(SEL)action frame:(CGRect)frame imageName:(NSString *)imageName;

+ (UIButton *)czh_buttonWithTarget:(id)target action:(SEL)action frame:(CGRect)frame titleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont title:(NSString *)title;
@end
