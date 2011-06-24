// COMMON FILE: Common

//
//  MethodReplace.m
//  XcodeColors
//
//  Created by Uncle MiF on 9/15/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "MethodReplace.h"

IMP ReplaceMethod(t_target target, 
																		Class sourceClass,SEL sourceSel,
																		Class destinationClass,SEL destinationSel)
{
	if (!sourceSel || !sourceClass || !destinationClass)
		return nil;
	
	if (!destinationSel)
		destinationSel = sourceSel;
	
	Method (*get_targetMethod)(Class,SEL) = target == CLASS_METHOD ? class_getClassMethod : class_getInstanceMethod;
	
	Method sourceMethod = get_targetMethod(sourceClass, sourceSel);
	if (!sourceMethod)
		return nil;
	
	IMP prevImplementation = method_getImplementation(sourceMethod);
	
	Method destinationMethod = get_targetMethod(destinationClass, destinationSel);
	if (!destinationMethod)
		return nil;
	
	IMP newImplementation = method_getImplementation(destinationMethod);
	if (!newImplementation)
		return nil;
	
	method_setImplementation(sourceMethod, newImplementation);
	
	return prevImplementation;
}