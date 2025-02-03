# About

> describe project in own words

# High

- Found a DoS in `PuppyRaffle::enterRaffle`
- Reentrancy in `PuppyRaffle::refund`
- Weak Randomness in `PuppyRaffle::selectWinner` in the winner and rarity functionality
- Unsafe Casting and Intger Overflow in `PuppyRaffle::selectWinner`
- Mishandling of ETH in `PuppyRaffle::withdrawFees`
- Functions missing events?
- `PuppyRaffle::_isActivePlayer` is not used - no impact or liklihood but it's a waste of gas and is clutter

# Medium

- Centralised (always include for private audits)

# Informationals 

> bad variable names (add i_ or s_, or CAPITALS)
`PuppyRaffle::entranceFee` is immutable, and should be `i_entranceFee`, or `ENTRANCE_FEE`
- Stop using literals (magic numbers), use constants
- Add index fields to events

# Gas

- Constants that should be declared as much 
- Too many storage calls, rather declare a variable 