//
//  TestViewController.m
//  CoreImageDemo
//
//  Created by 李康 on 15/7/17.
//  Copyright (c) 2015年 Luck. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc]init];
    view.layer.borderColor = [UIColor purpleColor].CGColor;
    view.layer.borderWidth = 3.0;
    view.backgroundColor = [UIColor greenColor];
    view.center = CGPointMake(self.view.frame.size.width/2.0, 200);
    view.bounds = CGRectMake(0, 0, 250, 250);
    view.layer.cornerRadius = view.frame.size.width/2.0;
    [self.view addSubview:view];

    UIImageView *imageview = [[UIImageView alloc]init];
    imageview.image = [UIImage imageNamed:@"image.png"];
    imageview.bounds = CGRectMake(0, 0, 120, 200);
    imageview.tag   =  100;
    imageview.center = CGPointMake(view.frame.size.width/2.0, view.frame.size.height/2.0);
    [view addSubview:imageview];
    

    
    CABasicAnimation *translation = [self rotation:1 degree:M_PI_2 direction:1 repeatCount:0];
    
    CABasicAnimation *translation1 = [self rotation:8 degree:0 direction:1 repeatCount:0];

    
//    CABasicAnimation *translatio2 = [self scale:@1.2 orgin:@1 durTimes:1 Rep:0];

//    CABasicAnimation *translation2 = [self rotation:1.5 degree:-M_PI_2 direction:1 repeatCount:1];

    
//    CABasicAnimation *translation3 = [self rotation:0.8 degree:M_PI_4 direction:1 repeatCount:1];

    
//    CABasicAnimation *translation4 = [self rotation:1.0 degree:-M_PI_4 direction:1 repeatCount:1];
    
    
//    CABasicAnimation *translation5 = [self rotation:1.2 degree:0 direction:1 repeatCount:1];

    
    CAAnimationGroup *group = [self groupAnimation:@[translation,translation1] durTimes:8 Rep:MAX_INPUT];
    
    [imageview.layer addAnimation:group forKey:nil];
    

    // Do any additional setup after loading the view.
}
-(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repeatTimes
//／／缩放
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=orginMultiple;
    animation.toValue=Multiple;
    animation.duration=time;

    animation.autoreverses=YES;
    animation.repeatCount=repeatTimes;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}


-(CAAnimationGroup *)groupAnimation:(NSArray *)animationAry durTimes:(float)time Rep:(float)repeatTimes
//／／组合动画
{
    CAAnimationGroup *animation=[CAAnimationGroup animation];
    animation.animations=animationAry;
    animation.duration=time;
    animation.repeatCount=repeatTimes;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    return animation;
}
-(CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount
//／／旋转
{
    CATransform3D rotationTransform  = CATransform3DMakeRotation(degree, 0, 0,direction);
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue= [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration= dur;
    animation.speed = 2.0;
    animation.autoreverses= NO;
    animation.cumulative= YES;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.repeatCount= repeatCount;
    animation.delegate= self;
    
    return animation;
}
- (void)animation{
    UIImageView *imageview=(UIImageView *)[self.view viewWithTag:100];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    imageview.transform = CGAffineTransformRotate(imageview.transform, M_PI_4);
    [UIView commitAnimations];
    
    
//
    [UIView animateWithDuration:0.5 animations:^{
        
        imageview.transform = CGAffineTransformRotate(imageview.transform, M_PI_4);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            
            imageview.transform = CGAffineTransformRotate(imageview.transform, -M_PI_2);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                
                imageview.transform = CGAffineTransformRotate(imageview.transform, M_PI_4);
                
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始摇动手机");
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"stop");
    UIAlertView *yaoyiyao = [[UIAlertView alloc]initWithTitle:@"温馨提示：" message:@"您摇动了手机，想干嘛？" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles: nil];
    [yaoyiyao show];
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
