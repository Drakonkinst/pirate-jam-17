shader_type spatial;
//Simple 3D shader to create a force-field effect inspired by Faultless Defense from Guilty Gear Xrd.
//In summary, it takes logic used for simple rim lighting and uses it to create the alpha instead.

render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform vec4 emission_color : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float emission_amount: hint_range(0.0, 16.0) = 5.0f; 
uniform float rim_steepness : hint_range(0.0f, 16.0f) = 3.0f; //higher values mean a smaller rim.
uniform vec3 uv_scale;
uniform vec3 uv_offset;

void vertex() {
	UV=UV*uv_scale.xy+uv_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
    float variance = 1.0;
	EMISSION = emission_color.rgb * (emission_amount + sin(TIME * 5.0) * 0.5);
	float NdotV = dot(NORMAL, VIEW);
	float rim_light = pow(1.0 - NdotV, rim_steepness);
	ALPHA = rim_light * emission_color.a / PI;
}