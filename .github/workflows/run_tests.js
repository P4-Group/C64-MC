const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process');

async function executeCommand(program, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(program, args);
    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => {
      stdout += data;
    });

    child.stderr.on('data', (data) => {
      stderr += data;
    });

    child.on('close', (code) => {
      if (code === 0) {
        console.log(stdout);
        resolve();
      } else {
        console.error(`Error executing command: ${program} ${args.join(' ')}`);
        console.error(stderr);
        reject(new Error(`Command failed with exit code ${code}`));
      }
    });

    child.on('error', (err) => {
      console.error(`Error spawning command: ${program} ${args.join(' ')}`);
      console.error(err);
      reject(err);
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
        const program = 'opam';
        const args = ['exec', '--', 'dune', 'exec', 'C64MC', filePath, '-T'];
        await executeCommand(program, args);
      }
    }
  } catch (error) {
    console.error('Error during test execution:', error);
    process.exit(1);
  }
}

runTests();
