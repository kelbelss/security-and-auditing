# TSwap Audit Notes

**What is TSwap?**

- permissionless way for users to swap assets between each other at a fair price
- a DEX (decentralised asset/token exchange)
- known as an AMM as it uses ‘pools’ of assets, and not a normal ‘order book’

## Invariant is `x * y = k`

y = Token Balance Y
x = Token Balance X
x * y = k
x * y = (x + ∆x) * (y − ∆y)
∆x = Change of token balance X
∆y = Change of token balance Y
β = (∆y / y)
α = (∆x / x)

**Final invariant equation without fees:**
∆x = (β/(1-β)) * x
∆y = (α/(1+α)) * y

**Invariant with fees**
ρ = fee (between 0 & 1, aka a percentage)
γ = (1 - p) (pronounced gamma)
∆x = (β/(1-β)) * (1/γ) * x
∆y = (αγ/1+αγ) * y