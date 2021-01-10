# Insurance-Claim-Simulation

In this report, we summarize our simulation of individual claims and its implications on year-end assets and risk of bankruptcy. Additionally, we provide recommendations to the company and considerations for future analysis.

To conduct this analysis, a few assumptions were made:
*   The probability of a customer making a claim in any one year is 10% 
*   The probability of a customer filing a claim is independent of their previous claims and independent of other customers’ claims 
*   Customers do not submit more than one claim per year 
*   The size of the claims are independent and follow a Pareto distribution with parameters alpha = 3 and Beta = 100,000

### *Simulating Insurance Claim Sizes*

In this analysis, the inversion method is used to simulate from *X*. The first step is to create a function **invpar** that calculates the inverse Pareto CDF <img src="https://render.githubusercontent.com/render/math?math=F^{-1}(u)">. The second step involves creating a function **rpar** which returns *n* simulated values from a Pareto distribution with parameters alpha and Beta. The first part of **rpar** generates *n* random values from a uniform distribution on *(0,1)*, and the second part runs these values through the **invpar** function. 

Below is a histogram of our simulated values:

![](/images/simulated-insurance-claims.png)

**NOTE:** The Pareto distribution is suitable for modeling insurance claims. Insurance claims are nonnegative and unbounded, so a support of [0,∞) is appropriate. The most important property of the Pareto distribution is that it exhibits fat tails. In insurance, one must account for the possibility of large claims. Most realizations from a Pareto distribution are relatively small, but there are still a significant number of large claims. For example, an exponential distribution is not suitable as the probability of large claims is too small. 

### *Simulating Year End Results*

In the function **assets1**, we simulate the assets at year-end by doing the following:

***Step 1.*** Simulate for each client a value 0 (no claim) or 1 (claim). After all, we assume that each client makes at most 1 claim per year. The probability of having 1 claim is given to be 0.1. To simulate one value from this discrete distribution, we simulate a value from a uniform distribution on (0,1). The {0,1} value can be simulated by plugging the result into the following:

*   <img src="https://render.githubusercontent.com/render/math?math=g(u) = 1"> if <img src="https://render.githubusercontent.com/render/math?math=u \leq 0.1">

*   <img src="https://render.githubusercontent.com/render/math?math=g(u) = 0"> if <img src="https://render.githubusercontent.com/render/math?math=u \gt 0.1">

In this step, we assume that the event of making a claim or not is independent across the clients. We sum the binary values indicating whether a client made claim to get the total number of claims (*#claims*).

***Step 2.*** The next step is to simulate the total value of the claims in a year. Using the **rpar** function, we simulate *#claims* values from a Pareto distribution with 𝛼 = 3 and 𝛽 = 100,000. In this step, we assume that the value of the claims is independent. Summing the values of these claims in a year gives the total value of claims in a year.

***Step 3.*** The assets at year-end can then be computed as:

<img src="https://render.githubusercontent.com/render/math?math=assets_1 = assets_0 %2B NC * premium - total claims">, where *NC* represents the number of clients.

The function **assets1** will then return a vector with the assets at year-end for each value of probclaim. Also, when the input premium is a vector, **assets1** returns a vector. We use the function **MCSimul** to generate many assets at year end. This function repeatedly calls assets1 and returns all results. The expected assets at year-end is the mean value of £1.24 million.

***Step 4.*** Lastly, the insurance firm is bankrupt when assets at year-end are negative. Here, we make use of the information that premiums are paid at the start of the year. Assets are therefore nonincreasing throughout the year, so bankruptcy can be assessed by considering the assets at year end. By counting the number of simulations of assets at year-end that are negative and dividing by the total number of simulations, we estimate the probability of bankruptcy at 9.8%.
