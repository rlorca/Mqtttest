//
//  CLPConnectViewController.m
//  Mqttest
//
//  Created by Rodrigo Lorca on 15/05/14.
//  Copyright (c) 2014 Clops. All rights reserved.
//

#import "CLPConnectViewController.h"

#import "CLPChatViewController.h"

@interface CLPConnectViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nickField;

@end

@implementation CLPConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nickField.delegate = self;
    
    self.nickField.text = [[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:6];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"connect"])
    {
        CLPChatViewController *chat = (CLPChatViewController*) segue.destinationViewController;
        
        chat.nickname = self.nickField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"connect" sender:textField];
    
    return YES;
}

@end
