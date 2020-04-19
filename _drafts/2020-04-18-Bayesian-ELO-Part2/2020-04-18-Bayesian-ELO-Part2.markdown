---
layout: post
title:  "Bayesian Elo - Part 2/3"
date:   2020-04-18
mathjax: true
categories: Bayes Sports Stan
---

In the first post I presented an introduction to the Elo rating system.
In this second post of 3 part series I describe the specifics of the model used to infer the Elo parameters $K$ and $\tau$ and once $K$ and $\tau$ are estimated, how Monte Carlo simulations could be used to infer the Elo ratings of the teams that reflect parameter uncertainty. In other words, instead of a single point estimate for a team's Elo rating, we can get a more informative view by looking at plausible values of Elo expressed as a probability distribution. This is a precursor for the final piece of the puzzle, covered in the 3rd post, where I estimate the win probabilities of future matures, including the Premiership.
The source code for this work can be found [here](https://github.com/sachinthak/afl_prediction).
{:.text-justify}

## Modelling


### Prior distributions

The model specified here is extremely simple. First I treat the Elo parameters $K$ and $\tau$ as random parameters. I assign somewhat weekly informative Normal distributions for these parameters as follows.
{:.text-justify}

$$\begin{aligned}
K &\sim \mathcal{N}(100,50^2),\\
\tau &\sim \mathcal{N}(400,100^2).\\
\end{aligned}
$$

where $\mathcal{N}(\mu,\sigma^2)$ denotes a Normal distribution with mean $\mu$ and standard deviation $\sigma$.  To understand why the above prior choices are weakly informative, notice that $K$ could take a value between 0 and 300 with approximately 95% probability, easily covering the typical $K$ values used in sports. Similarly the approximate 95% interval for $\tau$ is (200,600).
{:.text-justify}

Let $r_{i,n}$ denote the Elo rating of team $i$ after round $n$. The Elo rating at the beginning of the season is denoted by $r_{i,0}$. What prior should I assign to $r_{i,0}$? One option would be to look at the past seasons of the teams and assign priors accordingly, perhaps with some allowance for [regression to the mean](https://en.wikipedia.org/wiki/Regression_toward_the_mean). But, I take a simple approach by acknowledging the ignorance of additional data and assume all the teams's initial Elo ratings are independent and identically distributed, i.e.
{:.text-justify}

\begin{equation}
  r_{i,0} \sim \mathcal{N}(1500,100^2).
\end{equation}
{:.text-justify}

### Likelihood

Let $W_{i,j,n}$ denote the outcome of a match between team $i$ and $j$ encountered in round $n$.

$$
 W(i,j,n) =
  \begin{cases}
   1 & \text{if team } i \text{ win the round $n$ match,} \\
   0       & \text{otherwise}.
  \end{cases}
$$

For simplicity, I do not distinguish between a loss and a tie.

Define $\delta_{i,j,n}$ as
\begin{equation}
\delta_{i,j,n} = r_{i,n-1} - r_{j,n-1}.
\end{equation}.

To form the likelihood function, I model $ W(i,j,n)$ as a Bernoulli trial with parameter $\mu_{i,j,n}$ where

$$
\mu_{i,j,n} = \frac{1}{1 + 10^{-\delta_{i,j,n}/\tau}}.
$$

After the outcome of the round $n$ match is available, Elo ratings are updated as

$$\begin{aligned}
  r_{i,n} &= r_{i,n-1} + K(S_{i,j,n}-\mu_{i,j,n}),\\
  r_{j,n} &= r_{j,n-1} + K(S_{j,i,n}-\mu_{j,i,n})\\
\end{aligned}
$$

where

$$
 S(i,j,n) =
  \begin{cases}
   1 & \text{if } i \text{ win the round $n$ match,} \\
   0       & \text{if } j  \text{  win the round $n$ match,}\\
   0.5 &\text{if the round $n$ match ties}.
  \end{cases}$$

Along with the above model specification and the actual match outcomes we can approximate the posterior distributions of the Elo parameters $K$, $\tau$ and the team ratings $r_{i,n}$ by using Markov Chain Monte Carlo. I used [Stan](https://mc-stan.org) to implement the model described above.
{:.text-justify}

## Results

After fitting the model with the match outcomes upto and including round 23, the posterior distributions for $K$ and $\tau$ are shown below. Posterior distributions were approximated from 4 parallel Markov Chains, each of length 10,000 (20,000 samples were drawn, but the first 10,000 of each chain was discarded as warmup).
The solid lines represent the posterior distribution while the dashed line represent the prior.
{:.text-justify}

![GitHub Logo]({{ site.baseurl }}/assets/2020-04-18-Bayesian-ELO-Part2/k_posterior.png)

![GitHub Logo]({{ site.baseurl }}/assets/2020-04-18-Bayesian-ELO-Part2/tau_posterior.png)

Posterior point estimates for the Elo parameters are shown in the following table along with the standard deviation.

|  parameter     | posterior mean           | posterior standard deviation  |
| ------------- |:-------------:| -----:|
| $K$      | 57.22 | 26.77 |
| $\tau$      | 439.04      |   89.06 |
{:.text-justify}


### Team Elo ratings as the season progressed

Note that we assigned a $\mathcal{N}(1500,100^2)$ prior for each team's Elo rating at the beginning of the season (i.e round = 0).
The prior specification for the Elo ratings for round 0,  together with  the Elo update formula, implictly induce prior distributions for Elo ratings for all the rounds. The MCMC samples from the fitted model can be used to approximate the posterior distributions of Elo ratings, after each round, for any team. Below, I plot this for two teams, St Kilda and West Coast Eagles, the latter team turned out to be the eventual winners of the tournament, while the former did not have a good season. In the below graphs, density plots for each round are stacked vertically. The dashed vertical line indicate the base Elo rating set by the prior 1500.

![GitHub Logo]({{ site.baseurl }}/assets/2020-04-18-Bayesian-ELO-Part2/st_kilda_elo.png)
