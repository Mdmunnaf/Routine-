export type SessionTiming = { startAt:number; endAt?:number; pausedAt?:number; pausedMs:number; breakMs:number };
export function elapsedSeconds(session:SessionTiming, now=Date.now()):number {
  const end=session.endAt ?? session.pausedAt ?? now;
  return Math.max(0,Math.floor((end-session.startAt-session.pausedMs-session.breakMs)/1000));
}
export function mockScore(correct:number, incorrect:number, negativePerWrong=0):number {
  return Math.max(0,correct)-Math.max(0,incorrect)*Math.max(0,negativePerWrong);
}
export function accuracyPercent(correct:number,total:number):number {
  return total>0?Math.round(Math.max(0,correct)/total*100):0;
}
export function nextReviewDate(from:Date, outcome:'Easy'|'Difficult'|'Forgotten', intervals=[1,3,7,14,30]):Date {
  const days=outcome==='Easy'?(intervals[2]??7):outcome==='Difficult'?(intervals[1]??3):(intervals[0]??1);
  const result=new Date(from); result.setDate(result.getDate()+days); return result;
}
export function progressPercent(completed:number,total:number):number {
  return total>0?Math.round(Math.max(0,completed)/total*100):0;
}
