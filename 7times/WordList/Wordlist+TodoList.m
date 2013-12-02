//
// Created by Li Shuo on 13-12-2.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "Wordlist+TodoList.h"


@implementation Wordlist (TodoList)

-(Wordlist *)todoList{
    if([self.name rangeOfString:@"todo"].location != NSNotFound){
        NSLog(@"A todo list should not have another todo list");
        return nil;
    }

    NSString *name = [NSString stringWithFormat:@"todo_%@", self.name];
    Wordlist *todo = [Wordlist MR_findFirstByAttribute:@"name" withValue:name];
    if(todo == nil){
        todo = [Wordlist MR_createEntity];
        todo.name = name;

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }

    return todo;
}

@end