//
//  QuikMarkScanPicture.m
//  ShareView
//
//  Created by dxs on 2017/5/23.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import <Photos/Photos.h>
#import "QuikMarkScanPicture.h"
#import <AVFoundation/AVFoundation.h>
#import<AssetsLibrary/AssetsLibrary.h>

@interface QuikMarkScanPicture ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation QuikMarkScanPicture

- (instancetype)init {
    if (self = [super init]) {
        [self readImageFromPhotoLibrary];
    }
    return self;
}

- (void)readImageFromPhotoLibrary {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0f) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            __weak QuikMarkScanPicture *weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // 用户第一次同意了访问相册权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
                        [imagePicker setDelegate:weakSelf];
                        [[weakSelf getCurrentVC] presentViewController:imagePicker animated:YES completion:nil];
                    });
                } else { // 用户第一次拒绝了访问相机权限
                    NSString *message = [NSString stringWithFormat:@"请去-> [设置 - 隐私 - 相机 - %@]", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
                    [weakSelf presentAlertViewControllerWithMessage:message confirmAction:YES cancelAction:YES];
                }
            }];
            
        } else if (status == PHAuthorizationStatusAuthorized) {
            // 用户允许当前应用访问相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.editing = YES;
            //（选择类型）表示仅仅从相册中选取照片
            [imagePicker setDelegate:self];
            [[self getCurrentVC] presentViewController:imagePicker animated:YES completion:nil];
            
        } else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) { // 用户拒绝当前应用访问相册
            NSString *message = [NSString stringWithFormat:@"请去-> [设置 - 隐私 - 相机 - %@]", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
            [self presentAlertViewControllerWithMessage:message confirmAction:YES cancelAction:YES];
            
        }
    } else {
        //此处小于9.0版本的打开相册授权代码
    }
}


- (void)presentAlertViewControllerWithMessage:(NSString *)message confirmAction:(BOOL)confirm cancelAction:(BOOL)cancel {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:cancelAction];
    }
    if (confirm) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        
        [alertVC addAction:confirmAction];
    }
    [[self getCurrentVC] presentViewController:alertVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
     UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - - - 从相册中识别二维码, 并进行界面跳转
- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理    
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        self.quikMarkScanPictureResultBlock(feature.messageString);
    }
}

//获取当前显示的控制器
- (UIViewController *)getCurrentVC {
    
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if (window.windowLevel != UIWindowLevelNormal) {
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for(UIWindow * tmpWin in windows) {
            
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
    
}

@end
