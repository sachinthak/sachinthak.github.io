---
layout: post
title:  "Bayesian Elo - Part 3/3"
date:   2020-04-25
mathjax: true
categories: Bayes Sports Stan
---

This is the final post of the 3 part series on Bayesian Elo. To summarise, in the first post, I briefly explained  the Elo rating system along with the two key parameters involved. In the second post, I described how a Bayesian model could be setup to estimate the Elo parameters and the
Elo ratings of teams. In this post, I discuss how we can use the model to estimate the win probabilities of future matches, including the tournament outcome using simulations. I assume that you are familiar with the notations I have used for part 1 and 2 and thus do not explain it again here. The source code for this work can be found [here](https://github.com/sachinthak/afl_prediction).
{:.text-justify}

## Estimating the win probabilities for the next round.


Assume we want to simulate a match outcome for team $A$ against team $B$ for round $n+1$. First, lets fix the Elo parameters $K$ and $\tau$ to some arbitrary values $K^\ast$ and $\tau^\ast$ respectively. Similarly, fix the Elo ratings  $r_{A,n}$ and $r_{B,n}$ at  $r_{A,n}^\ast$
and $r_{B,n}^\ast$ respectively. For those fixed values, our likelihood function returns the  probability of team $A$ winning against team $B$ as
a Bernoulli trial with parameter $\mu_{A,B,n}^\ast$ where
{:.text-justify}

$$
\mu_{A,B,n}^\ast = \frac{1}{1 + 10^{-\delta_{A,B,n}^\ast/\tau^\ast}}
$$

with

\begin{equation}
\delta_{A,B,n}^\ast = r_{A,n}^\ast - r_{B,n}^\ast.
\end{equation}.

We can randomly simulate a match outcome by drawing a sample from $\mathcal{Bern}(\mu_{A,B,n}^\ast)$. So far, we have fixed the Elo parameters,
and the ratings, and by doing so ignored the uncertainty of these parameters. First step in fixing this is to note that the posterior distribution of these parameters contain all the information we know of them after observing past match outcomes. These distributions encode the uncertainty of these parameters. To capture the effect of uncertainty of these parameters, instead of using a fixed set of values, we could draw many samples from the posterior distributions and use those samples values to simulate match outcomes. Conveniently MCMC samples, after sufficient [burn-in/warmup](https://statmodeling.stat.columbia.edu/2017/12/15/burn-vs-warm-iterative-simulation-algorithms/) can be used as draws from the posterior. The proportion of simulated matches that team $A$ won against team $B$ is an approximation to team $A$'s win probability.
{:.text-justify}

Assume I have $M$ draws from the (joint) posterior distribution. I use the superscript notation to indicate the sample number. For example $\tau^{(m)}$ denote the $$m^\text{th}$$  MCMC sample for $\tau$. Let $W_{A,B,n+1}^{(m)}$ denote the simulated match outcome (for round $n+1$) drawn from the Bernoulli distribution with $\mu_{A,B,n}^{(m)}$, i.e.
{:.text-justify}

$$
 W_{A,B,n+1}^{(m)} \sim \mathcal{Bern}\left(\mu_{A,B,n}^{(m)}\right)
$$

where the $\mu_{A,B,n}^{(m)}$ is calculated using $\tau^{(m)}, r_{A,n}^{(m)}$ and $r_{B,n}^{(m)}$.

Probability of team $A$ winning against $B$ in round $n+1$ is given by

$$\begin{aligned}
 \text{Pr}\left(W_{A,B,n+1} = 1\right) &\approx \frac{1}{M} \sum_{m=1}^M \mu_{A,B,n}^{(m)},\\
                            &\approx \frac{1}{M}\sum_{m=1}^M  W_{A,B,n+1}^{(m)}.
\end{aligned}$$

### Looking under the hood

Why is the right hand side of the above equation an approximation to team $A$'s winning probability and what does it got to do with Bayes? Let me explain.  
{:.text-justify}

Formally, what we are after is the posterior predictive distribution for the outcome of the next match. That is, what probability do we assign to the outcome of the **future** match, **after observing** the actual outcomes of rounds 1 to $n$, . That is
{:.text-justify}

$$
\text{Pr}\left(W_{A,B,n+1}=1|\mathbf{W}_{A,B,n}\right)
$$

where $\mathbf{W}_{A,B,n}$ is a vector of  match outcomes of all the past matches up to and including round $n$.

As a step towards evaluating the above quantity, I introduce the Elo parameters and the ratings and then marginalise them out. This is possible
because of [Chapman-Kolmogorov](https://en.wikipedia.org/wiki/Chapman–Kolmogorov_equation) equation.
{:.text-justify}

$$\begin{aligned}
  &\text{Pr}\left(W_{A,B,n+1}=1|\mathbf{W}_{A,B,n}\right)  \\
    &= \int p\left(W_{A,B,n+1}=1,\tau,r_{A,n},r_{B,n}| \mathbf{W}_{A,B,n}\right) \text{d}\tau \text{d}r_{A,n}\text{d}r_{B,n},\\
    &= \int \text{Pr}\left(W_{A,B,n+1}=1|\tau,r_{A,n},r_{B,n}\right)p(\tau,r_{A,n},r_{B,n} |\mathbf{W}_{A,B,n})\text{d}\tau \text{d}r_{A,n}\text{d}r_{B,n},\\
    &\approx  \frac{1}{M}\sum_{m=1}^M\text{Pr}\left(W_{A,B,n+1}=1|\tau,^{(m)}r_{A,n}^{(m)},r_{B,n}^{(m)}\right),\\
    &=  \frac{1}{M} \sum_{m=1}^M \mu_{A,B,n}^{(m)},\\
    &\approx \frac{1}{M}\sum_{m=1}^M  W_{A,B,n+1}^{(m)}.
\end{aligned}
$$


In the 3rd and final part of the series, I will go into the details of how we can simulate the remainder of the tournaments and use these simulation results to approximate the probability of each team making it to the finals series or winning the Premiership, etc.
