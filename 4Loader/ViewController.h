//
//  ViewController.h
//  4Loader
//
//  Created by waveOcean Software on 2/12/13.
//  Copyright (c) 2013 vincemansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASyncURLConnection.h"
#import "SmallView.h"
#import "DownloadOperation.h"

@interface ViewController : UIViewController <SmallViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) SmallView *lastSelectedView;

@property (strong, nonatomic) NSOperationQueue *queue;


- (IBAction)goButton:(id)sender;
- (IBAction)clearButton:(id)sender;
- (IBAction)timeoutButton:(id)sender;


@end
