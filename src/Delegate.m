/* Delegate.m: Delegate for Cocoa
 * Copyright 2012-2025 Vincent Damewood
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <SilikoCore/InfixParser.h>
#include <SilikoCore/StringSource.h>
#include <SilikoCore/SyntaxTree.h>
#include <SilikoCore/Value.h>

#import "Delegate.h"

@implementation SilikoGuiDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.caller = SilikoFunctionCallerNew();
	SilikoFunctionCallerInstallOperators(self.caller);
	SilikoFunctionCallerInstallFunctions(self.caller);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	SilikoFunctionCallerDelete(self.caller);
}

- (IBAction) Calculate:(id)sender
{
	SilikoSyntaxTreeNode *Ast = SilikoParseInfix(SilikoStringSourceNew([[self.input stringValue] UTF8String]));
	SilikoValue *Result = SilikoSyntaxTreeEvaluate(Ast, self.caller);
	SilikoSyntaxTreeDelete(Ast);

	switch (SilikoValueGetStatus(Result))
	{
	case (SilikoValueInteger):
		[self.output setIntegerValue: SilikoValueToInteger(Result)];
		break;
	case (SilikoValueReal):
		[self.output setDoubleValue: SilikoValueToReal(Result)];
		break;
	case (SilikoValueError):
		switch(SilikoValueToError(Result))
		{
		case SilikoErrorMemory:
			[self.output setStringValue: @"Out of memory"];
			break;
		case SilikoErrorSyntax:
			[self.output setStringValue: @"Syntax error"];
			break;
		case SilikoErrorZeroDivision:
			[self.output setStringValue: @"Division by zero"];
			break;
		case SilikoErrorFunctionName:
			[self.output setStringValue: @"Function not found"];
			break;
		case SilikoErrorFunctionArguments:
			[self.output setStringValue: @"Bad argument count"];
			break;
		case SilikoErrorDomain:
			[self.output setStringValue: @"Domain error"];
			break;
		case SilikoErrorRange:
			[self.output setStringValue: @"Range error"];
			break;
		default:
			[self.output setStringValue: @"Unexpected error"];
		}
	}

	SilikoValueDelete(Result);
}
@end
