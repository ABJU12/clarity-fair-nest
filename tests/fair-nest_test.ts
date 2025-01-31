import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can list a property",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("fair-nest", "list-property", [
        types.utf8("Beach House"),
        types.utf8("Beautiful beachfront property"),
        types.uint(100),
        types.uint(500)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result, '(ok u1)');
  }
});

Clarinet.test({
  name: "Ensure user can book a property",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    // First list a property
    let block = chain.mineBlock([
      Tx.contractCall("fair-nest", "list-property", [
        types.utf8("Beach House"),
        types.utf8("Beautiful beachfront property"),
        types.uint(100),
        types.uint(500)
      ], wallet_1.address)
    ]);
    
    // Then try to book it
    block = chain.mineBlock([
      Tx.contractCall("fair-nest", "book-property", [
        types.uint(1),
        types.uint(1000),
        types.uint(1003)
      ], wallet_2.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.receipts[0].result, '(ok u1)');
  }
});
