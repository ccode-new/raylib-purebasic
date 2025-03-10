#include "raylib_pb_helper.h"
#include "rlgl.h"
#include <math.h>

// Measure a text in 3D ignoring the `~~` chars.
void pbhelper_MeasureTextWave3D(Vector3* result, Font* font, const char* text, float fontSize, float fontSpacing, float lineSpacing)
{
	if (result && font)
	{
		int len = TextLength(text);
		int tempLen = 0;                // Used to count longer text line num chars
		int lenCounter = 0;

		float tempTextWidth = 0.0f;     // Used to count longer text line width

		float scale = fontSize/(float)font->baseSize;
		float textHeight = scale;
		float textWidth = 0.0f;

		int letter = 0;                 // Current character
		int index = 0;                  // Index position in sprite font

		for (int i = 0; i < len; i++)
		{
			lenCounter++;

			int next = 0;
			letter = GetCodepoint(&text[i], &next);
			index = GetGlyphIndex(*font, letter);

			// NOTE: normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
			// but we need to draw all of the bad bytes using the '?' symbol so to not skip any we set next = 1
			if (letter == 0x3f) next = 1;
			i += next - 1;

			if (letter != '\n')
			{
				if (letter == '~' && GetCodepoint(&text[i+1], &next) == '~')
				{
					i++;
				}
				else
				{
					if (font->glyphs[index].advanceX != 0) textWidth += (font->glyphs[index].advanceX+fontSpacing)/(float)font->baseSize*scale;
					else textWidth += (font->recs[index].width + font->glyphs[index].offsetX)/(float)font->baseSize*scale;
				}
			}
			else
			{
				if (tempTextWidth < textWidth) tempTextWidth = textWidth;
				lenCounter = 0;
				textWidth = 0.0f;
				textHeight += scale + lineSpacing/(float)font->baseSize*scale;
			}

			if (tempLen < lenCounter) tempLen = lenCounter;
		}

		if (tempTextWidth < textWidth) tempTextWidth = textWidth;

		Vector3 vec = { 0 };
		vec.x = tempTextWidth + (float)((tempLen - 1)*fontSpacing/(float)font->baseSize*scale); // Adds chars spacing to measure
		vec.y = 0.25f;
		vec.z = textHeight;

		*result = vec;
	}
}
