const {exec, execSync} = require('child_process')
const kill = require('tree-kill')
const isConnected = require('tcp-ping').probe

isConnected('localhost', 3000, (error, connected) => {
	if (!connected) {
		console.error("Rails server must be started before running acceptance tests.")
	} else {
		console.log("Starting Selenium server...")
		const server = exec('selenium-standalone start', {stdio: 'inherit'})

		console.log("Seeding database with test data...")
		execSync('bundle exec rails db:seed', {stdio: 'inherit'})

		console.log("Running CodeceptJs...")
		execSync('codeceptjs run --reporter mochawesome', {stdio: 'inherit'})

		console.log("Closing Selenium server...")
		kill(server.pid)

		console.log("Cleaning up database test data...")
		execSync('rails acceptance_cleanup', {stdio: 'inherit'})
	}
})
