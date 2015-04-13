//
//  GeschwindViewController.m
//  Geschwind
//
//  Created by Beni Cheni on 4/9/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import "GeschwindViewController.h"

@interface GeschwindViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *searchPhrase;

@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation GeschwindViewController

#pragma mark - UIViewController

- (void)loadView {
    [self loadViewComponents:self];
}

- (void) loadViewComponents:(GeschwindViewController *)appViewController {
    appViewController.textField = [UITextField new];
    appViewController.textField.keyboardType = UIKeyboardTypeURL;
    appViewController.textField.returnKeyType = UIReturnKeyDone;
    appViewController.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    appViewController.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    appViewController.textField.placeholder = NSLocalizedString(@"Website URL or Search Keyword(s)", @"Placeholder text for web browser URL field");
    appViewController.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    [appViewController.textField setKeyboardType:UIKeyboardTypeWebSearch];
    appViewController.textField.delegate = appViewController;
    
    appViewController.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.backButton setEnabled:NO];
    appViewController.forwardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.forwardButton setEnabled:NO];
    appViewController.stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.stopButton setEnabled:NO];
    appViewController.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [appViewController.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Back comnmand") forState:UIControlStateNormal];
    [self.forwardButton setTitle:NSLocalizedString(@"Forward", @"Forward comnmand") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop comnmand") forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"Refresh", @"Reload comnmand") forState:UIControlStateNormal];

    [self updateButtons];
    
    appViewController.webview = [UIWebView new];
    appViewController.webview.delegate = appViewController;
    UIView *mainView = [UIView new];
    
    [@[appViewController.webview,
       appViewController.textField,
       appViewController.backButton,
       appViewController.forwardButton,
       appViewController.stopButton,
       appViewController.reloadButton]
           enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [mainView addSubview:(UIView *) obj];
     }];
    
    appViewController.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // Make the webview fill the main view.
    self.webview.frame = self.view.frame;
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight - itemHeight; // top 50, bottom 50 CGFloat units
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) / 4;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat currentButton = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        thisButton.frame = CGRectMake(currentButton, CGRectGetMaxY(self.webview.frame), buttonWidth, itemHeight);
        currentButton += buttonWidth;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSMutableString *URLString = [NSMutableString string];
    NSArray *keywords = [textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    keywords = [keywords filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    
    NSUInteger keywordCount = [keywords count];
    
    for (int i = 0; i < keywordCount; i++) {
        [URLString appendString: (NSString *) keywords[i]];
        
        if ((keywordCount - i) != 1) {  // Upper bound of array - index == 1 when the item is the last one in the array.
            [URLString appendString:@"+"];
        }
    }
    
    self.searchPhrase = [NSString stringWithString:URLString];  // This search phrase is not used if a valid web address is given to the browser.
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (!URL.scheme) {
            URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self resetButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self resetButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != -999) {
        if ([self.textField.text length] == 0) {
            [self popAlert:error errorMessage:NSLocalizedString(@"Empty URL", @"Empty URL")];
        } else {
            // Change the logic that when a target page encounters error code other than -999, the code redirect to google search.
            NSString *urlString = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", self.searchPhrase];
            NSURL *googleSearchURL = [NSURL URLWithString:urlString];
            
            if (googleSearchURL) {
                NSURLRequest *request = [NSURLRequest requestWithURL:googleSearchURL];
                [self.webview loadRequest:request];
            }
        }
    }
    
    self.frameCount--;
    [self resetButtonsAndTitle];
}

#pragma mark - Miscellaneous

- (void)popAlert:(NSError *)error errorMessage:(NSString *)message {
    // UIAlertView is deprecated in iOS8. Use UIAlertController instead
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [UIWebView new];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    self.textField.text = nil;
    [self resetButtonsAndTitle];
}

- (void)resetButtonsAndTitle {
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    self.frameCount > 0 ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
    [self updateButtons];
}

- (void)updateButtons {
    [self updateButtonOnTheGo:self.backButton isActionValid:[self.webview canGoBack] actionType:@"goBack"];
    [self updateButtonOnTheGo:self.forwardButton isActionValid:[self.webview canGoForward] actionType:@"goForward"];
    [self updateButtonOnTheGo:self.stopButton isActionValid:self.frameCount > 0 actionType:@"stopLoading"];
    [self updateButtonOnTheGo:self.reloadButton isActionValid:self.webview.request.URL
     && self.frameCount == 0 actionType:@"reload"];
}

- (void)updateButtonOnTheGo:(UIButton *) button isActionValid:(BOOL) validFlag actionType: type {
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    if (validFlag) {
        if ([type isEqualToString:@"goBack"]) {
            [button addTarget:self.webview action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        } else if ([type isEqualToString:@"goForward"]) {
            [button addTarget:self.webview action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
        } else if ([type isEqualToString:@"stopLoading"]) {
            [button addTarget:self.webview action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
        } else if ([type isEqualToString:@"reload"]) {
            [button addTarget:self.webview action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.enabled = YES;
    } else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.enabled = NO;
    }
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
