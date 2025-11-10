#import bevy_pbr::{
    mesh_view_bindings::globals,
    prepass_utils,
    forward_io::VertexOutput,
}

@fragment
fn fragment(
    mesh: VertexOutput,
) -> @location(0) vec4<f32> {

    let normal = bevy_pbr::prepass_utils::prepass_normal(mesh.position, 0);
    return vec4(abs(normal), 1.0);
}
