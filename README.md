# Insurance-Claim-Simulation

[Insert brief overview of the analysis]


## Simulating Insurance Claim Sizes

A brief summary of our methodology is as follows:

***Step 1.*** We use the inversion method to simulate from <img src="https://render.githubusercontent.com/render/math?math=X">. Our first step is to create a function
*invpar* that calculates the inverse Pareto CDF <img src="https://render.githubusercontent.com/render/math?math=F^{-1}(\mu)"> as defined above.

<img src="https://render.githubusercontent.com/render/math?math=e^{i \pi} = -1">





***Step 2.*** We create a function rpar which returns n simulated values from a Pareto distribution
with parameters α, β. The first part of the function generates n random values from a uniform


## 

