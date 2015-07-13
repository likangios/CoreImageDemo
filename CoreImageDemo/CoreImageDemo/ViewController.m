//
//  ViewController.m
//  CoreImageDemo
//
//  Created by 李康 on 15/7/3.
//  Copyright (c) 2015年 Luck. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{
    UIImageOrientation _orientation;
}
@property (nonatomic,strong) UIImagePickerController *imagePicker;

@property (nonatomic,strong) UIImageView *ImageView;

@property (nonatomic,strong) UIImage *originalImage;

//@property (nonatomic,strong) CIImage *image;

@property (nonatomic,strong) CIImage *outputImage;

@property (nonatomic,strong) CIContext *content;//上下文本

@property (nonatomic,strong) CIFilter *colorControlsFilter;//色彩滤镜

@property (nonatomic,strong) CIFilter *filter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *autoDeal2 = [[UIBarButtonItem alloc]initWithTitle:@"还原" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    
    UIBarButtonItem *autoDeal = [[UIBarButtonItem alloc]initWithTitle:@"自动处理" style:UIBarButtonItemStylePlain target:self action:@selector(autoDeal)];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    

    UIBarButtonItem *open = [[UIBarButtonItem alloc]initWithTitle:@"打开" style:UIBarButtonItemStylePlain target:self action:@selector(open)];
    
    self.navigationItem.rightBarButtonItems = @[save,autoDeal,autoDeal2];
    
    self.navigationItem.leftBarButtonItem = open;
    
    
    self.navigationController.hidesBarsOnTap = YES;
    
    
    _ImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 80, self.view.frame.size.width-80, 300)];
    _ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_ImageView];
    
    NSArray *array = @[@"怀旧",@"黑白",@"色调",@"岁月",@"单色",@"褪色",@"冲印",@"铬黄",];
    CGFloat butW = self.view.frame.size.width/array.count;
    CGFloat butH = 30.0;
    for (int i = 0; i<array.count; i++) {
        
        UIButton *but = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        but.center = CGPointMake(butW/2.0+i*butW, CGRectGetMaxY(_ImageView.frame)+20);
        but.bounds = CGRectMake(0, 0, butW-4, butH);
        [but setTitle:array[i] forState:UIControlStateNormal];
        but.titleLabel.adjustsFontSizeToFitWidth = YES;
        but.layer.cornerRadius =butH/2.0;
        but.tag = i+1;
        but.layer.borderColor = [UIColor blueColor].CGColor;
        [but addTarget:self action:@selector(butsClick:) forControlEvents:UIControlEventTouchUpInside];
        but.layer.borderWidth = 1.0;
        [self.view addSubview:but];
        
    }
    
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat leftSide = 50;

    NSArray *tit = @[@"原图",@"自动改善"];
    for (int i = 0; i<2; i++) {
        UIButton *but= [UIButton buttonWithType:UIButtonTypeCustom];
        but.frame = CGRectMake(50+i*120, height-200, 100, 40);
        [but setTitle:tit[i] forState:UIControlStateNormal];
        [but setBackgroundColor:[UIColor purpleColor]];
        [but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        but.titleLabel.adjustsFontSizeToFitWidth = YES;
        but.tag = 1<<i;
        [but addTarget:self action:@selector(butClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:but];
    }
    

    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(leftSide, height-150, width-leftSide-10, 20)];
    [slider addTarget:self action:@selector(slider:) forControlEvents:UIControlEventValueChanged];
    slider.minimumValue = 0;
    slider.maximumValue = 2;
    slider.value = 1;
    slider.tag = 11;
    [self.view addSubview:slider];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(slider.frame), leftSide, CGRectGetHeight(slider.frame))];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"饱和度";
    label.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:label];
    
    
    UISlider *slider2 = [[UISlider alloc]initWithFrame:CGRectMake(leftSide, height-100, width-leftSide-10, 20)];
    [slider2 addTarget:self action:@selector(slider2:) forControlEvents:UIControlEventValueChanged];
    slider2.minimumValue = -1;
    slider2.maximumValue = 1;
        slider2.tag = 12;
    slider2.value = 0;
    [self.view addSubview:slider2];

    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(slider2.frame), leftSide, CGRectGetHeight(slider2.frame))];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.adjustsFontSizeToFitWidth = YES;
    label2.text = @"亮度";
    [self.view addSubview:label2];
    
    UISlider *slider3 = [[UISlider alloc]initWithFrame:CGRectMake(leftSide, height-50, width-leftSide-10, 20)];
    [slider3 addTarget:self action:@selector(slider3:) forControlEvents:UIControlEventValueChanged];
    slider3.minimumValue = 0;
    slider3.maximumValue = 2;
    slider3.tag = 13;
    slider3.value = 1;
    [self.view addSubview:slider3];
    

    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(slider3.frame), leftSide, CGRectGetHeight(slider3.frame))];
    label3.textAlignment = NSTextAlignmentCenter;
        label3.adjustsFontSizeToFitWidth = YES;
    label3.text = @"对比度";
    [self.view addSubview:label3];
    
    _content = [CIContext contextWithOptions:nil];
    
    _colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)butsClick:(UIButton *)but{
    
    NSArray *filternames = @[@"CIPhotoEffectInstant",@"CIPhotoEffectNoir",@"CIPhotoEffectTonal",@"CIPhotoEffectTransfer",@"CIPhotoEffectMono",@"CIPhotoEffectFade",@"CIPhotoEffectProcess",@"CIPhotoEffectChrome",];
    
    _filter = [CIFilter filterWithName:filternames[but.tag-1]];
    
    [self outPutImage];
    
}
- (void)outPutImage{
    CIImage *inputimage = [CIImage imageWithCGImage:_originalImage.CGImage];
    
    [_filter setValue:inputimage forKey:kCIInputImageKey];
    
    CIImage *outciimage  =  _filter.outputImage;
    
  CGImageRef imageref =   [_content createCGImage:outciimage fromRect:outciimage.extent];
    
    _ImageView.image = [UIImage imageWithCGImage:imageref];
}
- (void)butClick:(UIButton *)but{
    if (but.tag == 1) {
//  原图
        _ImageView.image = _originalImage;

        
    }else{
//  自动改善
        
        CIImage *inputImage = [CIImage imageWithCGImage:_originalImage.CGImage];
        
        NSArray *filters =  inputImage.autoAdjustmentFilters;
        
        for (CIFilter *filter in filters) {
            
            [filter setValue:inputImage forKey:kCIInputImageKey];
            
            inputImage = filter.outputImage;
        }

        
    CIContext *context = [CIContext  contextWithOptions:nil];

    CGImageRef cgimg = [context createCGImage:inputImage fromRect:inputImage.extent];
        
        UIImage *image = [UIImage imageWithCGImage:cgimg
                          ];
        
        NSLog(@"output image.size %f %f",image.size.width,image.size.height);
        _ImageView.image = image;
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
    }
}

- (void)back{
    
    CIImage *img=  [CIImage imageWithCGImage:_originalImage.CGImage];
    
    [_colorControlsFilter setValue:img forKey:@"inputImage"];
    
    UISlider *slier = (UISlider *)[self.view viewWithTag:11];
    slier.value = 1;
    UISlider *slier2 = (UISlider *)[self.view viewWithTag:12];
    slier2.value = 0;
    UISlider *slier3 = (UISlider *)[self.view viewWithTag:13];
    slier3.value = 1;
    
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier.value] forKey:@"inputSaturation"];
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier2.value] forKey:@"inputBrightness"];
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier3.value] forKey:@"inputContrast"];
    [self setImage];

}
- (void)autoDeal{
    CIImage *img=  [CIImage imageWithCGImage:_originalImage.CGImage];
    [_colorControlsFilter setValue:img forKey:@"inputImage"];
    
    UISlider *slier = (UISlider *)[self.view viewWithTag:11];
    slier.value = 1.4;
    UISlider *slier2 = (UISlider *)[self.view viewWithTag:12];
    slier2.value = 0.03;
    UISlider *slier3 = (UISlider *)[self.view viewWithTag:13];
    slier3.value = 1.1;
    
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier.value] forKey:@"inputSaturation"];
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier2.value] forKey:@"inputBrightness"];
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slier3.value] forKey:@"inputContrast"];
    
    [self setImage];
    
}
- (void)setImage{
    
    CIImage *outputImage = [_colorControlsFilter outputImage];
    
    CGRect outRect = [outputImage extent];
    
    CGImageRef temp = [_content createCGImage:outputImage fromRect:outRect];
    
    UIImage *img = [UIImage imageWithCGImage:temp];
    
    UIImage *image = [UIImage imageWithCGImage:temp scale:1 orientation:_orientation];
    
    NSLog(@"image.size %f %f %d",image.size.width,image.size.height,image.imageOrientation);
    
    _ImageView.image = image;
    
    CGImageRelease(temp);
}
- (void)slider:(UISlider *)slider{
    
    NSLog(@"饱和度 %f",slider.value);
    
    dispatch_async(dis, <#^(void)block#>)
    CIImage *img=  [CIImage imageWithCGImage:_originalImage.CGImage];
    
    [_colorControlsFilter setValue:img forKey:@"inputImage"];
    
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputSaturation"];
    
    [self setImage];
}
- (void)slider2:(UISlider *)slider{
    NSLog(@"亮度 %f",slider.value);
    CIImage *img=  [CIImage imageWithCGImage:_originalImage.CGImage];
    
    [_colorControlsFilter setValue:img forKey:@"inputImage"];
    
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputBrightness"];
        [self setImage];
}
- (void)slider3:(UISlider *)slider{
    
     NSLog(@"对比度 %f",slider.value);
    CIImage *img=  [CIImage imageWithCGImage:_originalImage.CGImage];
    
    [_colorControlsFilter setValue:img forKey:@"inputImage"];
    
    [_colorControlsFilter setValue:[NSNumber numberWithFloat:slider.value] forKey:@"inputContrast"];
        [self setImage];
}
- (void)save{
    
    UIImageWriteToSavedPhotosAlbum(_ImageView.image, nil, nil, nil);
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"图片保存成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
- (void)open{
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
}
- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.allowsEditing = NO;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:NULL];
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    _originalImage = img;
    _orientation = img.imageOrientation;
    _ImageView.image = _originalImage;
    NSLog(@"image.size %f %f",img.size.width,img.size.height);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
