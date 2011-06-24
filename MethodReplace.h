// COMMON FILE: Common

//
//  MethodReplace.h
//  XcodeColors
//
//  Created by Uncle MiF on 9/15/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

/* The Black Magic begins here */
#import <objc/runtime.h>

typedef enum { CLASS_METHOD, INSTANCE_METHOD} t_target;

#define ReplaceClassMethod(sourceClassName,sourceSelName,destinationClassName) ReplaceMethod(CLASS_METHOD, [sourceClassName class], @selector(sourceSelName), [destinationClassName class], 0)
#define ReplaceInstanceMethod(sourceClassName,sourceSelName,destinationClassName) ReplaceMethod(INSTANCE_METHOD, [sourceClassName class], @selector(sourceSelName), [destinationClassName class], 0)

#define DynamicMessage(targetMode,targetClassName,instance,targetSelName,...) \
do\
{\
Method (*get_targetMethod)(Class,SEL) = targetMode == CLASS_METHOD ? class_getClassMethod : class_getInstanceMethod;\
Method method = get_targetMethod([targetClassName class],@selector(targetSelName));\
if (method)\
{\
IMP imp = method_getImplementation(method);\
if (imp)\
imp(instance,@selector(targetSelName),##__VA_ARGS__);\
}\
} while(0)

#define DynamicClassMessage(...) DynamicMessage(CLASS_METHOD,##__VA_ARGS__)
#define DynamicInstanceMessage(...) DynamicMessage(INSTANCE_METHOD,##__VA_ARGS__)

IMP ReplaceMethod(t_target target, 
																		Class sourceClass,SEL sourceSel,
																		Class destinationClass,SEL destinationSel);