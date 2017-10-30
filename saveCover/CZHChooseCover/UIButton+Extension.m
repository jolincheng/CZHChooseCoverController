//
//  UIButton+Extension.m
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import "UIButton+Extension.h"
#import "Header.h"
@implementation UIButton (Extension)

+ (UIButton *)czh_buttonWithTarget:(id)target action:(SEL)action frame:(CGRect)frame imageName:(NSString *)imageName titleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont backgroundColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor title:(NSString *)title {
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = frame;
    button.backgroundColor = backgroundColor;
    
    if (title.length) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        button.titleLabel.font = titleFont;
    }
    
    if (imageName.length) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        if (title.length) {
            
            button.titleEdgeInsets = UIEdgeInsetsMake(0, CZH_ScaleWidth(10), 0, 0);
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, CZH_ScaleWidth(10));
        }
    }
    
    if (cornerRadius > 0) {
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = cornerRadius;
    }
    button.layer.borderWidth = borderWidth;
    button.layer.borderColor = borderColor.CGColor;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


+ (UIButton *)czh_buttonWithTarget:(id)target action:(SEL)action frame:(CGRect)frame titleColor:(UIColor *)titleColor titleFont:(UIFont *)titleFont title:(NSString *)title {
    return [UIButton czh_buttonWithTarget:target action:action frame:frame imageName:nil titleColor:titleColor titleFont:titleFont backgroundColor:nil cornerRadius:0 borderWidth:0 borderColor:nil title:title];
}


+ (UIButton *)czh_buttonWithTarget:(id)target action:(SEL)action frame:(CGRect)frame imageName:(NSString *)imageName {
    return [UIButton czh_buttonWithTarget:target action:action frame:frame imageName:imageName titleColor:nil titleFont:0 backgroundColor:nil cornerRadius:0 borderWidth:0 borderColor:nil title:nil];
}
@end
