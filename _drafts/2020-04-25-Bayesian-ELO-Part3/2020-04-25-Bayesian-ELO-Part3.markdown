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

Our belief of probability of team $A$ winning against $B$ in round $n+1$ can be approximated as
$\frac{1}{M}\sum_{m=1}^M  W_{A,B,n+1}^{(m)}$.



### Looking under the hood

Why is $\frac{1}{M}\sum_{m=1}^M  W_{A,B,n+1}^{(m)}$ an approximation to team $A$'s winning probability and what does it got to do with Bayes? Let me explain.  
{:.text-justify}

Formally, what we are after is the posterior predictive distribution for the outcome of the next match. In other words, what probability do we assign to the outcome of a **future** match, **after observing** the actual outcomes of rounds 1 to $n$. Let $\mathbf{W}_{A,B,n}$ denote a vector of  match outcomes of all the past matches up to and including round $n$. Then the posterior predictive distribution can be approximated as follows.
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

First equality follows from [Chapman-Kolmogorov](https://en.wikipedia.org/wiki/Chapman–Kolmogorov_equation) equation. Second equality is due to the conditional probability formula. Note the term $p(\tau,r_{A,n},r_{B,n}\|\mathbf{W}_{A,B,n})$ is the joint posterior distribution of (some of) the parameters from the Elo model. Third line is by using a Monte Carlo approximation to the integral using the MCMC samples which approximate the draws from the posterior distribution.
{:.text-justify}

## Simulating matches beyond the immediate round

In order to workout the probabilities of winning the premiership, we need to simulate future matches not just for the next round but until a team wins the premiership. If we can simulate these virtual tournaments many times then the proportion of times a given team ends up winning the premiership is an approximation for that team's probability of winning the tournament. The power and flexibility of Monte Carlo simulations is that, the same method can be used to find probabilities of other events, such as a team making the top 8, semi finals or preliminary finals, etc.
{:.text-justify}

Our parameter space for which MCMC samples is generated is multidimensional. That is, after $n$ (physical) rounds of matches, the parameters in our model for which the inference is performed are the Elo parameters $K$ and $\tau$ and Elo rating for each team after each round up to and including round $n$. It should be noted that a single sample from the MCMC chain gives a realisation for each of these parameters. For each MCMC sample, I create a trajectory of outcomes for future matches. The important thing to note is that outcomes of the simulated matches are used to update the Elo ratings for future rounds according to the Elo update formula, which I discussed in part 1 and 2.
{:.text-justify}

There is a subtle point that I wish to emphasise here. Though, I update the future Elo ratings based on the simulated outcomes, I implicitly assume that the future Elo rating changes are purely based on current Elo ratings and the stochastic nature of the dynamics induced by the Elo framework. In other words, factors such as future changes in team morale etc are not captured, because the Elo rating updates for the future rounds are based on simulated match outcomes instead of  actual match outcomes.  
{:.text-justify}

The MCMC for parameter estimation and future match simulation were both handled via [Stan](https://mc-stan.org). Though, I had some limited experience with Stan before, this is the first time I used it extensively. Beyond round 23, the teams facing head to head  in a match are not fixed and depend on the outcome of the previous matches. Because Stan is a probabilisitic programming language and not a general purpose language like Python, there  was a bit of a learning curve involved to figure out how to implement the ["AFL final eight system"](https://en.wikipedia.org/wiki/AFL_final_eight_system) purely in Stan,
{:.text-justify}

Here are the estimated probabilities for tournament outcome as evaluated at the end of round 22.


| Header One     | Header Two     |
| :------------- | :------------- |
| Item One       | Item Two       |
