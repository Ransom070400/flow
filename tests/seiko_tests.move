#[test_only]
module 0xYourAddress::simple_token_transfer_with_history_tests {
    use 0xYourAddress::simple_token_transfer_with_history;
    use sui::coin::{Self, TreasuryCap};
    use sui::tx_context::TxContext;
    use sui::transfer;

    #[test]
    fun test_token_transfer_with_history() {
        // Initialize context and addresses
        let mut ctx = tx_context::dummy();
        let sender = ctx.sender();
        let recipient = @0x1;

        // Initialize the token and history table
        simple_token_transfer_with_history::init(&mut ctx);

        // Mint some tokens
        let treasury = borrow_global<TreasuryCap<simple_token_transfer_with_history::MY_TOKEN>>(sender);
        simple_token_transfer_with_history::mint(&treasury, 1000, &mut ctx);

        // Transfer tokens
        simple_token_transfer_with_history::transfer(recipient, 100, &mut ctx);

        // Get transaction history
        let history = simple_token_transfer_with_history::get_transaction_history(sender);

        // Check if the transaction history is correct
        assert!(vector::length(&history) == 1, 1);
        let txn = vector::borrow(&history, 0);
        assert!(txn.sender == sender, 2);
        assert!(txn.recipient == recipient, 3);
        assert!(txn.amount == 100, 4);
    }
}
