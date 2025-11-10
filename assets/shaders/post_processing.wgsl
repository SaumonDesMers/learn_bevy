#import bevy_core_pipeline::fullscreen_vertex_shader::FullscreenVertexOutput

#import bevy_pbr::{
    mesh_view_bindings,
    prepass_utils,
    forward_io::VertexOutput
}

@group(0) @binding(0) var screen_texture: texture_2d<f32>;
@group(0) @binding(1) var texture_sampler: sampler;
struct PostProcessSettings {
    intensity: f32,
}
@group(0) @binding(2) var<uniform> settings: PostProcessSettings;

fn get_kernel(coord: vec2<i32>) -> array<vec4<f32>, 9>
{
    return array<vec4<f32>, 9>(
        abs(textureLoad(screen_texture, coord + vec2<i32>(-1, -1), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(0, -1), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(1, -1), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(-1, 0), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(0, 0), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(1, 0), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(-1, 1), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(0, 1), 0)),
        abs(textureLoad(screen_texture, coord + vec2<i32>(1, 1), 0))
    );
}

fn get_sobel(coord: vec2<i32>) -> f32
{
    let k = get_kernel(coord);

    let edge_h = k[2] + (2. * k[5]) + k[8] - (k[0] + (2. * k[3]) + k[6]);
    let edge_v = k[0] + (2. * k[1]) + k[2] - (k[6] + (2. * k[7]) + k[8]);

    let sobel = sqrt((edge_h * edge_h) + (edge_v * edge_v));

    if (length(sobel) > 0.1)
    {
        return 1.0;
    }
    return 0.0;
}

@fragment
fn fragment(in: FullscreenVertexOutput) -> @location(0) vec4<f32>
{

    let edge = get_sobel(vec2<i32>(in.position.xy));

    if (edge > 0.9)
    {
        return vec4(0., 0., 0., 1.);
    }

//    return textureLoad(screen_texture, vec2<i32>(in.position.xy), 0);
    let normal = bevy_pbr::prepass_utils::prepass_normal(mesh.position, 0);
    return vec4(abs(normal), 1.0);
}

