//
//  CLPViewController.m
//  Mqttest
//
//  Created by Rodrigo Lorca on 13/05/14.
//  Copyright (c) 2014 Clops. All rights reserved.
//

#import "CLPChatViewController.h"

#import <MQTTKit.h>

@interface CLPChatViewController () <UITextFieldDelegate>

@property MQTTClient *client;

@property (weak, nonatomic) IBOutlet UITextView *output;
@property (weak, nonatomic) IBOutlet UITextField *message;

@end

@implementation CLPChatViewController

static NSString * const channel = @"/MQTTKit/canard";

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.message.delegate = self;
    
    self.client = [[MQTTClient alloc] initWithClientId:self.nickname];
    
    self.client.cleanSession = NO;
    
    __weak CLPChatViewController *weakSelf = self;
    
    [self.client setMessageHandler:^(MQTTMessage *message) {
        
        [weakSelf append:message.payloadString];
    }];
    
    // connect to the MQTT server
    [self.client connectToHost:@"78.47.91.34"
             completionHandler:^(NSUInteger code) {
                 if (code == ConnectionAccepted) {
                     
                     [weakSelf append:@"Connected"];
                     
                     [self.client subscribe:channel
                                    withQos:ExactlyOnce
                          completionHandler:nil];
                     
                     NSString *msg = [NSString stringWithFormat:@"%@ joined.", self.nickname];
                     
                     [self.client publishString:msg
                                        toTopic:channel
                                        withQos:ExactlyOnce
                                         retain:YES completionHandler:nil];
                     
                     msg = [NSString stringWithFormat:@"%@ left.", self.nickname];
                     
                     [self.client setWill:msg toTopic:channel withQos:AtLeastOnce retain:NO];
                 }
             }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(!self.client.connected)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please connect first"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return YES;
    }
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:SS";
    
    NSString *msg = [NSString stringWithFormat:@"[%@] <%@> %@", [fmt stringFromDate:[NSDate date]],
                                                                self.nickname,
                                                                textField.text];
    
    [self.client publishString:msg
                       toTopic:channel
                       withQos:AtLeastOnce
                        retain:YES
             completionHandler:^(int mid) {
                 
                 
             }];
    
    textField.text = nil;
    
    return YES;
}

-(void) append:(NSString*) text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.output.text = [NSString stringWithFormat:@"%@\n%@", text, self.output.text];
    });
}


@end
