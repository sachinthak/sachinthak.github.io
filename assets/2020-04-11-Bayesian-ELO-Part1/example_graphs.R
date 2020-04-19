# 'posterior' data to plot the graphs is obtaine after running bayesian_elo_parameter_estimation.R
# from the git@github.com:sachinthak/afl_prediction.git repo

library(data.table)
library(ggplot2)
library(latex2exp)

saveRDS(posterior,'~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/posterior.RDS')
posterior <- readRDS('~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/posterior.RDS')
#cols <- c("Posterior"="#0072B2","Prior" = "#0072B2")
#line_types <- c("Posterior"=1,"Prior"=3)
x_seq <- seq(-50,250, by  = 1)
ggplot() + geom_density(aes(x=posterior[,'K']), size = .7, col = "#0072B2") +
  scale_x_continuous(limits = c(-50,250), breaks = seq(-40,200,20), name = 'K') +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50)), linetype = 'dashed',
            size = .5, col = "#0072B2") + geom_vline(xintercept = mean(posterior[,'K']), linetype = 'dashed') +
  # scale_color_manual(name = 'Distribution', values = cols) +
 # scale_linetype_manual(values=line_types) +
 theme_bw()

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/k_posterior.png')

mean(posterior[,'K'])
sd(posterior[,'K'])

x_seq <- seq(100,800, by  = 1)
ggplot() + geom_density(aes(x=posterior[,'xi']), size = .7, col = "#0072B2") +
  geom_vline(xintercept = mean(posterior[,'xi']), linetype = 'dashed') + 
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 400,sd = 100)), linetype = 'dashed',
            size = .5, col = "#0072B2") + 
  scale_x_continuous( name = TeX('$\\tau$'),limits = c(100,800), breaks = seq(100,800,40)) +
  theme_bw()

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/tau_posterior.png')

mean(posterior[,'xi'])
sd(posterior[,'xi'])

futr_elo_score[1,11]
ggplot() + geom_density(aes(x=posterior[,'futr_elo_score[1,11]']), size = .7, col = "#0072B2") +
  scale_x_continuous(name = 'Elo rating') +
  geom_vline(xintercept = mean(posterior[,'futr_elo_score[1,11]']), linetype = 'dashed') + theme_bw()
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-11-Bayesian-ELO-Part1/elo_rating_density.png')

ggplotposterior[,'K']
