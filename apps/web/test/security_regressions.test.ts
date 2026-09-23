import { describe, it, expect, vi, afterEach } from 'vitest';
import { consumeBankOAuth, beginBankOAuth } from '../src/services/bankOAuth';
import { browserStorage, getStorageError } from '../src/store/browserStorage';
import { useSubscriptionStore } from '../src/store/useSubscriptionStore';
const data = { id: 'valid-test', name: 'Service', amount: 10, category: 'General', cycle: 'Monthly', startDate: '2026-09-12' };
function memoryStorage() { const map = new Map<string,string>(); return {getItem:(k:string)=>map.get(k)||null,setItem:(k:string,v:string)=>map.set(k,v),removeItem:(k:string)=>map.delete(k)}; }
afterEach(() => vi.unstubAllGlobals());
describe('OAuth transaction and local persistence defenses', () => {
  it.each([null,'wrong'])('rejects absent or mismatched state %s', value => {
    const sessionStorage = memoryStorage(); vi.stubGlobal('sessionStorage', sessionStorage);
    sessionStorage.setItem('subflow-bank-oauth', JSON.stringify({state:'expected',verifier:'a'.repeat(43),createdAt:Date.now()}));
    expect(()=>consumeBankOAuth(value)).toThrow();
    expect(sessionStorage.getItem('subflow-bank-oauth')).toBeNull();
  });
  it('accepts one PKCE transaction, rejects replay and expired transactions', async () => {
    const sessionStorage = memoryStorage(); vi.stubGlobal('sessionStorage', sessionStorage);
    vi.stubGlobal('window', {location:{origin:'https://test.example',pathname:'/app'}});
    const url = new URL(await beginBankOAuth('bank-test'));
    expect(url.searchParams.get('code_challenge_method')).toBe('S256');
    expect(consumeBankOAuth(url.searchParams.get('state')).verifier).toHaveLength(43);
    expect(()=>consumeBankOAuth(url.searchParams.get('state'))).toThrow();
    sessionStorage.setItem('subflow-bank-oauth', JSON.stringify({state:'expired',verifier:'a'.repeat(43),createdAt:Date.now()-601000}));
    expect(()=>consumeBankOAuth('expired')).toThrow();
  });
  it('purges a legacy credential on read while preserving subscriptions', () => {
    const localStorage = memoryStorage(); vi.stubGlobal('window', {localStorage,location:{pathname:'/app'}});
    localStorage.setItem('subflow-storage-v2', JSON.stringify({state:{subscriptions:[data],googleAccount:{accessToken:'legacy-fixture'}}}));
    browserStorage.getItem('subflow-storage-v2');
    expect(localStorage.getItem('subflow-storage-v2')).not.toContain('legacy-fixture');
    expect(localStorage.getItem('subflow-storage-v2')).toContain('valid-test');
  });
  it('removes a credential-bearing legacy snapshot when sanitizing cannot be written', () => {
    let stored: string | null = JSON.stringify({state:{subscriptions:[data],googleAccount:{accessToken:'legacy-fixture'}}});
    const localStorage = {getItem:()=>stored,setItem:()=>{throw new Error('blocked');},removeItem:()=>{stored=null;}};
    vi.stubGlobal('window', {localStorage,location:{pathname:'/app'},dispatchEvent:vi.fn()});
    expect(browserStorage.getItem('subflow-storage-v2')).toBeNull();
    expect(stored).toBeNull();
  });
  it('reports quota errors rather than claiming the in-memory change was undone', () => {
    vi.stubGlobal('window', {localStorage:{setItem:()=>{throw new Error('QuotaExceededError');}},location:{pathname:'/app'}});
    expect(()=>browserStorage.setItem('subflow-storage-v2','{}')).not.toThrow();
    expect(getStorageError()).toContain('Sauvegarde locale impossible');
  });
  it('does not read or write real storage from demo', () => {
    const localStorage = {getItem:vi.fn(),setItem:vi.fn()}; vi.stubGlobal('window',{localStorage,location:{pathname:'/demo'}});
    expect(browserStorage.getItem('subflow-storage-v2')).toBeNull(); browserStorage.setItem('subflow-storage-v2','demo');
    expect(localStorage.getItem).not.toHaveBeenCalled(); expect(localStorage.setItem).not.toHaveBeenCalled();
  });
  it('imports atomically and does not duplicate repeated imports', () => {
    useSubscriptionStore.setState({subscriptions:[]});
    expect(()=>useSubscriptionStore.getState().importSubscriptions([data,{...data,id:'bad',amount:-3}])).toThrow();
    expect(useSubscriptionStore.getState().subscriptions).toHaveLength(0);
    expect(useSubscriptionStore.getState().importSubscriptions([data])).toBe(1);
    expect(useSubscriptionStore.getState().importSubscriptions([data])).toBe(0);
  });
  it('does not publish an import when its durable snapshot cannot be written', () => {
    const localStorage = {getItem:()=>null,setItem:()=>{throw new Error('QuotaExceededError');},removeItem:vi.fn()};
    vi.stubGlobal('window', {localStorage,location:{pathname:'/app'},dispatchEvent:vi.fn()});
    useSubscriptionStore.setState({subscriptions:[]});
    expect(()=>useSubscriptionStore.getState().importSubscriptions([data])).toThrow('Sauvegarde locale impossible');
    expect(useSubscriptionStore.getState().subscriptions).toEqual([]);
  });
  it('does not publish a cloud restoration when its durable snapshot cannot be written', () => {
    const original = {...data,id:'original'};
    const localStorage = {getItem:()=>null,setItem:(key:string)=>{if(key==='subflow-storage-v2') throw new Error('QuotaExceededError');},removeItem:vi.fn()};
    vi.stubGlobal('window', {localStorage,location:{pathname:'/app'},dispatchEvent:vi.fn()});
    useSubscriptionStore.setState({subscriptions:[original]});
    expect(()=>useSubscriptionStore.getState().restoreFromCloud({subscriptions:[data]})).toThrow('Sauvegarde locale impossible');
    expect(useSubscriptionStore.getState().subscriptions).toEqual([original]);
  });
  it('restores an empty snapshot rather than resurrecting deleted records', () => {
    useSubscriptionStore.setState({subscriptions:[data]});
    useSubscriptionStore.getState().restoreFromCloud({subscriptions:[]});
    expect(useSubscriptionStore.getState().subscriptions).toEqual([]);
  });
});
