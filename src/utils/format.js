export const niceNum = (num) => {
  if (!num) { return num; }
  if (num > 999 && num < 1000000) {
    let back = num % 1000;
    if (back < 10) {
      back = `00${back}`
    } else if (back < 100) {
      back = `0${back}`
    }
    return `${Math.floor(num / 1000)},${back}`;
  }
  return `${num}`
}
