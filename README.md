# Insurance-Claim-Simulation

[Insert brief overview of the analysis]


## Simulating Insurance Claim Sizes

We use the inversion method to simulate from *X*. Our first step is to create a function **invpar** that calculates the inverse Pareto CDF <img src="https://render.githubusercontent.com/render/math?math=F^{-1}(u)">. We then create a function **rpar** which returns *n* simulated values from a Pareto distribution with parameters α, β. The first part of the function generates *n* random values from a uniform distribution on *(0,1)*, and the second part runs these values through the **invpar** function. 

Below is a histogram of our simulated values:

![](/images/simulated-insurance-claims.png)

## 

