#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// http://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 voronoi2( in vec2 x ) {
    vec2 n = floor(x);
    vec2 f = fract(x);

    vec2 mg, mr;
    float md = 8.0;
    for (int j= -1; j <= 1; j++) {
        for (int i= -1; i <= 1; i++) {
            vec2 g = vec2(float(i),float(j));
            vec2 o = random2( n + g );
            o = 0.5 + 0.5*sin( u_time + 6.2831*o );

            vec2 r = g + o - f;
            float d = dot(r,r);

            if( d<md ) {
                md = d;
                mr = r;
                mg = g;
            }
        }
    }

    // second pass: distance to borders

    return vec3(md, mr);
}

vec3 voronoi( in vec2 x) {
    vec2 n = floor(x);
    vec2 f = fract(x);

    vec2 c = random2(n);
    c = 0.5 + 0.5*sin( u_time + 6.2831*random2(n) );
    vec2 r3 = c - f;
    
    vec2 mg, mr;
    float md = 0.0;
    for (int j1= -1; j1 <= 1; j1++) {
        for (int i1= -1; i1 <= 1; i1++) {
            vec2 g = vec2(float(i1),float(j1));
            vec2 o = random2( n + g );
            o = 0.5 + 0.5*sin( u_time + 6.2831*o );
            vec2 r1 = g + o - f;

            md += 1.-smoothstep(0.02,0.03,length(r1));
            
            vec2 r2;
            for (int j2= -1; j2 <= 1; j2++) {
                for (int i2= -1; i2 <= 1; i2++) {
                vec2 g = vec2(float(i2),float(j2));
                vec2 o = random2( n + g );
                o = 0.5 + 0.5*sin( u_time + 6.2831 * o );
                r2 = g + o - f;
                    
                float a = 1.;
				a *= 1.-step(1.1,abs(float(j2)-float(j1)));
                a *= 1.-step(1.1,abs(float(i2)-float(i1)));

                    
                float d = 1.-smoothstep(0.,1.6,length(r2-r1));
                    
                md += (1.-smoothstep(-1.0,-0.99, dot(normalize(r1), normalize(r2)) ))*d*a;
                }
            }
        }
    }
    return vec3(md/2.);
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;
    vec3 color = vec3(0.);
	color += mix(vec3(0.077,0.115,0.190), vec3(0.042,0.110,0.245), 1.-length(st - vec2(0.5)));
    // Scale
    st *= 5.;
    
    vec3 c = voronoi(st);
    color = mix( color, vec3(0.253,0.330,0.495), c.x );

    
    
    gl_FragColor = vec4(color,1.0);
}
