# About

> describe project in own words

# High

- Found a DoS 
- Reentrancy in `PuppyRaffle::refund`
- Weak Randomness in `PuppyRaffle::selectWinner` in the winner and rarity functionality
- Unsafe Casting and Intger Overflow in `PuppyRaffle::selectWinner`
- Mishandling of ETH in `PuppyRaffle::withdrawFees`

# Informationals 

> bad variable names (add i_ or s_, or CAPITALS)
`PuppyRaffle::entranceFee` is immutable, and should be `i_entranceFee`, or `ENTRANCE_FEE`