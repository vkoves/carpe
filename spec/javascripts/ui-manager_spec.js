describe('UI Manager', () => {
  it('should show overlay', () => {
    UIManager.showOverlay();

    expect($('.ui-widget-overlay:visible').length).to.equal(1);
  });

  it('should hide overlay after showing', done => {
    UIManager.showOverlay();
    UIManager.hideOverlay(() => {
      expect($('.ui-widget-overlay:visible').length).to.equal(0);
      done();
    });
  });
});
