uniform    sampler2D s_Texture;
uniform lowp vec2    u_OutlineStep;
uniform lowp vec4    u_OutlineColor;

varying lowp    vec4 v_Color;
varying highp   vec2 v_TexCoord;

void main()
{
    highp vec4 texel = texture2D(s_Texture, v_TexCoord);

    lowp float a = texel.a * 4.0;
    a -= texture2D(s_Texture, v_TexCoord + vec2(u_OutlineStep.x, 0)).a;
    a -= texture2D(s_Texture, v_TexCoord + vec2(-u_OutlineStep.x, 0)).a;
    a -= texture2D(s_Texture, v_TexCoord + vec2(0, u_OutlineStep.y)).a;
    a -= texture2D(s_Texture, v_TexCoord + vec2(0, -u_OutlineStep.y)).a;
    a = clamp(a, 0.0, 1.0);

    gl_FragColor = mix(texel * v_Color, u_OutlineColor * a, a);
}