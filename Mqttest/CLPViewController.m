//
//  CLPViewController.m
//  Mqttest
//
//  Created by Rodrigo Lorca on 13/05/14.
//  Copyright (c) 2014 Clops. All rights reserved.
//

#import "CLPViewController.h"

#import <MQTTKit.h>

@interface CLPViewController () <UITextFieldDelegate>

@property MQTTClient *client;
@property (weak, nonatomic) IBOutlet UITextField *nick;
@property (weak, nonatomic) IBOutlet UITextView *output;
@property (weak, nonatomic) IBOutlet UITextField *message;

@end

@implementation CLPViewController

static NSString * const channel = @"/MQTTKit/canard";

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.message.delegate = self;
    
    self.nick.text = [[[UIDevice currentDevice] identifierForVendor].UUIDString substringToIndex:6];
}

- (IBAction)connect:(id)sender
{
    __weak CLPViewController *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nick resignFirstResponder];
    });
    
    NSString *nickname = self.nick.text;
    
    self.client = [[MQTTClient alloc] initWithClientId:nickname];

    self.client.cleanSession = NO;
    
    [self.client setMessageHandler:^(MQTTMessage *message) {
       
        NSString *text = [NSString stringWithFormat:@"(%d)%@", message.mid, message.payloadString];
        
        [weakSelf append:text];
    }];
    
    // connect to the MQTT server
    [self.client connectToHost:@"78.47.91.34"
             completionHandler:^(NSUInteger code) {
                 if (code == ConnectionAccepted) {
                     
                     [weakSelf append:@"Connected"];
                     
                     [self.client subscribe:channel
                                    withQos:ExactlyOnce
                          completionHandler:nil];
                     
                     NSString *msg = [NSString stringWithFormat:@"%@ joined.", nickname];
                     
                     [self.client publishString:msg
                                        toTopic:channel
                                        withQos:AtLeastOnce
                                         retain:YES completionHandler:nil];
                     
                      msg = [NSString stringWithFormat:@"%@ left.", nickname];

                     
                     [self.client setWill:msg toTopic:channel withQos:AtLeastOnce retain:NO];
                     
                 }
             }];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(!self.client.connected)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please connect first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return YES;
    }
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:SS";
    
    NSString *msg = [NSString stringWithFormat:@"[%@] <%@> %@", [fmt stringFromDate:[NSDate date]],
                                                                self.nick.text,
                     
                     textField.text];
    
    [self.client publishString:msg
                       toTopic:channel
                       withQos:AtLeastOnce
                        retain:YES
             completionHandler:^(int mid) {
                 
                 
             }];
    
    return YES;
}

-(void) append:(NSString*) text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.output.text = [NSString stringWithFormat:@"%@\n%@", text, self.output.text];
    });
}


@end
