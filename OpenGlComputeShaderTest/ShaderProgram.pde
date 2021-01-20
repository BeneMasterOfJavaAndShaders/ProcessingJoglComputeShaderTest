public class ShaderProgram {
  protected final GL4 gl;
  protected final int programId, shaderIds[];

  public ShaderProgram(int[] shaderTypes, String[] shaderCodes) {
    this.gl = getGL4(false);
    this.programId = this.gl.glCreateProgram();
    this.shaderIds = new int[shaderTypes.length];
    for (int i=0; i<shaderTypes.length; i++)
      this.shaderIds[i] = this.gl.glCreateShader(shaderTypes[i]);
    for (int i=0; i<shaderTypes.length; i++)
      this.compileShader(this.shaderIds[i], shaderCodes[i]);
    this.linkProgram();
  }

  public void compileShader(int shaderId, String code) {
    if (shaderId == 0)
      this.stop("Error creating shader. Shader id is zero."); 
    this.gl.glShaderSource(shaderId, 1, new String[] { code }, null); 
    this.gl.glCompileShader(shaderId); 
    this.validateShader(shaderId);
  }

  public void linkProgram() {
    for (int i=0; i<this.shaderIds.length; i++)
      this.gl.glAttachShader(this.programId, this.shaderIds[i]); 
    this.gl.glLinkProgram(this.programId); 
    this.validateProgram();
  }

  public void disposeProgram() {
    for (int i=0; i<this.shaderIds.length; i++) {
      this.gl.glDetachShader(this.programId, this.shaderIds[i]);
      this.gl.glDeleteShader(this.shaderIds[i]);
    }
    this.gl.glDeleteProgram(this.programId);
  }

  //-------------------------------------------- Validation and Error Handling ----------------------------------------

  private void validateShader(int shaderId) {
    IntBuffer intBuffer = IntBuffer.allocate(1); 
    this.gl.glGetShaderiv(shaderId, GL4.GL_COMPILE_STATUS, intBuffer); 
    if (intBuffer.get(0) != 1) {
      this.gl.glGetShaderiv(shaderId, GL4.GL_INFO_LOG_LENGTH, intBuffer); 
      int size = intBuffer.get(0); 
      if (size > 0) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(size); 
        this.gl.glGetShaderInfoLog(shaderId, size, intBuffer, byteBuffer); 
        println(new String(byteBuffer.array()));
      }
      this.stop("Error compiling shader!");
    }
  }

  private void validateProgram() {
    IntBuffer intBuffer = IntBuffer.allocate(1); 
    this.gl.glGetProgramiv(this.programId, GL4.GL_LINK_STATUS, intBuffer); 
    if (intBuffer.get(0) != 1) {
      this.gl.glGetProgramiv(this.programId, GL4.GL_INFO_LOG_LENGTH, intBuffer); 
      int size = intBuffer.get(0); 
      if (size > 0) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(size); 
        this.gl.glGetProgramInfoLog(this.programId, size, intBuffer, byteBuffer); 
        System.out.println(new String(byteBuffer.array()));
      }
      this.stop("Error linking shader program!");
    }
    
    this.gl.glValidateProgram(this.programId); 
    intBuffer = IntBuffer.allocate(1); 
    this.gl.glGetProgramiv(this.programId, GL4.GL_VALIDATE_STATUS, intBuffer); 
    if (intBuffer.get(0) != 1) {
      this.gl.glGetProgramiv(this.programId, GL4.GL_INFO_LOG_LENGTH, intBuffer); 
      int size = intBuffer.get(0); 
      if (size > 0) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(size); 
        this.gl.glGetProgramInfoLog(this.programId, size, intBuffer, byteBuffer); 
        println(new String(byteBuffer.array()));
      }
      this.stop("Error validating shader program!");
    }
  }

  public void stop(String msg) {
    this.gl.getContext().destroy(); 
    System.out.println("Stop: "+msg);
  }
}

GL4 getGL4(boolean debug) {
  final GLCapabilities caps = new GLCapabilities(GLProfile.get(GLProfile.GL4));

  GLAutoDrawable glWindow = GLWindow.create(caps);
  ((GLWindow)glWindow).setVisible(true);
  ((GLWindow)glWindow).setSize(1, 1);
  if (debug)
    glWindow.setGL(new TraceGL4(new DebugGL4(glWindow.getGL().getGL4()), System.out));
  glWindow.getContext().makeCurrent();
  return glWindow.getGL().getGL4();
}
