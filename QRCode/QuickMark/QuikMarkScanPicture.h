//
//  QuikMarkScanPicture.h
//  ShareView
//
//  Created by dxs on 2017/5/23.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^QuikMarkScanPictureResultBlock)(NSString *result);


@interface QuikMarkScanPicture : UIViewController

@property (nonatomic, copy) QuikMarkScanPictureResultBlock quikMarkScanPictureResultBlock;

@end
