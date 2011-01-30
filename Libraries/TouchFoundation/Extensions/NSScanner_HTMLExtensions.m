//
//  NSScanner_HTMLExtensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 07/01/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSScanner_HTMLExtensions.h"

typedef struct
	{
	char *name;
	NSInteger codePoint;
	unichar unicode;
	}
	HTMLEntity;

HTMLEntity kRawEntities[] = {

	{ .name = "nbsp", .codePoint = 160, .unicode = 0x00A0 }, // no-break space = non-breaking space, U+00A0 ISOnum

	// C0 Controls and Basic Latin
	{ .name = "quot", .codePoint = 34, .unicode = 0x0022 }, // quotation mark = APL quote, U+0022 ISOnum
	{ .name = "amp", .codePoint = 38, .unicode = 0x0026 }, // ampersand, U+0026 ISOnum
	{ .name = "lt", .codePoint = 60, .unicode = 0x003C }, // less-than sign, U+003C ISOnum
	{ .name = "gt", .codePoint = 62, .unicode = 0x003E }, // greater-than sign, U+003E ISOnum

	// Latin Extended-A
	{ .name = "OElig", .codePoint = 338, .unicode = 0x0152 }, // latin capital ligature OE, U+0152 ISOlat2
	{ .name = "Yuml", .codePoint = 376, .unicode = 0x0178 }, // latin capital letter Y with diaeresis, U+0178 ISOlat2
	// ligature is a misnomer, this is a separate character in some languages
	{ .name = "Scaron", .codePoint = 352, .unicode = 0x0160 }, // latin capital letter S with caron, U+0160 ISOlat2
	{ .name = "scaron", .codePoint = 353, .unicode = 0x0161 }, // latin small letter s with caron, U+0161 ISOlat2
	{ .name = "Yuml", .codePoint = 376, .unicode = 0x0178 }, // latin capital letter Y with diaeresis, U+0178 ISOlat2

	// Spacing Modifier Letters
	{ .name = "circ", .codePoint = 710, .unicode = 0x02C6 }, // modifier letter circumflex accent, U+02C6 ISOpub
	{ .name = "tilde", .codePoint = 732, .unicode = 0x02DC }, // small tilde, U+02DC ISOdia

	// General Punctuation
	{ .name = "ensp", .codePoint = 8194, .unicode = 0x2002 }, // en space, U+2002 ISOpub
	{ .name = "emsp", .codePoint = 8195, .unicode = 0x2003 }, // em space, U+2003 ISOpub
	{ .name = "thinsp", .codePoint = 8201, .unicode = 0x2009 }, // thin space, U+2009 ISOpub
	{ .name = "zwnj", .codePoint = 8204, .unicode = 0x200C }, // zero width non-joiner, U+200C NEW RFC 2070
	{ .name = "zwj", .codePoint = 8205, .unicode = 0x200D }, // zero width joiner, U+200D NEW RFC 2070
	{ .name = "lrm", .codePoint = 8206, .unicode = 0x200E }, // left-to-right mark, U+200E NEW RFC 2070
	{ .name = "rlm", .codePoint = 8207, .unicode = 0x200F }, // right-to-left mark, U+200F NEW RFC 2070
	{ .name = "ndash", .codePoint = 8211, .unicode = 0x2013 }, // en dash, U+2013 ISOpub
	{ .name = "mdash", .codePoint = 8212, .unicode = 0x2014 }, // em dash, U+2014 ISOpub
	{ .name = "lsquo", .codePoint = 8216, .unicode = 0x2018 }, // left single quotation mark, U+2018 ISOnum
	{ .name = "rsquo", .codePoint = 8217, .unicode = 0x2019 }, // right single quotation mark, U+2019 ISOnum
	{ .name = "sbquo", .codePoint = 8218, .unicode = 0x201A }, // single low-9 quotation mark, U+201A NEW
	{ .name = "ldquo", .codePoint = 8220, .unicode = 0x201C }, // left double quotation mark, U+201C ISOnum
	{ .name = "rdquo", .codePoint = 8221, .unicode = 0x201D }, // right double quotation mark, U+201D ISOnum
	{ .name = "bdquo", .codePoint = 8222, .unicode = 0x201E }, // double low-9 quotation mark, U+201E NEW
	{ .name = "dagger", .codePoint = 8224, .unicode = 0x2020 }, // dagger, U+2020 ISOpub
	{ .name = "Dagger", .codePoint = 8225, .unicode = 0x2021 }, // double dagger, U+2021 ISOpub
	{ .name = "permil", .codePoint = 8240, .unicode = 0x2030 }, // per mille sign, U+2030 ISOtech
	{ .name = "lsaquo", .codePoint = 8249, .unicode = 0x2039 }, // single left-pointing angle quotation mark, U+2039 ISO proposed
	// lsaquo is proposed but not yet ISO standardized
	{ .name = "rsaquo", .codePoint = 8250, .unicode = 0x203A }, // single right-pointing angle quotation mark, U+203A ISO proposed
	// rsaquo is proposed but not yet ISO standardized
	{ .name = "euro", .codePoint = 8364, .unicode = 0x20AC }, // euro sign, U+20AC NEW

	// http://www.w3.org/TR/REC-html40/sgml/entities.html
	{ .name = "nbsp", .codePoint = 160, .unicode = 0x00A0 }, // no-break space = non-breaking space, U+00A0 ISOnum
	{ .name = "iexcl", .codePoint = 161, .unicode = 0x00A1 }, // inverted exclamation mark, U+00A1 ISOnum
	{ .name = "cent", .codePoint = 162, .unicode = 0x00A2 }, // cent sign, U+00A2 ISOnum
	{ .name = "pound", .codePoint = 163, .unicode = 0x00A3 }, // pound sign, U+00A3 ISOnum
	{ .name = "curren", .codePoint = 164, .unicode = 0x00A4 }, // currency sign, U+00A4 ISOnum
	{ .name = "yen", .codePoint = 165, .unicode = 0x00A5 }, // yen sign = yuan sign, U+00A5 ISOnum
	{ .name = "brvbar", .codePoint = 166, .unicode = 0x00A6 }, // broken bar = broken vertical bar, U+00A6 ISOnum
	{ .name = "sect", .codePoint = 167, .unicode = 0x00A7 }, // section sign, U+00A7 ISOnum
	{ .name = "uml", .codePoint = 168, .unicode = 0x00A8 }, // diaeresis = spacing diaeresis, U+00A8 ISOdia
	{ .name = "copy", .codePoint = 169, .unicode = 0x00A9 }, // copyright sign, U+00A9 ISOnum
	{ .name = "ordf", .codePoint = 170, .unicode = 0x00AA }, // feminine ordinal indicator, U+00AA ISOnum
	{ .name = "laquo", .codePoint = 171, .unicode = 0x00AB }, // left-pointing double angle quotation mark= left pointing guillemet, U+00AB ISOnum
	{ .name = "not", .codePoint = 172, .unicode = 0x00AC }, // not sign, U+00AC ISOnum
	{ .name = "shy", .codePoint = 173, .unicode = 0x00AD }, // soft hyphen = discretionary hyphen, U+00AD ISOnum
	{ .name = "reg", .codePoint = 174, .unicode = 0x00AE }, // registered sign = registered trade mark sign, U+00AE ISOnum
	{ .name = "macr", .codePoint = 175, .unicode = 0x00AF }, // macron = spacing macron = overline= APL overbar, U+00AF ISOdia
	{ .name = "deg", .codePoint = 176, .unicode = 0x00B0 }, // degree sign, U+00B0 ISOnum
	{ .name = "plusmn", .codePoint = 177, .unicode = 0x00B1 }, // plus-minus sign = plus-or-minus sign, U+00B1 ISOnum
	{ .name = "sup2", .codePoint = 178, .unicode = 0x00B2 }, // superscript two = superscript digit two= squared, U+00B2 ISOnum
	{ .name = "sup3", .codePoint = 179, .unicode = 0x00B3 }, // superscript three = superscript digit three= cubed, U+00B3 ISOnum
	{ .name = "acute", .codePoint = 180, .unicode = 0x00B4 }, // acute accent = spacing acute, U+00B4 ISOdia
	{ .name = "micro", .codePoint = 181, .unicode = 0x00B5 }, // micro sign, U+00B5 ISOnum
	{ .name = "para", .codePoint = 182, .unicode = 0x00B6 }, // pilcrow sign = paragraph sign, U+00B6 ISOnum
	{ .name = "middot", .codePoint = 183, .unicode = 0x00B7 }, // middle dot = Georgian comma= Greek middle dot, U+00B7 ISOnum
	{ .name = "cedil", .codePoint = 184, .unicode = 0x00B8 }, // cedilla = spacing cedilla, U+00B8 ISOdia
	{ .name = "sup1", .codePoint = 185, .unicode = 0x00B9 }, // superscript one = superscript digit one, U+00B9 ISOnum
	{ .name = "ordm", .codePoint = 186, .unicode = 0x00BA }, // masculine ordinal indicator, U+00BA ISOnum
	{ .name = "raquo", .codePoint = 187, .unicode = 0x00BB }, // right-pointing double angle quotation mark= right pointing guillemet, U+00BB ISOnum
	{ .name = "frac14", .codePoint = 188, .unicode = 0x00BC }, // vulgar fraction one quarter= fraction one quarter, U+00BC ISOnum
	{ .name = "frac12", .codePoint = 189, .unicode = 0x00BD }, // vulgar fraction one half= fraction one half, U+00BD ISOnum
	{ .name = "frac34", .codePoint = 190, .unicode = 0x00BE }, // vulgar fraction three quarters= fraction three quarters, U+00BE ISOnum
	{ .name = "iquest", .codePoint = 191, .unicode = 0x00BF }, // inverted question mark= turned question mark, U+00BF ISOnum
	{ .name = "Agrave", .codePoint = 192, .unicode = 0x00C0 }, // latin capital letter A with grave= latin capital letter A grave, U+00C0 ISOlat1
	{ .name = "Aacute", .codePoint = 193, .unicode = 0x00C1 }, // latin capital letter A with acute, U+00C1 ISOlat1
	{ .name = "Acirc", .codePoint = 194, .unicode = 0x00C2 }, // latin capital letter A with circumflex, U+00C2 ISOlat1
	{ .name = "Atilde", .codePoint = 195, .unicode = 0x00C3 }, // latin capital letter A with tilde, U+00C3 ISOlat1
	{ .name = "Auml", .codePoint = 196, .unicode = 0x00C4 }, // latin capital letter A with diaeresis, U+00C4 ISOlat1
	{ .name = "Aring", .codePoint = 197, .unicode = 0x00C5 }, // latin capital letter A with ring above= latin capital letter A ring, U+00C5 ISOlat1
	{ .name = "AElig", .codePoint = 198, .unicode = 0x00C6 }, // latin capital letter AE= latin capital ligature AE, U+00C6 ISOlat1
	{ .name = "Ccedil", .codePoint = 199, .unicode = 0x00C7 }, // latin capital letter C with cedilla, U+00C7 ISOlat1
	{ .name = "Egrave", .codePoint = 200, .unicode = 0x00C8 }, // latin capital letter E with grave, U+00C8 ISOlat1
	{ .name = "Eacute", .codePoint = 201, .unicode = 0x00C9 }, // latin capital letter E with acute, U+00C9 ISOlat1
	{ .name = "Ecirc", .codePoint = 202, .unicode = 0x00CA }, // latin capital letter E with circumflex, U+00CA ISOlat1
	{ .name = "Euml", .codePoint = 203, .unicode = 0x00CB }, // latin capital letter E with diaeresis, U+00CB ISOlat1
	{ .name = "Igrave", .codePoint = 204, .unicode = 0x00CC }, // latin capital letter I with grave, U+00CC ISOlat1
	{ .name = "Iacute", .codePoint = 205, .unicode = 0x00CD }, // latin capital letter I with acute, U+00CD ISOlat1
	{ .name = "Icirc", .codePoint = 206, .unicode = 0x00CE }, // latin capital letter I with circumflex, U+00CE ISOlat1
	{ .name = "Iuml", .codePoint = 207, .unicode = 0x00CF }, // latin capital letter I with diaeresis, U+00CF ISOlat1
	{ .name = "ETH", .codePoint = 208, .unicode = 0x00D0 }, // latin capital letter ETH, U+00D0 ISOlat1
	{ .name = "Ntilde", .codePoint = 209, .unicode = 0x00D1 }, // latin capital letter N with tilde, U+00D1 ISOlat1
	{ .name = "Ograve", .codePoint = 210, .unicode = 0x00D2 }, // latin capital letter O with grave, U+00D2 ISOlat1
	{ .name = "Oacute", .codePoint = 211, .unicode = 0x00D3 }, // latin capital letter O with acute, U+00D3 ISOlat1
	{ .name = "Ocirc", .codePoint = 212, .unicode = 0x00D4 }, // latin capital letter O with circumflex, U+00D4 ISOlat1
	{ .name = "Otilde", .codePoint = 213, .unicode = 0x00D5 }, // latin capital letter O with tilde, U+00D5 ISOlat1
	{ .name = "Ouml", .codePoint = 214, .unicode = 0x00D6 }, // latin capital letter O with diaeresis, U+00D6 ISOlat1
	{ .name = "times", .codePoint = 215, .unicode = 0x00D7 }, // multiplication sign, U+00D7 ISOnum
	{ .name = "Oslash", .codePoint = 216, .unicode = 0x00D8 }, // latin capital letter O with stroke= latin capital letter O slash, U+00D8 ISOlat1
	{ .name = "Ugrave", .codePoint = 217, .unicode = 0x00D9 }, // latin capital letter U with grave, U+00D9 ISOlat1
	{ .name = "Uacute", .codePoint = 218, .unicode = 0x00DA }, // latin capital letter U with acute, U+00DA ISOlat1
	{ .name = "Ucirc", .codePoint = 219, .unicode = 0x00DB }, // latin capital letter U with circumflex, U+00DB ISOlat1
	{ .name = "Uuml", .codePoint = 220, .unicode = 0x00DC }, // latin capital letter U with diaeresis, U+00DC ISOlat1
	{ .name = "Yacute", .codePoint = 221, .unicode = 0x00DD }, // latin capital letter Y with acute, U+00DD ISOlat1
	{ .name = "THORN", .codePoint = 222, .unicode = 0x00DE }, // latin capital letter THORN, U+00DE ISOlat1
	{ .name = "szlig", .codePoint = 223, .unicode = 0x00DF }, // latin small letter sharp s = ess-zed, U+00DF ISOlat1
	{ .name = "agrave", .codePoint = 224, .unicode = 0x00E0 }, // latin small letter a with grave= latin small letter a grave, U+00E0 ISOlat1
	{ .name = "aacute", .codePoint = 225, .unicode = 0x00E1 }, // latin small letter a with acute, U+00E1 ISOlat1
	{ .name = "acirc", .codePoint = 226, .unicode = 0x00E2 }, // latin small letter a with circumflex, U+00E2 ISOlat1
	{ .name = "atilde", .codePoint = 227, .unicode = 0x00E3 }, // latin small letter a with tilde, U+00E3 ISOlat1
	{ .name = "auml", .codePoint = 228, .unicode = 0x00E4 }, // latin small letter a with diaeresis, U+00E4 ISOlat1
	{ .name = "aring", .codePoint = 229, .unicode = 0x00E5 }, // latin small letter a with ring above= latin small letter a ring, U+00E5 ISOlat1
	{ .name = "aelig", .codePoint = 230, .unicode = 0x00E6 }, // latin small letter ae= latin small ligature ae, U+00E6 ISOlat1
	{ .name = "ccedil", .codePoint = 231, .unicode = 0x00E7 }, // latin small letter c with cedilla, U+00E7 ISOlat1
	{ .name = "egrave", .codePoint = 232, .unicode = 0x00E8 }, // latin small letter e with grave, U+00E8 ISOlat1
	{ .name = "eacute", .codePoint = 233, .unicode = 0x00E9 }, // latin small letter e with acute, U+00E9 ISOlat1
	{ .name = "ecirc", .codePoint = 234, .unicode = 0x00EA }, // latin small letter e with circumflex, U+00EA ISOlat1
	{ .name = "euml", .codePoint = 235, .unicode = 0x00EB }, // latin small letter e with diaeresis, U+00EB ISOlat1
	{ .name = "igrave", .codePoint = 236, .unicode = 0x00EC }, // latin small letter i with grave, U+00EC ISOlat1
	{ .name = "iacute", .codePoint = 237, .unicode = 0x00ED }, // latin small letter i with acute, U+00ED ISOlat1
	{ .name = "icirc", .codePoint = 238, .unicode = 0x00EE }, // latin small letter i with circumflex, U+00EE ISOlat1
	{ .name = "iuml", .codePoint = 239, .unicode = 0x00EF }, // latin small letter i with diaeresis, U+00EF ISOlat1
	{ .name = "eth", .codePoint = 240, .unicode = 0x00F0 }, // latin small letter eth, U+00F0 ISOlat1
	{ .name = "ntilde", .codePoint = 241, .unicode = 0x00F1 }, // latin small letter n with tilde, U+00F1 ISOlat1
	{ .name = "ograve", .codePoint = 242, .unicode = 0x00F2 }, // latin small letter o with grave, U+00F2 ISOlat1
	{ .name = "oacute", .codePoint = 243, .unicode = 0x00F3 }, // latin small letter o with acute, U+00F3 ISOlat1
	{ .name = "ocirc", .codePoint = 244, .unicode = 0x00F4 }, // latin small letter o with circumflex, U+00F4 ISOlat1
	{ .name = "otilde", .codePoint = 245, .unicode = 0x00F5 }, // latin small letter o with tilde, U+00F5 ISOlat1
	{ .name = "ouml", .codePoint = 246, .unicode = 0x00F6 }, // latin small letter o with diaeresis, U+00F6 ISOlat1
	{ .name = "divide", .codePoint = 247, .unicode = 0x00F7 }, // division sign, U+00F7 ISOnum
	{ .name = "oslash", .codePoint = 248, .unicode = 0x00F8 }, // latin small letter o with stroke,= latin small letter o slash, U+00F8 ISOlat1
	{ .name = "ugrave", .codePoint = 249, .unicode = 0x00F9 }, // latin small letter u with grave, U+00F9 ISOlat1
	{ .name = "uacute", .codePoint = 250, .unicode = 0x00FA }, // latin small letter u with acute, U+00FA ISOlat1
	{ .name = "ucirc", .codePoint = 251, .unicode = 0x00FB }, // latin small letter u with circumflex, U+00FB ISOlat1
	{ .name = "uuml", .codePoint = 252, .unicode = 0x00FC }, // latin small letter u with diaeresis, U+00FC ISOlat1
	{ .name = "yacute", .codePoint = 253, .unicode = 0x00FD }, // latin small letter y with acute, U+00FD ISOlat1
	{ .name = "thorn", .codePoint = 254, .unicode = 0x00FE }, // latin small letter thorn, U+00FE ISOlat1
	{ .name = "yuml", .codePoint = 255, .unicode = 0x00FF }, // latin small letter y with diaeresis, U+00FF ISOlat1
	{ .name = NULL },
	};

static NSDictionary *gEntitiesByName = NULL;
static NSDictionary *gEntitiesByCodePoint = NULL;

@implementation NSScanner (NSScanner_HTMLExtensions)

- (BOOL)scanHTMLEntityIntoString:(NSString **)outString
{
@synchronized (gEntitiesByName)
	{
	if (gEntitiesByName == NULL)
		{
		NSMutableDictionary *theEntitiesByName = [NSMutableDictionary dictionary];
		NSMutableDictionary *theEntitiesByCodePoint = [NSMutableDictionary dictionary];

		for (HTMLEntity *P = kRawEntities; P->name != NULL; ++P)
			{
			NSString *theUnicode = [NSString stringWithFormat:@"%C", P->unicode];
			[theEntitiesByName setObject:theUnicode forKey:[NSString stringWithUTF8String:P->name]];
			
			NSNumber *theCodePoint = [NSNumber numberWithInt:P->codePoint];
			[theEntitiesByCodePoint setObject:theUnicode forKey:theCodePoint];
			}
		
		// TODO -- technically this leaks.
		gEntitiesByName = [theEntitiesByName copy];
		gEntitiesByCodePoint = [theEntitiesByCodePoint copy];
		}
	}

// #############################################################################

const NSUInteger theSavedLocation = [self scanLocation];
NSString *theString = NULL;
NSString *theOutput = NULL;

if ([self scanString:@"&" intoString:NULL] == NO)
	{
	// TODO - we dont do hex entities yet. But we should.
	[self setScanLocation:theSavedLocation];
	return(NO);
	}



if ([self scanString:@"#" intoString:NULL] == YES)
	{
	if ([self scanString:@"x" intoString:NULL] == YES)
		{
		// TODO - we dont do hex entities yet. But we should.
		[self setScanLocation:theSavedLocation];
		return(NO);
		}
	else
		{
		if ([self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&theString] == NO)
			{
			[self setScanLocation:theSavedLocation];
			return(NO);
			}
		const NSInteger theCodePoint = [theString intValue];
		NSString *theUnicode = [gEntitiesByCodePoint objectForKey:[NSNumber numberWithInt:theCodePoint]];
		if (theUnicode == NULL)
			{
			[self setScanLocation:theSavedLocation];
			return(NO);
			}
		theOutput = theUnicode;
		}

	if ([self scanString:@";" intoString:NULL] == NO)
		{
		[self setScanLocation:theSavedLocation];
		return(NO);
		}
	}
else
	{
	if ([self scanUpToString:@";" intoString:&theString] == NO)
		{
		[self setScanLocation:theSavedLocation];
		return(NO);
		}
	else
		{
		NSString *theUnicode = [gEntitiesByName objectForKey:theString];
		if (theUnicode == NULL)
			{
			[self setScanLocation:theSavedLocation];
			return(NO);
			}
		theOutput = theUnicode;
		}

	if ([self scanString:@";" intoString:NULL] == NO)
		{
		[self setScanLocation:theSavedLocation];
		return(NO);
		}
	}

	
if (outString)
	*outString = theOutput;

return(YES);
}

@end
