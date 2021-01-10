# Insurance-Claim-Simulation

[Insert brief overview of the analysis]


### *Simulating Insurance Claim Sizes*

In this analysis, the inversion method is used to simulate from *X*. The first step is to create a function **invpar** that calculates the inverse Pareto CDF <img src="https://render.githubusercontent.com/render/math?math=F^{-1}(u)">. The second step involves creating a function **rpar** which returns *n* simulated values from a Pareto distribution with parameters α, β. The first part of **rpar** generates *n* random values from a uniform distribution on *(0,1)*, and the second part runs these values through the **invpar** function. 

Below is a histogram of our simulated values:

![](/images/simulated-insurance-claims.png)

*Why use the Pareto distribution to simulate individual insurance claims?* Note that insurance claims are nonnegative and unbounded, so a support of [0,∞) is appropriate. The most important property of the Pareto distribution is that it exhibits fat tails. In insurance, one must account for the possibility of large claims. Most realizations from a Pareto distribution are relatively small, but there are still a significant number of large claims. For example, an exponential distribution is not suitable as the probability of large claims is too small. 

### *Simulating Year End Results*

In the function **assets1**, we simulate the assets at year-end by doing the following:

*Step 1.* Simulate for each client a value 0 (no claim) or 1 (claim). After all, we assume that each client makes at most 1 claim per year. The probability of having 1 claim is given to be 0.1. To simulate one value from this discrete distribution, we simulate a value from a uniform distribution on (0,1). The {0,1} value can be simulated by plugging the result into the following:

<img src="https://render.githubusercontent.com/render/math?math=g(u) = 1 if u \leq 0.1">

<img src="https://render.githubusercontent.com/render/math?math=F^{-1}(u)">

In this step, we assume that the event of making a claim or not is independent across the clients. We sum the binary values indicating whether a client made claim to get the total number of claims (#claims).
