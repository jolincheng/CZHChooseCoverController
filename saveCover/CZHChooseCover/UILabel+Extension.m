//
//  UIButton+Extension.m
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import "UILabel+Extension.h"

@implementation UILabel (Extension)

+ (UILabel *)setLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textAliment:(NSTextAlignment)textAliment shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset numberOfLines:(NSInteger)numberOfLines text:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.frame = frame;
    label.textAlignment = textAliment;
    label.text = text;
    label.numberOfLines = numberOfLines;
    label.shadowColor = shadowColor;
    label.shadowOffset = shadowOffset;
    if (backgroundColor == nil) {
        label.backgroundColor = [UIColor clearColor];
    } else {
        label.backgroundColor = backgroundColor;
    }
    label.font = font;
    label.textColor = textColor;
    
    return label;
}

+ (UILabel *)setLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textAliment:(NSTextAlignment)textAliment shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset text:(NSString *)text {
    
    return [UILabel setLabelWithFrame:frame font:font textColor:textColor backgroundColor:backgroundColor textAliment:textAliment shadowColor:shadowColor shadowOffset:shadowOffset numberOfLines:1 text:text];
}

+ (UILabel *)setLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textAliment:(NSTextAlignment)textAliment text:(NSString *)text {
    
    return [UILabel setLabelWithFrame:frame font:font textColor:textColor backgroundColor:backgroundColor textAliment:textAliment shadowColor:nil shadowOffset:CGSizeZero text:text];
}

+ (UILabel *)setLabelWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor textAliment:(NSTextAlignment)textAliment text:(NSString *)text {
    return [UILabel setLabelWithFrame:frame font:font textColor:textColor backgroundColor:[UIColor clearColor] textAliment:textAliment text:text];
}

@end
