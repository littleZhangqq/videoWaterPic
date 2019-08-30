//
//  FilterEffectViewController.m
//  MovieWaterPic
//
//  Created by admin on 2019/8/30.
//  Copyright © 2019 admin. All rights reserved.
//

#import "FilterEffectViewController.h"
#import "Masonry.h"
#import "GPUImage.h"

#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

@interface FilterEffectViewController ()

@property (nonatomic, unsafe_unretained) FilterEffectType type;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageVideoCamera *camera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) GPUImageMovieWriter *writer;
@property (nonatomic, strong) NSArray *filterArray;

@end

@implementation FilterEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filterArray = @[@"高斯模糊",@"边缘模糊",@"素描",@"卡通",@"马赛克",@"暗角",@"黑白画面",@"旋涡",@"哈哈镜",@"图形倒立",@"同心圆像素",@"浮雕效果",@"正常"];
    self.type = Normal;
    [self createMainView];
}

-(void)createMainView{
    UIScrollView *scv = [[UIScrollView alloc] init];
    scv.alwaysBounceHorizontal = YES;
    scv.showsHorizontalScrollIndicator = NO;
    scv.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:scv];
    
    [scv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(150);
    }];
    
    UIView *contain = [UIView new];
    [scv addSubview:contain];
    
    [contain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.height.mas_equalTo(scv);
    }];
    
    UIButton *lastButton;
    for (NSInteger i = 0; i<_filterArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.backgroundColor = [UIColor orangeColor];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [contain addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(contain);
            make.left.equalTo(contain.mas_left).offset(100*i);
            make.width.mas_equalTo(80);
        }];
        
        UIImageView *imv = [[UIImageView alloc] init];
        imv.backgroundColor = [UIColor purpleColor];
        imv.layer.cornerRadius = 30;
        imv.layer.masksToBounds = YES;
        [btn addSubview:imv];
        
        [imv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 60));
            make.centerX.mas_equalTo(btn);
            make.top.mas_equalTo(20);
        }];
        
        UILabel *text = [[UILabel alloc] init];
        text.font = [UIFont systemFontOfSize:13];
        text.textColor = [UIColor whiteColor];
        text.text = _filterArray[i];
        [btn addSubview:text];
        
        [text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(btn);
            make.top.mas_equalTo(imv.mas_bottom).offset(15);
        }];
        
        lastButton = btn;
    }
    
    [contain mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastButton);
    }];
}

-(void)filterButtonClick:(UIButton *)sender{
    sender.selected = YES;
    for (NSInteger i = 0; i<_filterArray.count; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:1000+i];
        if (i != sender.tag-1000) {
            btn.selected = NO;
        }
    }
    self.type = sender.tag - 1000;
}

- (void)setType:(FilterEffectType)type{
    if (_type == type) {
        return;
    }
    
    _type = type;
    switch (_type) {
        case GaussiBlurt:
            _filter = [[GPUImageGaussianBlurFilter alloc] init];
            [(GPUImageGaussianBlurFilter *)_filter setTexelSpacingMultiplier:2];
            [(GPUImageGaussianBlurFilter *)_filter setBlurRadiusInPixels:4];
            break;
        case RGBDilation:
            _filter = [[GPUImageRGBDilationFilter alloc] initWithRadius:4];
            break;
        case Sketch:
            _filter = [[GPUImageSketchFilter alloc] init];
            break;
        case Cartoon:
            _filter = [[GPUImageToonFilter alloc] init];
            [(GPUImageToonFilter *)_filter setQuantizationLevels:7];
            [(GPUImageToonFilter *)_filter setThreshold:1.5];
            break;
        case Masaic:
            _filter = [[GPUImagePixellatePositionFilter alloc] init];
            break;
        case DarkCorner:
            _filter = [[GPUImageVignetteFilter alloc] init];
            break;
        case ColorPacking:
            _filter = [[GPUImageColorPackingFilter alloc] init];
            break;
        case Swirl:
            _filter = [[GPUImageSwirlFilter alloc] init];
            [(GPUImageSwirlFilter *)_filter setRadius:0.75];
            [(GPUImageSwirlFilter *)_filter setAngle:0.35];
            break;
        case Distortion:
            _filter = [[GPUImageStretchDistortionFilter alloc] init];
            break;
        case Refraction:
            _filter = [[GPUImageSphereRefractionFilter alloc] init];
            [(GPUImageSphereRefractionFilter *)_filter setRadius:0.5];
            break;
        case CirclePixel:
            _filter = [[GPUImagePolarPixellateFilter alloc] init];
            [(GPUImagePolarPixellateFilter *)_filter setPixelSize:CGSizeMake(0.02, 0.02)];
            break;
        case Emboss:
            _filter = [[GPUImageEmbossFilter alloc] init];
            [(GPUImageEmbossFilter *)_filter setIntensity:2.5];
            break;
        case Normal:
            _filter = [[GPUImageFilter alloc] init];
            break;
        default:
            break;
    }
    [_writer finishRecording];
    [_filter removeTarget:_writer];
    [self initCamera];
}

-(void)initCamera{
    [self.camera addTarget:self.filter];
    
    _filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-150)];
    _filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:_filterView];
    [self.filter addTarget:_filterView];
    
    [self.camera startCameraCapture];
    
    NSString *fileName = [NSString stringWithFormat:@"video_%ld",time(NULL)];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Movie_%@.mp4",fileName]];
    unlink([pathToMovie UTF8String]);
    NSURL * movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    _writer.encodingLiveVideo = YES;
    _writer.shouldPassthroughAudio = YES;//是否使用源音源
    self.camera.audioEncodingTarget = _writer;//加入声音
    [self.filter addTarget:_writer];
    __weak typeof(self) weakSelf = self;
    dispatch_after(0.1, dispatch_get_main_queue(), ^(void){
        [weakSelf.writer startRecording];
    });
}

- (GPUImageVideoCamera *)camera{
    if (!_camera) {
        _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = YES;
        _camera.horizontallyMirrorRearFacingCamera = NO;
    }
    return _camera;
}



@end
