# R Appendix

# Clear working directory
rm(list=ls())

# Install relevant packages (if necessary)
# install.packages("ggplot2")

# Load relevant packages
library(ggplot2)

# Define relevant inputs
init_assets <- 250000
nclient <- 1000
premium <- 6000
probclaim <- 0.1
alpha <- 3
beta <- 100000

# Set seed so that simulation results are replicable
set.seed(1)

###########################################################
###################### Question 1C ########################
###########################################################

# Write a function to calculate the inverse of the Pareto CDF
invpar <- function(u, a, b) {
  m <- (1 - u) ^ (1 / a)
  x <- (b / m) - b
  return(x)
}

# Write a function that uses the inversion method to simulate
# the values drawn from X
rpar <- function(n, a, b) {
  
  # Make sure that inputs meet assumptions for alpha, beta
  if(a <= 0 | b <= 0) {
    print("Invalid input")
    return(0)
  }
  
  # Generate n random values from Unif(0, 1)
  u <- runif(n)
  
  # Run these values through the 'invpar' function
  x <- invpar(u, a, b)
  
  return(x)
}

# Simulate 10,000 values drawn from X
n <- 10000
x <- rpar(n, alpha, beta)

# Write a function to calculate the true density function
density <- function(z) {
  (alpha * (beta ^ alpha)) / ((z + beta) ^ (alpha + 1))
}

# Get a sense of the distribution of simulated values from X
summary(x)

# Add x to a dataframe so it will work with ggplot
dfr <- data.frame(x)

# NOTE: For aesthetic reasons, we will set upper xlim = 500,000
sum(x<500000)/length(x) # 0.9962
# Our histogram will still include over 99.5% of the observations

# Create ggplot
ggplot(dfr, aes(x = x)) +
  
  # Add a histogram of 10,000 values drawn from X
  geom_histogram(aes(y = ..density..), bins = 100, colour = "black", fill = "white") +
  
  # Superimpose the true density function
  stat_function(fun = density, col = "red", size = 1) +
  
  # Adjust the x-axis limits
  xlim(0, 500000) +
  
  # Add axis titles
  ylab("Density") + 
  xlab("Simulated Insurance Claim Sizes (£)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

###########################################################
####################### Question 2 ########################
###########################################################

### (1) Simulating assets after 1 year

# Write a function to estimate the assets at year end
assets1 <- function(init_assets, premium, nclient, probclaim, a, b) {
  
  # Simulate for each client a value 0 (no claim) or 1 (claim)
  u = runif(nclient)
  
  # Calculate the number of claims per year
  nclaim = sapply(probclaim, function(x){sum(u <= x)})
  
  # Calculate the total value of claims per year
  tot_claims = sapply(nclaim, function(x){sum(rpar(x, a, b))})
  
  # Calculate the assets at year end
  assets1 = init_assets + premium * nclient - tot_claims
  
  return(assets1)
}

# Write a function to generate a large number of assets at year end
MCsimul <- function(B, init_assets, premium, nclient, probclaim, a, b) {
  
  # Generate the first column of assets at year end 
  assets <- assets1(init_assets, premium, nclient, probclaim, a, b)
  
  # Loop through B-1 more times to calculate assets at year end and
  # add those columns to the 'assets' matrix
  for(i in 2:B){
    assets <- rbind(assets, assets1(init_assets, premium, nclient, probclaim, a, b))
  }
  
  return(assets)
}

# Simulate assets of the company at year end 10,000 times
B <- 10000
MC <- MCsimul(B, init_assets, premium, nclient, probclaim, alpha, beta)

# Calculate the expected assets at year end 
summary(MC / 1000000)

# Calculate the probability of bankruptcy at year end
sum(MC < 0) / B * 100

###########################################################

### (2) Long-run probability of bankruptcy

# Write a function to simulate assets of the company after k years
MCsimul_kyear <- function(B, init_assets, premium, nclient, probclaim, a, b, k){
  
  # Define starting values/vectors
  assets = init_assets
  pbankrupt <- c()
  
  # Simulate assets of the company at year end 10,000 times
  assets <- MCsimul(B, init_assets, premium, nclient, probclaim, alpha, beta)
  
  # Calculate number of firms that went bankrupt after year 1
  bankrupt <- sum(assets < 0)
  
  # Calculate probability of bankruptcy after year 1
  pbankrupt[1] <- bankrupt / B
  
  # Calculate number of firms that are still operating after year 1
  nalive <- B - bankrupt
  
  # Filter out the assets of all bankrupt companies
  assets <- assets[assets >= 0]
  
  # Loop through k-1 more times, repeating all the previous steps
  for(i in 2:k){
    MC <- MCsimul(nalive, 0, premium, nclient, probclaim, alpha, beta)
    assets <- assets + MC
    bankrupt <- sum(assets < 0)
    pbankrupt[i] <- bankrupt / nalive
    nalive <- nalive - bankrupt
    assets <- assets[assets >= 0]
  }
  
  return(list(assets, pbankrupt))
}

# Simulate assets of the company after 5 years
MC5 <- MCsimul_kyear(B, init_assets, premium, nclient, probclaim, alpha, beta, 5)

# Display probability of bankruptcy for years 1 to 5
MC5[[2]]*100

###########################################################

### (3) Varying number of clients

# Generate a vector of clients 1000, 1100, ..., 2500
nclients <- seq(1000, 2500, by=100)

# Define empty vectors assets_end and probbankrupt
assets_end <- c()
probbankrupt <- c()

# Simulate assets at year end for each value of nclients
for(i in 1:length(nclients)){
  
  # Simulate assets of the company at year end 10,000 times
  MC <- MCsimul(B, init_assets, premium, nclients[i], probclaim, alpha, beta)
  
  # Calculate expected assets at year end and store in vector
  assets_end[i] <- mean(MC) / 1000000
  
  # Calculate probability of bankruptcy at year end and store in vector
  probbankrupt[i] <- (sum(MC<0)/B) * 100
}

# Add nclients, assets_end and probbankrupt to a dataframe 
# so that it is compatible with ggplot
dfr <- data.frame(nclients, assets_end, probbankrupt)

# Create ggplot
ggplot(dfr, aes(x=nclients, y=assets_end)) +
  
  # Add markers to show bankrupt_premium vs. premiums
  geom_point(size=4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Add axis titles
  xlab("Number of Clients") +
  ylab("Expected Assets (£ Millions)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

# Create ggplot
ggplot(dfr, aes(x=nclients, y=probbankrupt)) +
  
  # Add markers to show bankrupt_premium vs. premiums
  geom_point(size=4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Add axis titles
  xlab("Number of Clients") +
  ylab("Probability of Bankruptcy (%)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

###########################################################
####################### Question 3A #######################
###########################################################

# Generate a vector of premiums 5500, 5750, 6000, ..., 8000
premiums <- seq(5500, 8000, by=250)

# Simulate assets of company at year end 10,000 times
MCpremium <- MCsimul(B, init_assets, premiums, nclient, probclaim, alpha, beta)

# Calculate the expected assets at year end
# Divide by 1 million for aesthetic purposes
means_premium <- colMeans(MCpremium) / 1000000

# Calculate the probability of bankruptcy at year end
bankrupt_premium <- vector()
for(i in 1:length(premiums)) {
  bankrupt_premium[i] <- sum(MCpremium[,i] < 0) / nrow(MCpremium) * 100
}

# Add premiums, expected assets and prob. bankruptcy to a 
# dataframe so that it is compatible with ggplot
dfr <- data.frame(premiums, means_premium, bankrupt_premium)

# Create ggplot
ggplot(dfr, aes(x = premiums, y = means_premium)) +
  
  # Add markers to show expected assets at year end for each premium
  geom_point(size = 4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Add axis titles
  xlab("Annual Premium (£)") +
  ylab("Expected Assets (£ Millions)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

# Create ggplot
ggplot(dfr, aes(x=premiums, y=bankrupt_premium)) +
  
  # Add markers to show bankrupt_premium vs. premiums
  geom_point(size=4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Adjust the y-axis limits
  ylim(0,20) +
  
  # Add a horizontal line at prob_bankrupcty = 2% 
  geom_hline(yintercept=2, linetype="dashed", colour="red", size=1) +
  
  # Add an arrow pointing to the optimal premium
  geom_segment(aes(x=7250, y=7.5, xend=7050, yend=3), size=1.3,
               arrow=arrow(length=unit(0.5, "cm"))) +
  
  # Add a text box
  annotate("label", x=7250, y=10, label="Premium = 7000\nP(Bankruptcy) = 2.07%") +
  
  # Add axis titles
  xlab("Annual Premium (£)") +
  ylab("Probability of Bankruptcy (%)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

###########################################################
####################### Question 3B #######################
###########################################################

# Generate a vector of claim probs 0.05, 0.055, 0.06, ..., 0.15
probclaims <- seq(0.05, 0.15, by = 0.005)

# Simulate assets of company at year end 10,000 times 
MCclaims <- MCsimul(B, init_assets, premium, nclient, probclaims, alpha, beta)

# Calculate the expected assets at year end
# Divide by 1 million for aesthetic purposes
means_claims <- colMeans(MCclaims) / 1000000

# Calculate the probability of bankruptcy at year end
bankrupt_claims <- vector()
for(i in 1:length(probclaims)) {
  bankrupt_claims[i] <- sum(MCclaims[,i] < 0) / nrow(MCclaims) * 100
}

# Multiply probclaims by 100 for aesthetic purposes
probclaims <- probclaims * 100

# Add probclaims, means_claims and bankrupt_claims to a dataframe
# so it will work with ggplot
dfr <- data.frame(probclaims, means_claims, bankrupt_claims)

# Create ggplot
ggplot(dfr, aes(x = probclaims, y = means_claims)) +
  
  # Add markers to show expected assets at year end for each premium
  geom_point(size = 4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Add a horizontal line at y = 0
  geom_hline(yintercept = 0, linetype = "dashed") +
  
  # Add axis titles
  xlab("Probability of a Customer Making a Claim (%)") +
  ylab("Expected Assets (£ Millions)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

# Create ggplot
ggplot(dfr, aes(x = probclaims, y = bankrupt_claims)) +
  
  # Add markers to show bankrupt_claims vs. probclaims
  geom_point(size = 4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Adjust the y-axis limits
  ylim(0, 90) +
  
  # Add a horizontal line at prob_bankrupcty = 2%
  geom_hline(yintercept = 2, linetype = "dashed", colour = "red", size = 1) +
  
  # Add an arrow pointing to the optimal claim probability
  geom_segment(aes(x = 8.3, y = 25, xend = 8.05, yend = 6), size = 1.3,
               arrow = arrow(length = unit(0.5, "cm"))) +
  
  # Add a text box
  annotate("label", x = 8.3, y = 35, label = "P(Claim) = 8%\nP(Bankruptcy) = 1.65%") +
  
  # Add axis titles
  xlab("Probability of a Customer Making a Claim (%)") +
  ylab("Probability of Bankruptcy (%)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

# Repeat the same analysis for more precise estimate of maximum probability of making claim #so that P(bankrupt)<2%
probclaims <- seq(0.08, 0.085, by = 0.0005)
MCclaims <- MCsimul(B, init_assets, premium, nclient, probclaims, alpha, beta)
means_claims <- colMeans(MCclaims) / 1000000
bankrupt_claims <- vector()
for(i in 1:length(probclaims)) {
  bankrupt_claims[i] <- sum(MCclaims[,i] < 0) / nrow(MCclaims) * 100
}
probclaims <- probclaims * 100
rbind(probclaims,bankrupt_claims)

###########################################################
############# Additional Analysis for Report ##############
###########################################################

### (1) Varying alpha

# Generate a vector of alpha's
alpha_seq <- seq(2.5, 3.5, by = 0.1)
df <- data.frame(alpha_seq)

# Compute probability of bankruptcy for each alpha
for(i in 1:length(alpha_seq)) {
  df[i, 2] <- 100 * sum(MCsimul(B, init_assets, premium, nclient, probclaim, alpha_seq[i], beta) < 0) / B
}

colnames(df) <- c("alpha", "pbankruptcy")

# Create ggplot
ggplot(df, aes(x = alpha, y = pbankruptcy)) +
  
  # Add markers to show alpha vs. pbankruptcy
  geom_point(size = 4) +
  
  # Connect the markers with a line
  geom_line() +
  
  # Add axis titles
  xlab("Parameter Alpha") +
  ylab("Probability of Bankruptcy (%)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

###########################################################

### (2) Varying beta

# Generate a vector of beta's
beta_seq <- seq(80000, 120000, by = 2500)
df <- data.frame(beta_seq / 1000)

# Compute probability of bankruptcy for each beta
for(i in 1:length(beta_seq)) {
  df[i, 2] <- 100 * sum(MCsimul(B, init_assets, premium, nclient, probclaim, alpha, beta_seq[i]) < 0) / B
}

colnames(df) <- c("beta", "pbankruptcy")

# Create ggplot
ggplot(df, aes(x = beta, y = pbankruptcy)) +
  
  # Add markers to show beta vs. pbankruptcy
  geom_point(size = 4) +
  
  # Connect markers with a line
  geom_line() +
  
  # Add axis titles
  xlab("Parameter Beta (x1000)") +
  ylab("Probability of Bankruptcy (%)") +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12))

###########################################################

### (3) Reinsurance

# Redefine input values
init_assets <- 250000
nclient <- 1000
premium <- 6000
probclaim <- 0.1
alpha <- 3
beta <- 100000

# Simulate assets after 1 year 10,000 times
MC <- MCsimul(B, init_assets, premium, nclient, probclaim, alpha, beta)

# Write a function to find reasonable caps
probbankrupt_cap <- function(dat, p) {
  # For a given p, estimate M such that P(Assets_1 < -M) = p
  df <- sort(dat, decreasing = F)
  
  ind = 1
  
  while(ind / B < p){
    ind = ind + 1
  }
  return(-df[ind - 1])
}


# Write a function to determine the reinsurance premium and probability of bankruptcy for a given cap
determine_reinspremium <- function(reinsp0, reinsp1, M) {
  iter = 1
  while(abs(reinsp1 - reinsp0) / reinsp0 > 0.0001 & iter < 1000) {
    # Compute premium and assets at year end repeatedly until convergence
    reinsp0 = reinsp1
    
    # Assets at year end is original minus premium reinsurance
    A1 = MC - reinsp0
    
    # Compute probability assets between -M and 0
    probM0 = sum((-M <= A1) & (A1 < 0))/B
    
    # Compute premium = -1.1 E[costs for reinsurer]
    reinsp1 = -1.1 * probM0 * mean(A1[(-M <= A1) & (A1 < 0)])
    iter = iter + 1
  }
  # Compute actual probability of bankruptcy
  A1 = MC - reinsp0
  pbankrupt <- sum((A1 < -M))/B
  return(list(reinsp1, pbankrupt))
}


# Generate a vector of probabilities of bankruptcy
p <- seq(0.005, 0.05, by = 0.005)

df <- matrix(p, ncol = 1)
df <- cbind(df, matrix(0, nrow = nrow(df), ncol = 3))

for(i in 1:nrow(df)) {
  
  # Determine caps
  cap <- probbankrupt_cap(MC, p[i])
  
  # Determine 'fair' reinsurance premium and P(bankruptcy)
  # (The starting values 0.1*cap and 0.2*cap are arbitrary)
  list_premium_probbankrupt <- determine_reinspremium(0.1 * cap, 0.2 * cap, cap)
  premium <- list_premium_probbankrupt[[1]]
  pbankrupt <- list_premium_probbankrupt[[2]]
  
  df[i, 2] <- cap / 1000
  
  df[i, 3] <- premium / 1000
  
  df[i,4] <- pbankrupt*100
}

# Add elements to dataframe to make them compatible with ggplot
dfr <- data.frame(df)
colnames(dfr) <- c("p", "cap", "premium", "pbankrupt")
dfr$pbankrupt <- dfr$p * 100

# Create ggplot
ggplot(dfr, aes(x = pbankrupt)) +
  
  # Add a line representing pbankrupt vs. cap
  geom_line(aes(y = cap, colour = "Cap Size"), size=1) +
  
  # Add a line representing pbankrupt vs. premium
  geom_line(aes(y = premium * 25, colour = "Annual Premium"), size=1) +
  
  # Put premiums on a secondary axis
  scale_y_continuous(sec.axis = sec_axis(~./25, name = "Annual Premium (£ Thousands)")) +
  
  geom_segment(aes(x = 0, y = dfr$cap[6], xend = 3, yend = dfr$cap[6], colour = "Cap Size"), linetype="dashed") +
  
  geom_segment(aes(x = 3, y = dfr$premium[6]*25, xend = 5, yend = dfr$premium[6]*25, colour = "Annual Premium"), linetype="dashed") +
  
  geom_vline(xintercept=3, size=0.8) +
  
  # Change the color of the lines
  scale_colour_manual(values = c("blue", "red")) +
  
  # Add axis labels
  ylab("Cap Size (£ Thousands)") +
  xlab("Probability of Bankruptcy (%)") +
  labs(colour = "Legend") +
  
  # Move legend to the top of the figure
  theme(legend.position = c(0.8, 0.9)) +
  
  # Adjust font sizes
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text.y=element_text(size = 12),
        axis.text.x=element_text(size = 12)) +
  
  scale_x_continuous(expand = c(0, 0)) 
