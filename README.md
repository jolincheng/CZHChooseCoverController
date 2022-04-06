# CZHChooseCoverController



![合成 1.gif](http://upload-images.jianshu.io/upload_images/6709174-f9c9f8667d18c705.gif?imageMogr2/auto-orient/strip)

###### 起初看到这个功能我是拒绝的，之前做的视频上传都是获取特定的帧数当封面，没有刻意的去选择封面，但是需求已定，随后网上也找了下，没有类似的，于是乎就自己写了一个，有什么改进的地方可以互相交流，话不多说直接上代码了

1.打开相册，系统相册用的很顺手，所以一直就用系统的相册
```
//两个代理
@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end
```
```
//代理方法
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
        //视频限制的长度
        NSUInteger limitTime = 30;
        if (videoTime > limitTime) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
            }
            //把系统相册mov格式转换成mp4格式
            [CZHTool convertMovTypeIntoMp4TypeWithSourceUrl:url convertSuccess:^(NSURL *path) {
            CZHStrongSelf(self);
            [picker dismissViewControllerAnimated:YES completion:nil];
            //选择封面控制器
            CZHChooseCoverController *chooseCover = [[CZHChooseCoverController alloc] init];
            //本地路径
            chooseCover.videoPath = path;
            //选择封面的block，把封面image回调
            chooseCover.coverImageBlock = ^(UIImage *coverImage) {
                self.coverImageView.image = coverImage;

                //上传视频操作
                //[self changeWithUploadSource:path];
                //上传封面操作
                //[self uploadCoverWithImage:coverImage];
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
```

2.选择封面控制器
```
//截取几张图片放在底部用作展示，我是用collectionview做展示
    AVURLAsset * asset = [AVURLAsset assetWithURL:self.videoPath];
    CMTime  time = [asset duration];
    self.timeValue = time.value;
    self.timeScale = time.timescale;
    if (time.value < 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }

    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoPath options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    /**The actual time of the generated images will be within the range [requestedTime-toleranceBefore, requestedTime+toleranceAfter] and may differ from the requested time for efficiency.
    Pass kCMTimeZero for both toleranceBefore and toleranceAfter to request frame-accurate image generation; this may incur additional decoding delay.
    Default is kCMTimePositiveInfinity.*/
    
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    //总帧数/展示的总数量
    long long baseCount = time.value / PHOTP_COUNT;
    //取出PHOTP_COUNT张图片,存放到数组，用于collectionview
    for (NSInteger i = 0 ; i < PHOTP_COUNT; i++) {

        NSError *error = nil;
            //每隔baseCount帧取一帧存起来,一共PHOTP_COUNT张
            CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(i * baseCount, time.timescale) actualTime:NULL error:&error];
        {
            UIImage *image = [UIImage imageWithCGImage:img];

            [self.photoArrays addObject:image];
        }
        ///释放内存
    CGImageRelease(img);
    }
```

```
//把存的存的几张图片用collectionview展示出来
    CGRect collectionViewF = CGRectMake(0,  CZH_ScaleHeight(461), ScreenWidth, CZH_ScaleHeight(62.5));
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewF collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[CZHChooseCoverCell class]    forCellWithReuseIdentifier:ID];
    [self.view addSubview:collectionView];
    self.collectionView  = collectionView;

    //在collectionview上面覆盖一个slider用于滑动选择图片
    UIImage *selected = [UIImage imageNamed:@"slider_select"];
    UIImage *deselected = [UIImage imageNamed:@"slider_deselect"];

    UISlider *slider = [[UISlider alloc] init];
    slider.frame = CGRectMake(0,  CZH_ScaleHeight(461), ScreenWidth, CZH_ScaleHeight(62.5));

    [slider setThumbImage:deselected forState:UIControlStateNormal];
    [slider setThumbImage:selected forState:UIControlStateHighlighted];
    //透明的图片
    UIImage *image = [CZHTool imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)];

    [slider setMinimumTrackImage:image forState:UIControlStateNormal];
    [slider setMaximumTrackImage:image forState:UIControlStateNormal];

    slider.maximumValue = self.timeValue;
    slider.minimumValue = 0;
    [slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];

    //默认选取第一帧展示
    [self chooseWithTime:0];

```

```
//滑动slider的操作
- (void)valueChange:(UISlider *)sender {

    int timeValue = sender.value;

    [self chooseWithTime:timeValue];
}


- (void)chooseWithTime:(CMTimeValue)time {

    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoPath options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    /**The actual time of the generated images will be within the range [requestedTime-toleranceBefore, requestedTime+toleranceAfter] and may differ from the requested time for efficiency.
    Pass kCMTimeZero for both toleranceBefore and toleranceAfter to request frame-accurate image generation; this may incur additional decoding delay.
    Default is kCMTimePositiveInfinity.*/
    
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;


    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(time, self.timeScale) actualTime:NULL error:&error];
    {
        UIImage *image = [UIImage imageWithCGImage:img];

        self.imageView.image = image;
    }
    ///释放内存
    CGImageRelease(img);
}

```

```
//点击返回按钮和完成按钮的操作
- (void)buttonClick:(UIButton *)sender {
    if (sender.tag == CZHChooseCoverControllerButtonTypeBack) {
        [self dismissViewControllerAnimated:YES completion:nil];
        } else if (sender.tag == CZHChooseCoverControllerButtonTypeComplete) {
            //封面图片回调
        if (_coverImageBlock) {
            _coverImageBlock(self.imageView.image);
        }
    [self dismissViewControllerAnimated:YES completion:nil];
    }
}
```


ps.模拟器相册没有视频的话可以用下面代码把项目的视频保存到相册
```
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
```

[更多查看blog](http://blog.csdn.net/HurryUpCheng)
