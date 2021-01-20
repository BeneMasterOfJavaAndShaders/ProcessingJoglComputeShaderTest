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
