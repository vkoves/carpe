describe('UI Manager', function() {
	it('should show overlay', function()
	{
		UIManager.showOverlay();

		assert.equal($(".ui-widget-overlay:visible").length, 1);
	});

	it('should hide overlay after showing', function(done){
		UIManager.showOverlay();
		UIManager.hideOverlay(function() {
			assert.equal($(".ui-widget-overlay:visible").length, 0);
			done();
		});
	});
});
