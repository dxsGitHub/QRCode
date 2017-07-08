//
//  QuickMark.h
//  ShareView
//
//  Created by dxs on 2017/5/8.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^QuickMarkResultBlock)(AVMetadataMachineReadableCodeObject *resultObj);

@interface QuickMark : UIViewController

@property (nonatomic, copy) QuickMarkResultBlock quickMarkResultBlock;

@end
