const child_process = require('child_process')
const phantomjs = require('phantomjs-prebuilt')
const pinger = require('tcp-ping')

pinger.ping({address: 'localhost', port: 3000, attempts: 1}, (error, alive) => {
	if (alive) {
		runCodeceptJsAndPhantomJs()
	} else {
		console.error("You must start the rails server before running acceptance tests.")
		process.exit(1)
	}
})

function runCodeceptJsAndPhantomJs() {
	phantomjs.run('--webdriver=4444').then(phantom => {
		child_process.exec('npm run codeceptjs --silent', (error, stdout, stderr) => {
			phantom.kill()

			if (stdout) { console.log(stdout) }
			if (stderr) {
				console.error("CodeceptJS Error:")
				console.error(stderr)
				process.exit(1)
			}
		})
	}).catch(error => {
		console.error("PhantomJS Error:")
		console.error(error)
		process.exit(1)
	})
}