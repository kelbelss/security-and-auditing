# About

> describe project in own words

# High

- Found a DoS 
- Reentrancy in `PuppyRaffle::refund`
- Weak Randomness in `PuppyRaffle::selectWinner`

# Informationals 

> bad variable names (add i_ or s_, or CAPITALS)
`PuppyRaffle::entranceFee` is immutable, and should be `i_entranceFee`, or `ENTRANCE_FEE`