# Insurance-Claim-Simulation

[Insert brief overview of the analysis]


### *Simulating Insurance Claim Sizes*

In this analysis, the inversion method is used to simulate from *X*. The first step is to create a function **invpar** that calculates the inverse Pareto CDF <img src="https://render.githubusercontent.com/render/math?math=F^{-1}(u)">. The second step involves creating a function **rpar** which returns *n* simulated values from a Pareto distribution with parameters α, β. The first part of **rpar** generates *n* random values from a uniform distribution on *(0,1)*, and the second part runs these values through the **invpar** function. 

Below is a histogram of our simulated values:

![](/images/simulated-insurance-claims.png)

## 

