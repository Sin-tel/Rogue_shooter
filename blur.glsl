// adapted from http://www.youtube.com/watch?v=qNM0k522R7o
// blur kernel from http://dev.theomader.com/gaussian-kernel-calculator/
//#extension GL_EXT_gpu_shader4 : require

extern vec2 size;
extern int samples = 9; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 1.0; // lower = smaller glow, better quality
extern number time = 0;


uniform float weight[5] = float[] (0.20236, 0.179044, 0.124009, 0.067234, 0.028532);

float getWeight(int x,int y){
  if (x<0) {
    x = -x;
  }
  if (y<0) {
    y = -y;
  }
  return weight[x]*weight[y];
}

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{

  vec4 sum = vec4(0);
  int diff = (samples - 1) / 2;
  vec2 sizeFactor = vec2(1) / size * quality;
  
  for (int x = -diff; x <= diff; x++)
  {
    for (int y = -diff; y <= diff; y++)
    {
      vec2 offset = vec2(x, y) * sizeFactor;
      vec4 t = Texel(tex, tc + offset);
      //t = max(vec4(0),t-0.2)*1.2;
      t = t*t*1.6;
      //t = t*1.1;
     // t = t*t*t*2.3;
      sum += t*getWeight(x,y);
    }
  }

  vec4 c = sum * colour * (0.8+0.2*sin(tc.y*30 + time*5));


  return c;
}

