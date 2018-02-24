//
//  ViewController.m
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CZHTool.h"
#import "Header.h"
#import "CZHChooseCoverController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    

    
}
//打开相册
- (IBAction)openAlbum:(id)sender {
    
    [self openImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
    
}


//打开相册
- (void)openImagePickerController:(UIImagePickerControllerSourceType)type
{
    if (![UIImagePickerController isSourceTypeAvailable:type]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    //视频最大时间
    ipc.videoMaximumDuration = 30;
    
    ipc.view.backgroundColor = [UIColor whiteColor];
    ipc.sourceType = type;
    ipc.delegate = self;
    //只打开视频
    ipc.mediaTypes = @[(NSString *)kUTTypeMovie];

    //视频上传质量
    ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentViewController:ipc animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
/**
 * 从UIImagePickerController选择完图片后就调用（拍照完毕或者选择相册图片完毕）
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    CZHWeakSelf(self);
   
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        //如果是视频
        NSURL *url = info[UIImagePickerControllerMediaURL];

        //计算相册视频时长
        NSDictionary *videoDic = [CZHTool getLocalVideoSizeAndTimeWithSourcePath:url.absoluteString];

        int videoTime = [[videoDic valueForKey:@"duration"] intValue];

        NSUInteger limitTime = 30;
        if (videoTime > limitTime) {
            
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [CZHTool convertMovTypeIntoMp4TypeWithSourceUrl:url convertSuccess:^(NSURL *path) {
            CZHStrongSelf(self);
            [picker dismissViewControllerAnimated:YES completion:nil];


            CZHChooseCoverController *chooseCover = [[CZHChooseCoverController alloc] init];
            chooseCover.videoPath = path;
            chooseCover.coverImageBlock = ^(UIImage *coverImage) {
                
                self.coverImageView.image = coverImage;
                
                //上传视频
//                [self changeWithUploadSource:path];
//                //上传封面
//                [self uploadCoverWithImage:coverImage];
            };
            [self presentViewController:chooseCover animated:YES completion:nil];

        }];

    }
}

// 取消图片选择调用此方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // dismiss UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
}



//保存本地视频到相册
- (IBAction)saveVideoToAlbum:(id)sender {


    NSMutableArray *videoArray = [NSMutableArray array];
    //工程中类型是MP4的文件数组
    NSArray *movs = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp4" inDirectory:nil];
    [videoArray addObjectsFromArray:movs];
    for (id item in videoArray) {
        //循环保存到相册
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(item)) {
            UISaveVideoAtPathToSavedPhotosAlbum(item, self, nil, NULL);
        }
    }
}

- (void)saveAction
{
    
} 

@end
