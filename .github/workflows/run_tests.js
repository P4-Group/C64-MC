const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');

async function runTests() {
  const testDir = 'tests';
  try {
    const files = await fs.readdir(testDir);
    for (const file of files) {
      const filePath = path.join(testDir, file);
      const stats = await fs.stat(filePath);
      if (stats.isFile()) {
        console.log(`Running test: ${filePath}`);
        const command = `opam exec -- dune exec C64MC "${filePath}" -T`;
        await executeCommand(command);
      }
    }
  } catch (error) {
    console.error('Error during test execution:', error);
    process.exit(1);
  }
}

async function executeCommand(command) {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing command: ${command}`);
        console.error(stderr);
        reject(error);
      } else {
        console.log(stdout);
        resolve();
      }
    });
  });
}

runTests();
