//
//  CZHChooseCoverController.m
//  saveCover
//
//  Created by 程召华 on 2017/10/30.
//  Copyright © 2017年 程召华. All rights reserved.
//
//底部显示的个数
#define PHOTP_COUNT  6

#import "CZHChooseCoverController.h"
#import <AVFoundation/AVFoundation.h>
#import "Header.h"
#import "CZHChooseCoverCell.h"

typedef NS_ENUM(NSInteger, CZHChooseCoverControllerButtonType) {
    //返回
    CZHChooseCoverControllerButtonTypeBack,
    //完成
    CZHChooseCoverControllerButtonTypeComplete
};
static NSString *const ID = @"CZHChooseCoverCell";
@interface CZHChooseCoverController ()<UICollectionViewDataSource>
///
@property (nonatomic, weak) UICollectionView *collectionView;
///图片显示
@property (nonatomic, weak) UIImageView *imageView;
///总帧数
@property (nonatomic, assign) CMTimeValue timeValue;
///比例
@property (nonatomic, assign) CMTimeScale timeScale;
///照片数组
@property (nonatomic, strong) NSMutableArray *photoArrays;
@end

@implementation CZHChooseCoverController

- (NSMutableArray *)photoArrays {
    if (!_photoArrays) {
        _photoArrays = [NSMutableArray array];
    }
    return _photoArrays;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZHColor(0x000000);
    
    [self getVideoTotalValueAndScale];
    
    [self setNavigationBar];
    
    [self setUpView];
}

- (void)getVideoTotalValueAndScale {
    
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
    
    long long baseCount = time.value / PHOTP_COUNT;
    //取出PHOTP_COUNT张图片,存放到数组，用于collectionview
    for (NSInteger i = 0 ; i < PHOTP_COUNT; i++) {
        
        NSError *error = nil;
        CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(i * baseCount, time.timescale) actualTime:NULL error:&error];
        {
            UIImage *image = [UIImage imageWithCGImage:img];
            
            [self.photoArrays addObject:image];
        }
    }
  
}



- (void)setUpView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, CZH_ScaleHeight(65), ScreenWidth, ScreenWidth);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ScreenWidth/PHOTP_COUNT, ScreenWidth/PHOTP_COUNT);
    layout.minimumInteritemSpacing = 0;
    
    CGRect collectionViewF = CGRectMake(0,  CZH_ScaleHeight(461), ScreenWidth, CZH_ScaleHeight(62.5));
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewF collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[CZHChooseCoverCell class] forCellWithReuseIdentifier:ID];
    [self.view addSubview:collectionView];
    self.collectionView  = collectionView;
    
    
    
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

    //手动选取一张
    [self chooseWithTime:0];
    

    
    CGFloat tipsLabelX = 0;
    CGFloat tipsLabelY = CZH_ScaleHeight(570);
    CGFloat tipsLabelW = ScreenWidth;
    CGFloat tipsLabelH = CZH_ScaleHeight(19);
    CGRect tipsLabelF = CGRectMake(tipsLabelX, tipsLabelY, tipsLabelW, tipsLabelH);
    UILabel *tipsLabel = [UILabel setLabelWithFrame:tipsLabelF font:CZHGlobelNormalFont(16) textColor:CZHColor(0xffffff) textAliment:NSTextAlignmentCenter text:@"优质的封面更能让大家喜欢哟"];
    [self.view addSubview:tipsLabel];
    
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArrays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CZHChooseCoverCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.coverImage = self.photoArrays[indexPath.item];
    return cell;
}


- (void)valueChange:(UISlider *)sender {
    
    int timeValue = sender.value;
    
    [self chooseWithTime:timeValue];
}


- (void)chooseWithTime:(CMTimeValue)time {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoPath options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    //    generator.maximumSize = CGSizeMake(ScreenWidth, ScreenHeight);
    
    
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(time, self.timeScale) actualTime:NULL error:&error];
    {
        UIImage *image = [UIImage imageWithCGImage:img];
        
        self.imageView.image = image;
    }
}


- (UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContext(self.collectionView.bounds.size);
    [self.collectionView drawViewHierarchyInRect:self.collectionView.bounds afterScreenUpdates:YES];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenshot;
}


- (void)setNavigationBar {
    
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = 20;
    CGFloat titleLabelW = ScreenWidth;
    CGFloat titleLabelH = 44;
    CGRect titleLabelF = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    UILabel *titleLabel = [UILabel setLabelWithFrame:titleLabelF font:CZHGlobelNormalFont(17) textColor:CZHColor(0xffffff) textAliment:NSTextAlignmentCenter text:@"设置封面"];
    [self.view addSubview:titleLabel];
    
    CGFloat backButtonX = CZH_ScaleWidth(7);
    CGFloat backButtonW = CZH_ScaleHeight(30);
    CGFloat backButtonH = CZH_ScaleHeight(30);
    CGFloat backButtonY = (44 - backButtonH) * 0.5 + 20;
    CGRect backButtonF = CGRectMake(backButtonX, backButtonY, backButtonW, backButtonH);
    UIButton *backButton = [UIButton czh_buttonWithTarget:self action:@selector(buttonClick:) frame:backButtonF imageName:@"back"];
    backButton.tag = CZHChooseCoverControllerButtonTypeBack;
    [self.view addSubview:backButton];
    
    
    
    CGFloat completeButtonW = CZH_ScaleHeight(55);
    CGFloat completeButtonH = 44;
    CGFloat completeButtonY = 20;
    CGFloat completeButtonX = ScreenWidth - completeButtonW;
    CGRect completeButtonF = CGRectMake(completeButtonX, completeButtonY, completeButtonW, completeButtonH);
    UIButton *completeButton = [UIButton czh_buttonWithTarget:self action:@selector(buttonClick:) frame:completeButtonF titleColor:CZHColor(0xffffff) titleFont:CZHGlobelNormalFont(17) title:@"完成"];
    completeButton.tag = CZHChooseCoverControllerButtonTypeComplete;
    [self.view addSubview:completeButton];
}



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



@end
