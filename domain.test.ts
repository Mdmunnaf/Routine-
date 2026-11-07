import { describe, expect, it } from 'vitest';
import { accuracyPercent, elapsedSeconds, mockScore, nextReviewDate, progressPercent } from '../domain';

describe('study domain calculations',()=>{
  it('calculates elapsed time from timestamps and excludes pauses and breaks',()=>{
    expect(elapsedSeconds({startAt:1000,endAt:121000,pausedMs:20000,breakMs:10000})).toBe(90);
  });
  it('uses the pause timestamp while a session is paused',()=>{
    expect(elapsedSeconds({startAt:1000,pausedAt:61000,pausedMs:10000,breakMs:0},999999)).toBe(50);
  });
  it('calculates mock-test score with negative marking',()=>{
    expect(mockScore(70,20,0.25)).toBe(65);
  });
  it('handles zero-question accuracy without dividing by zero',()=>{
    expect(accuracyPercent(5,0)).toBe(0);
    expect(accuracyPercent(7,10)).toBe(70);
  });
  it('schedules revision intervals by outcome',()=>{
    const from=new Date('2026-10-01T12:00:00');
    expect(nextReviewDate(from,'Easy').getDate()).toBe(8);
    expect(nextReviewDate(from,'Difficult').getDate()).toBe(4);
    expect(nextReviewDate(from,'Forgotten').getDate()).toBe(2);
  });
  it('returns zero for empty syllabus progress',()=>{
    expect(progressPercent(0,0)).toBe(0);
    expect(progressPercent(3,4)).toBe(75);
  });
});
