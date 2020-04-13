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

Next let's focus on some properties of ELO

### Not all wins and losses are treated equal

What I mean by this is that, a win of a highly rated team against a very low rated team only barely changes the ratings, while losing to such a team penalise the ratings of the top team disproportionately.  Lets look at an example. Continuing the previous example, assume that the team A's current Elo rating is 500 (instead of 1300). When compared against an initial Elo score of 1600 for team B, it is a significantly lower rating. If team B wins against team A, the Elo score of team B would increase just marginally from 1600 to 1600.071. On the contrary if team B lost to team A, the Elo ratings of team B would  incur a substantial drop to a new rating of 1560.071.
{:.text-justify}

Similarly losing to a very strong team alter the Elo rating of the weak team just marginally, whereas a win against a strong team result in disproportional gain in the Elo rating. This behaviour is due to the property that I discuss next.
{:.text-justify}

### Conservation of average Elo

This is also known as the zero-sum rule. Precisely, provided that $S_{A,B} + S_{B,A} = 1$, increase in team A's Elo is equal to the decrease in team B's Elo and vice versa.
In other words
{:.text-justify}

\begin{equation}
  r_{A,\text{new}} - r_{A,\text{old}} = r_{B,\text{old}} - r_{B,\text{new}}.
\end{equation}

This implies that the average Elo value across all the teams remain static despite fluctuations in individual team ratings.

### K factor

K value directly affects the volatility of the ratings. A big value of K means that a even a marginally better performance from a team alters that team's rating by a significant amount. On the opposite end, a too small value of K, causes just a little shift in a team's rating despite exceptional performance.  It is easy to see that in the extreme case of $K = 0$ the ratings remain static indefinitely.  
{:.text-justify}


### logistic parameter $\tau$

 How does the difference in Elo translate into likelihood of team B winning compared to team A winning? Logistic parameter can help answer this and put some context behind the Elo difference. Recall that $\mu_{A,B}$ is a number between 0 and 1. This could be (loosely) interpreted as the expected probability of team A winning against team B. With some algebra it can be shown that
\begin{equation}
  \frac{\mu_{A,B}}{\mu_{B,A}}= 10^{(r_{A,\text{old}}-r_{B,\text{old}})/\tau} .
\end{equation}.
{:.text-justify}

Notice that an Elo difference of $\tau$ means that probability that team A wins against team B is 10 times more than the probability of team B beating team A.
{:.text-justify}

### Accounting for margin of victory

Recall the $S_{i,j}$  term introduced earlier. So far the system described here treat a win by just a single point and a win by a significant margin as the same. This is clearly not desirable. Let $h_{i,j}$ and $h_{j,i}$ denote the scores that team $i$ scored against team $j$ and vice versa, respectively. A simple modification to take the margin of victory into the Elo system is to incorporate the team scores for the match is to redefine $S_{i,j}$ as
\begin{equation}
  S_{i,j} = \frac{h_{i,j}+1}{h_{j,i} + h_{i,j} + 2}.
\end{equation}
{:.text-justify}

Note that even after this modification $S_{i,j} + S_{j,i} = 1$.


### Limitations

In the vanilla Elo system described here, important factors such as player substitution, injuries, team dynamics, home field are not taken into account. These factors could have a material influence to the outcome of a game. However, though the home field advantage can be somewhat accounted for by some modifications, for the purposes of the current exercise, I have ignored the home field advantage.


## Bayesian Elo?

Rather than assuming the parameters $K$ and $\tau$ as fixed parameters, what if I treat them as random parameters and use data to estimate them? This means that team ratings, in turn become random quantities. Intuition suggests that it would be a better approach for modelling as it enables to express the uncertainty of these parameters quantitatively. I used [Stan](https://mc-stan.org) to implement my version of the Bayesian Elo for AFL.  For further motivation, I present below some of the parameters that was estimated, expressed as  probability densities.
![GitHub Logo]({{ site.baseurl }}/assets/2020-04-11-Bayesian-ELO-Part1/k_density.png)
![GitHub Logo]({{ site.baseurl }}/assets/2020-04-11-Bayesian-ELO-Part1/tau_density.png)
![GitHub Logo]({{ site.baseurl }}/assets/2020-04-11-Bayesian-ELO-Part1/elo_rating_density.png)

More details on the modelling approach and method for calculating winning probabilities for the premiership based on simulations will be presented in part 2 and 3 of this series.
