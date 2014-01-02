//
//  ASPluginRemover.m
//  ASPluginRemover
//
//  Created by Adam N. Smith on 1/1/14.
//  Copyright (c) 2014 Magnus Development. All rights reserved.
//

#import "ASPluginRemover.h"

@implementation ASPluginRemover

+(void)pluginDidLoad:(NSBundle *)plugin{
    
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }//end if
}//end method

-(id)initWithBundle:(NSBundle *)plugin{
    
    if (self = [super init]) {

        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Product"];
        
        if (menuItem) {
            
            //setup main menu item
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Remove Plugin" action:nil keyEquivalent:@""];
            [[menuItem submenu] addItem:actionMenuItem];
            
            //get list of plugin names
            NSString *pluginsPath = @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins";
            NSArray *pluginFilePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[pluginsPath stringByStandardizingPath] error:nil];
            
            //remove plugin filename extension
            NSMutableArray *pluginNames = [[NSMutableArray alloc] init];
            for(NSString *fileName in pluginFilePaths)
                [pluginNames addObject:[[fileName componentsSeparatedByString:@"."] objectAtIndex:0]];
            
            //create menu with plugin names
            NSMenu *menuOfPlugins = [[NSMenu alloc] init];
            for(NSString *pluginName in pluginNames){
            
                NSMenuItem *plugin = [[NSMenuItem alloc] initWithTitle:pluginName action:@selector(deletePluginWithName:) keyEquivalent:@""];
                [plugin setTarget:self];
                [menuOfPlugins addItem:plugin];
                
            }//end for
            
            actionMenuItem.submenu = menuOfPlugins;
        }//end if
        
    }//end if
    
    return self;
    
}//end method

-(void)deletePluginWithName:(NSMenuItem *)pluginMenuItem{

    //get path to plugin
    NSString *pluginFilePath = [NSString stringWithFormat:@"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/%@.xcplugin",pluginMenuItem.title];
    
    //remove plugin
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[pluginFilePath stringByStandardizingPath] error:&error];
    
    //display alert message
    NSAlert *finishedAlert;
    if(error == nil){
    
        finishedAlert = [NSAlert alertWithMessageText:@"Plugin Successfully Removed!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please restart Xcode for the changes to take effect."];
        
    }else{
    
        finishedAlert = [NSAlert alertWithMessageText:@"Error!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"An error occurred while removing the plugin."];
        
    }//end if
    
    [finishedAlert runModal];
    
}//end method

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}//end method

@end
