//
//  ViewController.m
//  4Loader
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import "ViewController.h"
#import "ASyncURLConnection.h"
#import "SmallView.h"
#import "ActivityAlert.h"

#define MAX_VIEWS 4

@interface ViewController ()
{
    NSURLCache *downloadCache;
    NSMutableArray *viewArray;
}

@property (assign, nonatomic) float timeoutValue;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timeoutValue = 30.0;
    
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue addObserver:self forKeyPath:@"operations"
                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                    context:NULL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"PrivateDocuments"];
    
    NSURL *docURL = [NSURL fileURLWithPath:documentsDirectory isDirectory:NO];
    NSString *cacheName = [NSString stringWithFormat:@"%@.cache", @"download" ];
    docURL = [docURL URLByAppendingPathComponent:cacheName];
    NSString *fileName = [docURL absoluteString];
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    
    downloadCache = [[NSURLCache alloc] initWithMemoryCapacity:100000000 diskCapacity:100000000 diskPath:fileName];
    [NSURLCache setSharedURLCache:downloadCache];
    
    //NSLog(@"Views: %@", [[self view] subviews]);
    
    NSUInteger smallViewIndex = [[[self view] subviews] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj respondsToSelector:@selector(progressView)])
            *stop = YES;

        return *stop;
    }];
    
    NSLog(@"First View: %@", [[self view] subviews][smallViewIndex]);
    SmallView *smallView = [[self view] subviews][smallViewIndex];
    self.lastSelectedView = smallView;
    
    viewArray = [[NSMutableArray alloc] init];
    
    for (int i = smallViewIndex; i < MAX_VIEWS + smallViewIndex; i++) {
        smallView = [[self view] subviews][i];
        
        [smallView initializeView];
        [smallView setDelegate:self];
        
        [viewArray addObject:smallView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (IBAction)goButton:(id)sender {
    
    //NSURL *url = [NSURL URLWithString:@"http://upload.wikimedia.org/wikipedia/commons/0/0c/GoldenGateBridge-001.jpg"];
    
    NSString *url1 = @"http://upload.wikimedia.org/wikipedia/commons/0/0c/GoldenGateBridge-001.jpg";
    
    NSString *url2 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Transamerica_building_san_francisco.jpg/682px-Transamerica_building_san_francisco.jpg";
    
    NSString *url3 = @"http://www.evolvernetwork.org/wp-content/uploads/2012/07/san-francisco.jpg";
    
    NSString *url4 = @"http://ist1-4.filesor.com/pimpandhost.com/3/4/4/6/34462/Z/N/f/G/ZNfG/sf25.jpg";
    
    NSString *url = @"http://images.apple.com/ipad/overview/images/hero_slide1.png";
    
    
    if ([self.urlTextField.text isEqualToString:[NSString string]] || ![self.urlTextField.text isEqualToString:@""])
        
        switch (self.lastSelectedView.tag) {
                
            case 1:
                url = url1;
                break;
                
            case 2:
                url = url2;
                break;
                
            case 3:
                url = url3;
                break;
                
            case 4:
                url = url4;
                break;
                
        }
    else {
        url = self.urlTextField.text;
    }
    
    [self.urlTextField resignFirstResponder];
    
    self.progressView.progress = 0;
    
    
     DownloadOperation *newOperation = [[DownloadOperation alloc] initWithLastSelectedView:self.lastSelectedView
                                                                                 urlString:url delegate:self];
    newOperation.timeoutValue = self.timeoutValue;
    
    [newOperation addObserver:self forKeyPath:@"isFinished"
                      options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                      context:NULL];
    [newOperation addObserver:self forKeyPath:@"isExecuting"
                      options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                      context:NULL];
    
    // The operation manages its own timeOut timer.
    [self.queue addOperation:newOperation];
    
}

- (IBAction)clearButton:(id)sender
{
    self.urlTextField.text = @"";
    [self.urlTextField resignFirstResponder];
    
    [downloadCache removeAllCachedResponses];
    
    [self clearViews];
    
    if (self.timeoutValue != 30.0) {
        [[self class] activityAlertAction:@"Timeout reset to 30 seconds"];
    }
    self.timeoutValue = 30.0;
}

- (IBAction)timeoutButton:(id)sender
{
    [[self class] activityAlertAction:@"Timeout is set to 5 seconds"];
    self.timeoutValue = 5.0;
}

- (void)clearViews
{
    for (SmallView *smallView in viewArray) {
        smallView.imageView.image = nil;
        smallView.progressView.progress = 0;
    }
}

+ (void)activityAlertFinish
{
    [ActivityAlert dismiss];
}

+ (void)activityAlertHalfway
{
    [ActivityAlert setMessage:@"OK!"];
}

+ (void)activityAlertAction: (id) sender
{
    //float amount = 0.0f;
    [ActivityAlert presentWithText:sender];
    [[self class] performSelector:@selector(activityAlertFinish) withObject:nil afterDelay:1.5f];
    [[self class] performSelector:@selector(activityAlertHalfway) withObject:nil afterDelay:0.75f];
}


#pragma mark - SmallViewDelegate Methods

- (void)viewWasSelected:(SmallView *)smallView withNumberOfTaps:(NSInteger)tapCount
{
    self.lastSelectedView = smallView;
}

#pragma mark - DownloadOperationDelegate Methods

- (void)connectionUpdateInBytes:(NSUInteger)current forMaxBytes:(NSUInteger)max forView:(UIView *)aView
{
    ((SmallView *)aView).progressView.progress = (float)current / (float)max;
    
    //NSLog(@"Thead = %@: Appending data: bytes = %u / %u", [NSThread currentThread], current, max);
    if (current == max) {
        //        NSLog(@"Cache = %@", downloadCache);
        //        NSLog(@"Memory Usage = %u", [downloadCache currentMemoryUsage]);
        //        NSLog(@"Memory Capacity = %u", [downloadCache memoryCapacity]);
        //        NSLog(@"Disk Usage = %u", [downloadCache currentDiskUsage]);
        //        NSLog(@"Disk Capacity = %u", [downloadCache diskCapacity]);
        
    }
    
}

- (void)downloadComplete:(NSData *)data forView:(UIView *)aView
{
    ((SmallView *)aView).imageView.image = [UIImage imageWithData:data];
}

- (void)timeoutOccuredForView:(UIView *)aView
{
    [[self class] showAlert:@"Timeout" withMessage:[NSString stringWithFormat:@"in quadrant %u.", ((SmallView *)aView).tag]];
}


#pragma mark - KVO Method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];

}

#pragma mark - Utility Methods

+ (void)showAlert:(NSString *)theTitle withMessage:(NSString *)theMessage
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:theTitle
                                                 message:theMessage
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}




@end
