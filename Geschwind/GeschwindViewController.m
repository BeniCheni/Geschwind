//
//  GeschwindViewController.m
//  Geschwind
//
//  Created by Beni Cheni on 4/9/15.
//  Copyright (c) 2015 Princess of Darkness Factory. All rights reserved.
//

#import "GeschwindViewController.h"
#import "FloatingToolbar.h"

@interface GeschwindViewController () <UIWebViewDelegate, UITextFieldDelegate, FloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) FloatingToolbar *toolbar;
@property (nonatomic, strong) NSString *searchPhrase;

@property (nonatomic, assign) NSUInteger frameCount;

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

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
    
    self.toolbar = [[FloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.toolbar.delegate = self;
    
    appViewController.webview = [UIWebView new];
    appViewController.webview.delegate = appViewController;
    UIView *mainView = [UIView new];
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.toolbar]) {
        [mainView addSubview:(UIView *) viewToAdd];
     };
    
    appViewController.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
                                                    message:NSLocalizedString(@"Geschwind is fast in German. Get excited to use the best web browser ever!", @"Welcome comment")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") otherButtonTitles:nil];
    [alert show];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    // Make the webview fill the main view.
    self.webview.frame = self.view.frame;
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    self.toolbar.frame = CGRectMake(135, 30, 280, 60);
}

#pragma mark - FloatToolbarDelegate

- (void)floatingToolbar:(FloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if([title isEqual:kWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqual:kWebBrowserForwardString]) {
        [self.webview goForward];
    } else if ([title isEqual:kWebBrowserStopString]) {
        [self.webview stopLoading];
    } else if ([title isEqual:kWebBrowserRefreshString]) {
        [self.webview reload];
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
    
    [self.toolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.toolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.toolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kWebBrowserStopString];
    [self.toolbar setEnabled:[self.webview.request.URL.absoluteString length] > 0
        && self.frameCount == 0 forButtonWithTitle:kWebBrowserRefreshString];
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
