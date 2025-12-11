export function compareTime(timeString1: string, timeString2: string): boolean {
  const dateTime1 = new Date(timeString1);
  const dateTime2 = new Date(timeString2);

  return dateTime1.getTime() > dateTime2.getTime();
}

export default compareTime;
