//
//	TouchcodePrefix.h
//	TouchCode
//
//	Created by Jonathan Wight on 10/15/2005.
//	Copyright 2005 toxicsoftware.com. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.
//

#ifdef __OBJC__

	#if !defined(DEBUG) || DEBUG == 0
		#define NS_BLOCK_ASSERTIONS 1
	#endif

	#if DEBUG == 1
		#define Assert_(test, ...) NSAssert((test), [NSString stringWithFormat:__VA_ARGS__])

		#define AssertC_(test, ...) NSAssertC((test), [NSString stringWithFormat:__VA_ARGS__])

		#define AssertUnimplemented_() Assert_(0, @"Method unimplemented")

		#define AssertCast_(CLS_, OBJ_) ({ \
			id theObject = (OBJ_); \
			if (theObject != NULL) \
				{ \
				Class theDesiredClass = [CLS_ class]; \
				NSAssert2([theObject isKindOfClass:theDesiredClass], @"Object %@ not of class %@", theObject, NSStringFromClass(theDesiredClass)); \
				} \
			(CLS_ *)theObject; \
			})

		#define AssertOnMainThread_()
	#else
		#define Assert_(test, ...) \
			do \
				{ \
				if (!(test)) NSLog(__VA_ARGS__); \
				} \
			while (0)

		#define AssertC_(test, ...) Assert_(test, __VA_ARGS__)

		#define AssertUnimplemented_() Assert_(0, @"Method unimplemented")

		#define AssertCast_(CLS_, OBJ_) ({ (CLS_ *)(OBJ_); })

		#define AssertOnMainThread_() Assert_([NSThread isMainThread], @"Need to be on main thread.")
	#endif

#endif
