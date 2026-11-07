import { openDB } from 'idb';
const DB_NAME='preppilot-local', STORE='app-state';
async function db(){return openDB(DB_NAME,1,{upgrade(d){if(!d.objectStoreNames.contains(STORE))d.createObjectStore(STORE)}})}
export async function readState<T>(key:string, fallback:T):Promise<T>{try{const d=await db();return (await d.get(STORE,key)) ?? fallback}catch{return fallback}}
export async function writeState<T>(key:string,value:T){try{const d=await db();await d.put(STORE,value,key)}catch{try{localStorage.setItem('preppilot:'+key,JSON.stringify(value))}catch{}}}
