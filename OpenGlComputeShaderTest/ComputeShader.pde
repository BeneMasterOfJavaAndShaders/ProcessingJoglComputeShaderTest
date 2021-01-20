public final class ComputeShader extends ShaderProgram {
  private int numBuffers, bufferHandles[];
  public Buffer[] buffers;

  public ComputeShader(String shaderCode, int numBuffers) {
    super(new int[]{GL4.GL_COMPUTE_SHADER}, new String[]{shaderCode});
    this.allocateBuffers(numBuffers);
  }

  void runTest() {
    boolean done = false;
    while (!done) {
      this.upload();
      this.compute();
      this.download();

      float[] out = new float[buffers[0].capacity()]; 
      ((FloatBuffer)this.buffers[0]).get(out, 0, out.length); 
      for (int i=0; i<out.length/4; i++)
        println(i + ": " + out[i*4]);
      println();
    }

    this.disposeProgram();
  }

  private void upload() {
    final int NUM_FLOATS_IN_SHADER = 4;
    final int NUM_ELEMENTS_IN_BUFFER = 64;
    final int FLOAT_SIZE_BYTES = 4;
    this.buffers[0] = Buffers.newDirectFloatBuffer(NUM_ELEMENTS_IN_BUFFER * NUM_FLOATS_IN_SHADER);
    for (int i=0; i<this.numBuffers; i++) {
      this.gl.glBindBuffer(GL4.GL_ARRAY_BUFFER, this.bufferHandles[i]); // Select the VBO, GPU memory data, to use for vertices
      this.gl.glBufferData(GL4.GL_ARRAY_BUFFER, this.buffers[i].capacity() * FLOAT_SIZE_BYTES, this.buffers[i], GL4.GL_DYNAMIC_DRAW); // copy data from CPU -> GPU memory  //target, size, data, "hint"??
      this.gl.glBindBuffer(GL4.GL_ARRAY_BUFFER, 0);
    }
  }

  private void compute() {
    this.gl.glUseProgram(programId); 
    //this.gl.glUniform1f(this.gl.glGetUniformLocation(this.programId, "delta"), 5);
    for (int i=0; i<this.numBuffers; i++)
      this.gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, i, this.bufferHandles[i]); 
    this.gl.glDispatchComputeGroupSizeARB(1, 1, 1, 8, 8, 1); 
    for (int i=0; i<this.numBuffers; i++)
      this.gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, i, 0);
    this.gl.glUseProgram(0);
  }

  private void download() {
    final int FLOAT_SIZE_BYTES = 4;
    for (int i=0; i<this.numBuffers; i++) {
      this.gl.glBindBuffer(GL4.GL_ARRAY_BUFFER, this.bufferHandles[i]); // Select the VBO, GPU memory data, to use for vertices
      this.gl.glGetBufferSubData(GL4.GL_ARRAY_BUFFER, 0, this.buffers[i].capacity() * FLOAT_SIZE_BYTES, this.buffers[i]); //target, offset, size, data
      this.gl.glBindBuffer(GL4.GL_ARRAY_BUFFER, 0);
    }
  }

  public void allocateBuffers(int numBuffers) {
    this.numBuffers = numBuffers;
    this.bufferHandles = new int[this.numBuffers];
    this.gl.glGenBuffers(this.numBuffers, bufferHandles, 0); //numberOfBuffers, *handles, ???keinPlan???
    this.buffers = new Buffer[this.numBuffers];
  }
}
