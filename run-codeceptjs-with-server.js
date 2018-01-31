const {spawn, spawnSync} = require('child_process')
const kill = require('tree-kill')
const isConnected = require('tcp-ping').probe

isConnected('localhost', 3000, (error, connected) => {
	if (!connected) {
		console.error("Rails server must be started before running acceptance tests.")
	} else {
		console.log("Starting Selenium server...")
		const server = spawn('selenium-standalone', ['start'], {stdio: 'ignore', detached: true})

		try {
			console.log("Seeding database with test data...")
			spawnSync('bundle', ['exec', 'rails', 'db:seed'], {stdio: 'inherit'})

			console.log("Running CodeceptJs...")
			spawnSync('codeceptjs', ['run', '--reporter', 'mochawesome'], {stdio: 'inherit'})

			console.log("Cleaning up database test data...")
			spawnSync('rails', ['acceptance_cleanup'], {stdio: 'inherit'})
		} finally {
			console.log("Closing Selenium server...")
			kill(server.pid)
		}
	}
})
