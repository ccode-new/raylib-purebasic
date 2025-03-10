#include "raylib_pb_helper.h"
#include <math.h>

// Generates a nice color with a random hue
void pbhelper_GenerateRandomColor(Color *result, float s, float v)
{
	if (result)
	{
		const float Phi = 0.618033988749895f; // Golden ratio conjugate
		float h = (float)GetRandomValue(0, 360);
		h = fmodf((h + h*Phi), 360.0f);
		*result = ColorFromHSV(h, s, v);
	}
}
