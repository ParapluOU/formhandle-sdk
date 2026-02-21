import * as readline from 'readline/promises';

export async function ask(question: string): Promise<string> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  try {
    const answer = await rl.question(question);
    return answer.trim();
  } finally {
    rl.close();
  }
}

export async function confirm(question: string): Promise<boolean> {
  const answer = await ask(`${question} (y/N) `);
  return answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes';
}
