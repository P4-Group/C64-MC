const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');

async function executeCommand(command, testFile) {
  return new Promise((resolve, reject) => {
    const fullCommand = `opam exec -- dune exec C64MC "${testFile}" -T`;
    exec(fullCommand, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing command: ${fullCommand}`);
        console.error(stderr);
        reject(error);
      } else {
        console.log(stdout);
        resolve();
      }
    });
  });
}

async function runTests() {
  const testDir = 'tests';
  try {
    const files = await fs.readdir(testDir);
    for (const file of files) {
      const filePath = path.join(testDir, file);
      const stats = await fs.stat(filePath);
      if (stats.isFile()) {
        console.log(`Running test: ${filePath}`);
        await executeCommand(`opam exec -- dune exec C64MC`, filePath); // Pass the testFile separately
      }
    }
  } catch (error) {
    console.error('Error during test execution:', error);
    process.exit(1);
  }
}

runTests();
