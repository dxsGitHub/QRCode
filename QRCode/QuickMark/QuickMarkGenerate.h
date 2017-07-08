//
//  QuickMarkGenerate.h
//  ShareView
//
//  Created by dxs on 2017/5/23.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QuickMarkGenerate : NSObject

+ (UIImage *)generateWithDefaultQRCodeData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth;

+ (UIImage *)generateQRCodeWithData:(NSString *)data mainCodeColor:(UIColor *)codeColor backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)generateLogoQRCodeWithData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScale;

@end
