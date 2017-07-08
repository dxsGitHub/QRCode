# QRCode
#引入：把QuickMark文件夹导入到工程中


#扫码：1，包含头文件#import "QuickMark.h"
#     2，在需要扫码的用户操作动作中添加如下代码
#    {
#     QuickMark *controller = [[QuickMark alloc] init];
#     controller.quickMarkResultBlock = ^(AVMetadataMachineReadableCodeObject *resultObj) {
#           //_resultLab.text = resultObj.stringValue;
#           //获取到的二维码信息
#     };
#   }


#识别图中二维码：1，包含头文件#import "QuikMarkScanPicture.h"
#             2，在需要识别二维码的用户操作动作中添加如下代码
            {
#            QuikMarkScanPicture *qmPic = [[QuikMarkScanPicture alloc] init];
#            qmPic.quikMarkScanPictureResultBlock = ^(NSString *result) {
#                  // logLab.text = result;
#                  //获取到的二维码信息
#             };
#           }


#生成二维码：生成普通二维码， 生成带logo的二维码， 生成彩色二维码 （注意：生成带logo二维码的时候logoScaleToSuperView要小于0.3f）
#- (IBAction)normalQRcodeBtnClickAction:(UIButton *)sender {
#    _resultImageView.image = [QuickMarkGenerate generateWithDefaultQRCodeData:@"邓小帅--QRCode" imageViewWidth:_resultImageView.frame.size.width];
#}

#- (IBAction)imageQRcodeBtnClickAction:(UIButton *)sender {
#    _resultImageView.image = [QuickMarkGenerate generateLogoQRCodeWithData:@"邓小帅--QRCode" logoImageName:@"QuickMark.bundle/logo.jpg" logoScaleToSuperView:0.26f];
#}

#- (IBAction)colorQRcodeBtnClickAction:(UIButton *)sender {
#    _resultImageView.image = [QuickMarkGenerate generateQRCodeWithData:@"邓小帅--QRCode" mainCodeColor:[UIColor blackColor] backgroundColor:[UIColor redColor]];
#}

