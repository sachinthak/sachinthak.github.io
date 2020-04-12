---
layout: post
title:  "Bayesian Elo - Part 1/3"
date:   2020-04-11 09:22:47 +1000
mathjax: true
categories: Bayes Sports
---

In this 3 part series, I want to share some of the work I did for fun during the 2018 AFL season. In part 1 (this post), I  give a brief introduction to the Elo ranking system.  In the second post, I will share how a Bayesian Model can be fit to estimate the parameters of the model. I will also share the results of applying the Bayesian Elo method to analyse how the team rankings changed as the 2018 AFL season progressed. One of the advantages of using a Bayesian Elo framework is that it allows us to capture the uncertainty or the randomness in team rankings and consequently account for them in predicting the match or tournament outcomes. What exactly I mean by this would be evident in the 2nd post of the series. In the 3rd post, I will show how we can use simulations to estimate the probabilities of the tournament outcome (of course, before the tournament ends). The source code for this work can be found [here](https://github.com/sachinthak/afl_prediction).
{:.text-justify}

## What is Elo?

Elo system, named after the inventor Arpad Elo was developed originally to rank Chess players. However, ELO has been extended to other sports including soccer, [basketball](https://fivethirtyeight.com/features/how-we-calculate-nba-elo-ratings/), tennis, etc.
{: .text-justify}

At the heart of the system is a formula to update the ratings of two any two teams whenever the teams encounter a head to head match. The change in the two teams ratings are based on:
{: .text-justify}
- the current ratings of the two teams,
- the outcome of the match (win/lose/tie) or the scores against each other,
- The ELO parameters $K$ and $\tau$.
{:.text-justify}

## How does it work?

Assume that two teams $i$ and $j$ have current ELO ratings of $r_{i,\text{old}}$ and $r_{j,\text{old}}$ respectively. Define the difference between the current Elo ratings, $\delta_{i,j}$, as

\begin{equation}
\delta_{i,j} = r_{i,\text{old}} - r_{j,\text{old}}.
\end{equation}
{:.text-justify}

Once the outcome of a match between  two teams $S_{i,j}$ is  observed, the Elo ratings for the two teams are updated as $r_{i,\text{new}}$ and $r_{j,\text{new}}$
according to

$$\begin{aligned}
  r_{i,\text{new}} &= r_{i,\text{old}} + K(S_{i,j}-\mu_{i,j}),\\
  r_{j,\text{new}} &= r_{j,\text{old}} + K(S_{j,i}-\mu_{j,i})\\
\end{aligned}
$$

where

$$
 S(i,j) =
  \begin{cases}
   1 & \text{if } i \text{ win,} \\
   0       & \text{if } j  \text{  win,}\\
   0.5 &\text{if the game ties}
  \end{cases}$$

and

$$\begin{aligned}
  \mu_{i,j}  &= \text{logistic}_{10}(-\delta_{i,j}/\tau),\\
  &= \frac{1}{1 + 10^{-\delta_{i,j}/\tau}}.
  \end{aligned}
$$

Here $K$ and $\tau$ are parameters of the Elo system known as "K-factor" and "logistic parameter" respectively. The chosen values of $K$ and $\tau$ vary by sport and implementation. As an example, in International Chess Federation's current implementation [$K = 40$](https://ratings.fide.com/calc.phtml?page=change)  and $\tau = 400$ for a new player until he/she has completed events with at least 30 games.
{:.text-justify}

Let's work through an example.
Assume that two teams A and B with current Elo ratings 1300 and 1600 respectively played a match against each other and team B won. The updated rankings for each team are as follows for an Elo system with $K = 40$ and $\tau = 400$.
{:.text-justify}

$$\begin{aligned}
  r_{B,\text{new}}  &=  1600 + 40 \left(1-\frac{1}{1+ 10^{-\frac{(1600-1300)}{400}}}\right),\\
                    &\approx 1606,\\
  r_{A,\text{new}}  &=  1300 + 40 \left(0-\frac{1}{1+ 10^{-\frac{(1300-1600)}{400}}}\right),\\
                                      &\approx 1294.                    
  \end{aligned}
$$


- equal Sum
- K factor
- Asymetrical
- logistic parameter
- extensions




## Bayesian Elo?
