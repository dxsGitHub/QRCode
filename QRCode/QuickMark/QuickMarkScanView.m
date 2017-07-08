//
//  QuickMarkScanView.m
//  ShareView
//
//  Created by dxs on 2017/5/17.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import "QuickMarkScanView.h"

#import <AVFoundation/AVFoundation.h>

#define kMarginSpace    30
#define kRedundantWidth     50
#define DEVICE_WIDTH   [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT  [UIScreen mainScreen].bounds.size.height

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.24
/** 扫描内容的Y值 */
#define scanContent_X self.frame.size.width * 0.15


static CGFloat const scanBorderOutsideViewAlpha = 0.5;

@interface QuickMarkScanView ()

@property (strong,nonatomic) NSTimer *timer;
@property (strong,nonatomic) UIImageView *scanningline;

@end

@implementation QuickMarkScanView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self addSubview:self.scanningline];
    }
    return self;
}


- (void)setupSubviews {
    // 扫描内容的创建
    _scanContent_layer = [[CALayer alloc] init];
    CGFloat scanContent_layerX = scanContent_X;
    CGFloat scanContent_layerY = scanContent_Y;
    CGFloat scanContent_layerW = self.frame.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    _scanContent_layer.frame = CGRectMake(scanContent_layerX, scanContent_layerY, scanContent_layerW, scanContent_layerH);
    _scanContent_layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    _scanContent_layer.borderWidth = 0.7;
    _scanContent_layer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:_scanContent_layer];
    
#pragma mark - - - 扫描外部View的创建
    // 顶部layer的创建
    CGRect topLayerFrame = CGRectMake(0, 0, DEVICE_WIDTH, scanContent_layerY);
    [self setupRoundLayerWithFrame:topLayerFrame];
    
    // 左侧layer的创建
    CGRect leftLayerFrame = CGRectMake(0, scanContent_layerY, scanContent_X, scanContent_layerH);
    [self setupRoundLayerWithFrame:leftLayerFrame];
    
    // 右侧layer的创建
    CGRect rightLayerFrame = CGRectMake(CGRectGetMaxX(_scanContent_layer.frame), scanContent_layerY, scanContent_X, scanContent_layerH);
    [self setupRoundLayerWithFrame:rightLayerFrame];
    
    
    // 下面layer的创建
    CGRect bottomLayerFrame = CGRectMake(0, CGRectGetMaxY(_scanContent_layer.frame), DEVICE_WIDTH, DEVICE_HEIGHT - CGRectGetMaxY(_scanContent_layer.frame));
    [self setupRoundLayerWithFrame:bottomLayerFrame];
    
    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_scanContent_layer.frame) + 15, DEVICE_WIDTH, 25)];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    [self addSubview:promptLabel];
    
    // 添加闪光灯按钮
    UIButton *light_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kRedundantWidth, kRedundantWidth)];
    [light_button setImage:[UIImage imageNamed:@"QuickMark.bundle/light_off"] forState:UIControlStateNormal];
    [light_button setImage:[UIImage imageNamed:@"QuickMark.bundle/light_on"] forState:UIControlStateSelected];
    light_button.layer.masksToBounds = YES;
    light_button.layer.cornerRadius = kRedundantWidth/2;
    [light_button setCenter:CGPointMake(self.center.x, CGRectGetMaxY(promptLabel.frame) + 2*kRedundantWidth/3)];
    [light_button addTarget:self action:@selector(controlLightClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:light_button];
    
#pragma mark - - - 扫描边角imageView的创建
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"QuickMark.bundle/QRCodeLeftTop"];
    UIImageView *left_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_scanContent_layer.frame) - left_image.size.width * 0.5 + margin, CGRectGetMinY(_scanContent_layer.frame) - left_image.size.width * 0.5 + margin, left_image.size.width, left_image.size.height)];
    [left_imageView setImage:left_image];
    [self.layer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"QuickMark.bundle/QRCodeRightTop"];
    UIImageView *right_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_scanContent_layer.frame) - right_image.size.width * 0.5 - margin, CGRectGetMinY(left_imageView.frame), left_image.size.width, left_image.size.height)];
    [right_imageView setImage:right_image];
    [self.layer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"QuickMark.bundle/QRCodeLeftBottom"];
    UIImageView *left_imageView_down = [[UIImageView alloc] initWithFrame:CGRectMake(left_imageView.frame.origin.x, CGRectGetMaxY(_scanContent_layer.frame) - left_image_down.size.width * 0.5 - margin, left_image.size.width, left_image.size.height)];
    [left_imageView_down setImage:left_image_down];
    [self.layer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"QuickMark.bundle/QRCodeRightBottom"];
    UIImageView *right_imageView_down = [[UIImageView alloc] initWithFrame:CGRectMake(right_imageView.frame.origin.x, left_imageView_down.frame.origin.y, left_image.size.width, left_image.size.height)];
    [right_imageView_down setImage:right_image_down];
    [self.layer addSublayer:right_imageView_down.layer];
}

- (void)setupRoundLayerWithFrame:(CGRect)frame {
    CALayer *roundLayer = [[CALayer alloc] init];
    [roundLayer setFrame:frame];
    roundLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    [self.layer addSublayer:roundLayer];
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:@"QuickMark.bundle/QRCodeScanningLine"];
        _scanningline.frame = CGRectMake(scanContent_X * 0.5, scanContent_Y, DEVICE_WIDTH - scanContent_X, 12);
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(lineScanUpdown:) userInfo:nil repeats:YES];
    }
    return _scanningline;
}

- (void)lineScanUpdown:(NSTimer*)timer {
    if (CGRectGetMaxY(_scanningline.frame) < CGRectGetMaxY(_scanContent_layer.frame)) {
        [_scanningline setFrame:CGRectMake(_scanningline.frame.origin.x, _scanningline.frame.origin.y + 1, _scanningline.frame.size.width, _scanningline.frame.size.height)];
    } else {
        [_scanningline setFrame:CGRectMake(_scanningline.frame.origin.x, CGRectGetMinY(_scanContent_layer.frame), _scanningline.frame.size.width, _scanningline.frame.size.height)];
    }
    NSLog(@"ceshitimer");
}

//打开系统手电筒
- (void)controlLightClickAction:(UIButton *)sender {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [captureDevice lockForConfiguration:nil];
        [captureDevice setTorchMode:AVCaptureTorchModeOn];
        [captureDevice unlockForConfiguration];
    }else{
        [captureDevice lockForConfiguration:nil];
        [captureDevice setTorchMode:AVCaptureTorchModeOff];
        [captureDevice unlockForConfiguration];
    }
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

@end
