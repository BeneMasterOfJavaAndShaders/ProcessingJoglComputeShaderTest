import com.jogamp.common.nio.Buffers;
import com.jogamp.newt.opengl.GLWindow;
import com.jogamp.opengl.GL4;
import com.jogamp.opengl.DebugGL4;
import com.jogamp.opengl.TraceGL4;
import com.jogamp.opengl.GLCapabilities;
import com.jogamp.opengl.GLProfile;
import com.jogamp.opengl.GLAutoDrawable;

import java.nio.Buffer;
import java.nio.IntBuffer;
import java.nio.ByteBuffer;
import java.nio.FloatBuffer;

final String cmoputeShaderTest
  = "#version 430 core \n"
  + "#extension GL_ARB_compute_variable_group_size : enable \n"
  + "layout (local_size_variable) in; \n"        //+ "layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in; \n"

  + "struct packet {"
  + "  float val;"
  + "  float padding;"
  + "  vec2 data;"
  + "};"

  + "layout (std430, binding = 0) buffer entities {"
  + "  packet e[];"
  + "};"

  + "void main(void) {"
  + "  uvec2 globalCoords = gl_WorkGroupID.xy * gl_LocalGroupSizeARB.xy + gl_LocalInvocationID.xy;"
  + "  uvec2 globalSize = gl_NumWorkGroups.xy * gl_LocalGroupSizeARB.xy;"
  + "  uint t = globalCoords.y * globalSize.x + globalCoords.x;"
  + "  t = min(t, 63);"
  + "  e[t].val = t;"
  + "}";

ComputeShader cs;

void setup() {
  println("Started");
  surface.setVisible(false);
  cs = new ComputeShader(cmoputeShaderTest, 1);
  cs.runTest();
  println("setup done.");
}

void draw() {
}

//const uvec3 gl_WorkGroupSize
//in uvec3 gl_NumWorkGroups
//in uvec3 gl_WorkGroupID
//in uvec3 gl_LocalInvocationID
//in uvec3 gl_GlobalInvocationID
//in uint  gl_LocalInvocationIndex
