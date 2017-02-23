//
//  TermsViewController.m
//  SportWorldPassport
//
//  Created by developer on 31/08/16.
//  Copyright © 2016 UWP. All rights reserved.
//

#import "TermsViewController.h"
#import "SignUpOneViewController.h"

@interface TermsViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.isWhat){
        [_lblTitle setText:@"TWP"];
        NSString *url = @"http://www.travelworldpassport.com/";
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
        NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSStringEncodingConversionAllowLossy  error:nil];
        [_webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPressBack:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
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
