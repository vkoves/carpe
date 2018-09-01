describe('UI Manager', function() {
	it('should show overlay', function()
	{
		UIManager.showOverlay();

		expect($(".ui-widget-overlay:visible").length).to.equal(1);
	});

	it('should hide overlay after showing', function(done){
		UIManager.showOverlay();
		UIManager.hideOverlay(function() {
			expect($(".ui-widget-overlay:visible").length).to.equal(0);
			done();
		});
	});
});
