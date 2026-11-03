
shader_type canvas_item;

uniform bool stepify = true;
uniform float value : hint_range(0.0, 1.0) = 1.0;
uniform int count = 10;
uniform vec2 margin;
uniform float shear_angle : hint_range(-1.0, 1.0) = 0.0;

uniform sampler2D gradient_x : source_color;
uniform sampler2D gradient_y : source_color;

uniform bool use_value_gradient = false;
uniform bool invert = false;


vec4 get_gradient_color(sampler2D src, float position) {
	position = clamp(position, 0.01, 0.99);
	return texture(src, vec2(position, 0.5));
}


float square_shape(vec2 uv, vec2 size) {
	vec2 bl = step((1.0 - size) / 2.0, uv);
	vec2 tr = step((1.0 - size) / 2.0, 1.0 - uv);

	return bl.x * bl.y * tr.x * tr.y;
}


float snap(float original, float numerator, float denominator) {
	return round(original * denominator / numerator) * numerator / denominator;
}


float map_range(float min1, float max1, float min2, float max2, float v) {
	float p = (v - min1) / (max1 - min1);
	return p * (max2 - min2) + min2;
}


vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}


void fragment() {
	vec2 uv = UV;

	// Shear
	float angle = 1.571 + (shear_angle * PI / 4.0);
	float shear_value = cos(angle) / sin(angle);
	float shear = shear_value * uv.y;

	uv.x += shear;
	uv.x -= shear_value / 2.0;

	uv.x *= 1.0 + abs(shear_value);
	uv.x -= abs(shear_value) / 2.0;


	float bar_count = float(count);
	float bar_size = 1.0 / bar_count;
	float separation_width = margin.x * bar_size;

	float shape = 0.0;

	// Calculate each segment independently
	for (int i = 0; i < count; i++) {
		float segment_start = float(i) / bar_count;
		float segment_end = float(i + 1) / bar_count;

		// How much of this segment is filled
		float segment_fill = clamp(
			(value - segment_start) / bar_size,
			0.0,
			1.0
		);

		// Segment position
		float segment_uv = (uv.x - segment_start) / bar_size;

		// Shrink the segment from its right edge
		float segment_width = segment_fill * (1.0 - margin.x);

		// Center the shrinking segment within its original space
		float segment_center = segment_start + bar_size * 0.5;

		float local_x = uv.x - segment_center;

		float segment_shape = step(
			- segment_width * 0.5,
			local_x
		) * step(
			local_x,
			segment_width * 0.5
		);

		float segment_y = square_shape(
			vec2(uv.y, uv.y),
			vec2(1.0, 1.0 - margin.y)
		);

		// Vertical bounds
		float vertical = step(margin.y * 0.5, uv.y)
			* step(uv.y, 1.0 - margin.y * 0.5);

		shape += segment_shape * vertical;
	}


	// Gradients
	float gradient_x_pos = uv.x;

	if (use_value_gradient) {
		gradient_x_pos = value;
	}

	vec4 gradient_color_x = get_gradient_color(
		gradient_x,
		gradient_x_pos
	);

	if (stepify) {
		float step_size = float(count) / 2.0;

		gradient_color_x = get_gradient_color(
			gradient_x,
			snap(gradient_x_pos, 1.0, step_size)
		);
	}


	float y = map_range(
		0.5 - (1.0 - margin.y) / 2.0,
		0.5 + (1.0 - margin.y) / 2.0,
		0.0,
		1.0,
		uv.y
	);

	if (invert) {
		y = uv.y;
		shape = 1.0 - shape;
	}

	vec4 gradient_color_y = get_gradient_color(gradient_y, y);

	vec4 gradient_color = mix(
		gradient_color_x,
		gradient_color_y,
		gradient_color_y.a
	);

	COLOR = vec4(gradient_color.rgb, clamp(shape, 0.0, 1.0));
}
