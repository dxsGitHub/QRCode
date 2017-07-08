//
//  ViewController.m
//  QRCode
//
//  Created by dxs on 2017/7/7.
//  Copyright © 2017年 dxs. All rights reserved.
//

#import "ViewController.h"

#import "QuickMark.h"
#import "QuickMarkGenerate.h"
#import "QuikMarkScanPicture.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLab;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong, nonatomic) QuikMarkScanPicture *qmPic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码";
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)scanQRcodeBtnClickAction:(UIButton *)sender {
    QuickMark *controller = [[QuickMark alloc] init];
    controller.quickMarkResultBlock = ^(AVMetadataMachineReadableCodeObject *resultObj) {
        _resultLab.text = resultObj.stringValue;
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)identifyQRcodeBtnClickAction:(UIButton *)sender {
    _qmPic = [[QuikMarkScanPicture alloc] init];
    __weak UILabel *logLab = _resultLab;
    _qmPic.quikMarkScanPictureResultBlock = ^(NSString *result) {
        logLab.text = result;
    };
}

- (IBAction)normalQRcodeBtnClickAction:(UIButton *)sender {
    _resultImageView.image = [QuickMarkGenerate generateWithDefaultQRCodeData:@"邓小帅--QRCode" imageViewWidth:_resultImageView.frame.size.width];
}

- (IBAction)imageQRcodeBtnClickAction:(UIButton *)sender {
    _resultImageView.image = [QuickMarkGenerate generateLogoQRCodeWithData:@"邓小帅--QRCode" logoImageName:@"QuickMark.bundle/logo.jpg" logoScaleToSuperView:0.26f];
}

- (IBAction)colorQRcodeBtnClickAction:(UIButton *)sender {
    _resultImageView.image = [QuickMarkGenerate generateQRCodeWithData:@"邓小帅--QRCode" mainCodeColor:[UIColor blackColor] backgroundColor:[UIColor redColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
