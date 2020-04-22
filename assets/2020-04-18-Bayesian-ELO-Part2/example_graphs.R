# 'posterior' data to plot the graphs is obtaine after running bayesian_elo_parameter_estimation.R
# from the git@github.com:sachinthak/afl_prediction.git repo

library(data.table)
library(ggplot2)
library(ggridges)
library(latex2exp)

#saveRDS(posterior,'~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/posterior.RDS')
#posterior <- readRDS('~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/posterior.RDS')

#cols <- c("Posterior"="#0072B2","Prior" = "#0072B2")
#line_types <- c("Posterior"=1,"Prior"=3)
# "#E69F00"
x_seq <- seq(-50,250, by  = 1)
ggplot() + geom_density(aes(x=posterior[,'K']), size = .7, col = "#0072B2") +
  scale_x_continuous(limits = c(-50,250), breaks = seq(-40,200,20), name = 'K') +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50)), linetype = 'dashed',
            size = .5, col = "#0072B2") + geom_vline(xintercept = mean(posterior[,'K']), linetype = 'dashed') +
  # scale_color_manual(name = 'Distribution', values = cols) +
 # scale_linetype_manual(values=line_types) +
 theme_bw()

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/k_posterior.png')


x_seq <- seq(-50,250, by  = 1)
ggplot() + geom_density(aes(x=posterior[,'K']), size = .7, col = "#0072B2") +
  geom_density(aes(x=posterior2[,'K']), size = .7, col = "#E69F00") + 
  scale_x_continuous(limits = c(-50,250), breaks = seq(-40,200,20), name = 'K') +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50)), linetype = 'dashed',
            size = .5, col = "#0072B2") + geom_vline(xintercept = mean(posterior[,'K']), linetype = 'dashed') +
  # scale_color_manual(name = 'Distribution', values = cols) +
  # scale_linetype_manual(values=line_types) +
  theme_bw()

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





# sensitivity analysis graphs ---------------------------------------------

cols = c("col1"="#0072B2", "col2"="#E69F00")
collabels = c('Original', 'Modified')
lines = c('line1'=1,'line2'=2)
linelabels = c('Posterior', 'Prior')

# case 1 - lognormal with same mean and variance
x_seq <- seq(-50,250, by  = 1)
x_seq2 <- seq(1,250, by  = 1)
ggplot() + 
  stat_density(geom='line', aes(x=posterior[,'K'], col = 'col1',linetype = 'line1'), size = .7) +
  stat_density(geom='line', aes(x=posterior2[,'K'], col = 'col2',linetype = 'line1'), size = .7) +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50), col = 'col1', linetype = 'line2' ),
            size = .5) +
  geom_vline(xintercept = mean(posterior[,'K']), linetype = 5, col = "#0072B2",size = .7) +
  geom_vline(xintercept = mean(posterior2[,'K']), linetype = 5, col = "#E69F00",size = .7) +
  geom_line(aes(x=x_seq2,y=dlnorm(x_seq2, meanlog = log(100^2/sqrt(100^2+50^2)),
                                  sdlog = sqrt(log(1 + 50^2/100^2)))),
            size = .5, col = "#E69F00",  linetype = 'dashed') +
  theme_bw() + theme(legend.title = element_blank())+
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_x_continuous( name = TeX('$K$'),limits = c(-50,250), breaks = seq(-50,250,40)) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_1_k.png')





x_seq <- seq(100,1000, by  = 1)

ggplot() + 
  stat_density(geom='line', aes(x=posterior[,'xi'],col = "col1", linetype = 'line1'), size = .7) +
  stat_density(geom='line',aes(x=posterior2[,'xi'],col = "col2", linetype = 'line1'), size = .7 ) +
  geom_vline(xintercept = mean(posterior[,'xi']), linetype = 5, col = "#0072B2",size = .7 ) + 
  geom_vline(xintercept = mean(posterior2[,'xi']), linetype = 5, col = "#E69F00",size = .7 ) + 
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 400,sd = 100),linetype = 'line2',col = "col1") ,
            size = .5 ) + 
  geom_line(aes(x=x_seq,y=dlnorm(x_seq, meanlog =  log(400^2/sqrt(400^2+100^2)),
                                 sdlog = sqrt(log(1 + 100^2/400^2))),
                linetype = 'line2',col = "col2"),
            size = .5 ) + 
  scale_x_continuous( name = TeX('$\\tau$'),limits = c(100,1000), breaks = seq(100,1000,40)) +
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  #ggtitle( label = 'Case 1') + 
  theme_bw() + theme(legend.title = element_blank())+
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_1_tau.png')


# case 2 - student t with same mean and scaling parmter

x_seq <- seq(-50,250, by  = 1)
df = 3
t_sig = 100
t_mu = 50

ggplot() + 
 stat_density(geom = 'line', aes(x=posterior[,'K'], col = 'col1', linetype = 'line1'), size = .7) +
 stat_density(geom = 'line', aes(x=posterior2[,'K'], col = 'col2', linetype = 'line1'), size = .7) +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50), col = 'col1',linetype = 'line2' ),
            size = .5) +
 geom_vline(xintercept = mean(posterior[,'K']), linetype = 5, col = "#0072B2", size = .7) +
 geom_vline(xintercept = mean(posterior2[,'K']), linetype = 5, col =  "#E69F00", size = .7) +
  geom_line(aes(x=x_seq,y=1/t_sig*dt((x_seq-t_mu)/t_sig,df = df),
                col = 'col2',  linetype = 'line2'),
            size = .5) +
  theme_bw() + theme(legend.title = element_blank())+
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_x_continuous( name = TeX('$K$'),limits = c(-50,250), breaks = seq(-50,250,40)) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_2_k.png')

x_seq <- seq(100,1000, by  = 1)
df = 3
t_sig = 100
t_mu = 400
ggplot() + 
  stat_density(geom = 'line', aes(x=posterior[,'xi'],col = "col1", linetype = 'line1'), size = .7) +
  stat_density(geom = 'line', aes(x=posterior2[,'xi'], col = "col2", linetype = 'line1'), size = .7) +
  geom_vline(xintercept = mean(posterior[,'xi']), linetype = 5, col = "#0072B2",size = .7 ) + 
  geom_vline(xintercept = mean(posterior2[,'xi']), linetype = 5, col = "#E69F00",size = .7 ) + 
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 400,sd = 100),col = "col1", linetype = 'line2'),
            size = .5) + 
  geom_line(aes(x=x_seq,y=1/t_sig*dt((x_seq-t_mu)/t_sig,df = df), col = "col2",  linetype = 'line2'),
            size = .5)  +
  scale_x_continuous( name = TeX('$\\tau$'),limits = c(100,1000), breaks = seq(100,1000,40)) +
  theme_bw() + theme(legend.title = element_blank())+
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_2_tau.png')


# case 3- student t with shifted mean and wide spread

x_seq <- seq(-50,250, by  = 1)
df = 3
t_sig = 100
t_mu = 80

ggplot() + 
  stat_density(geom = 'line', aes(x=posterior[,'K'], col = 'col1', linetype = 'line1'), size = .7) +
  stat_density(geom = 'line', aes(x=posterior2[,'K'], col = 'col2', linetype = 'line1'), size = .7) +
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 100,sd = 50), col = 'col1',linetype = 'line2' ),
            size = .5) +
  geom_vline(xintercept = mean(posterior[,'K']), linetype = 5, col = "#0072B2", size = .7) +
  geom_vline(xintercept = mean(posterior2[,'K']), linetype = 5, col =  "#E69F00", size = .7) +
  geom_line(aes(x=x_seq,y=1/t_sig*dt((x_seq-t_mu)/t_sig,df = df),
                col = 'col2',  linetype = 'line2'),
            size = .5) +
  theme_bw() + theme(legend.title = element_blank())+
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_x_continuous( name = TeX('$K$'),limits = c(-50,250), breaks = seq(-50,250,40)) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_3_k.png')

x_seq <- seq(100,1000, by  = 1)
df = 3
t_sig = 200
t_mu = 200
ggplot() + 
  stat_density(geom = 'line', aes(x=posterior[,'xi'],col = "col1", linetype = 'line1'), size = .7) +
  stat_density(geom = 'line', aes(x=posterior2[,'xi'], col = "col2", linetype = 'line1'), size = .7) +
  geom_vline(xintercept = mean(posterior[,'xi']), linetype = 5, col = "#0072B2",size = .7 ) + 
  geom_vline(xintercept = mean(posterior2[,'xi']), linetype = 5, col = "#E69F00",size = .7 ) + 
  geom_line(aes(x=x_seq,y=dnorm(x_seq, mean = 400,sd = 100),col = "col1", linetype = 'line2'),
            size = .5) + 
  geom_line(aes(x=x_seq,y=1/t_sig*dt((x_seq-t_mu)/t_sig,df = df), col = "col2",  linetype = 'line2'),
            size = .5)  +
  scale_x_continuous( name = TeX('$\\tau$'),limits = c(100,1000), breaks = seq(100,1000,40)) +
  theme_bw() + theme(legend.title = element_blank())+
  scale_color_manual(name = "color", values = cols, 
                     labels = collabels,
                     guide = guide_legend(override.aes=aes(fill=NA))) +
  scale_linetype_manual(name = 'line',values=lines,labels = linelabels, guide = 'none') +
  theme(legend.position = c(0.8, 0.8))
ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/case_3_tau.png')


# Example graph of a team
team <- 'St Kilda'
team_id <- which(team_list == team)
cols <- grep(pattern = paste0("^elo_score\\[[[:digit:]]+,",team_id,"\\]"), x = colnames(posterior),
     value = T)

team_elo_dat <- as.data.table(posterior[, cols])
team_elo_dat <- melt.data.table(team_elo_dat, measure.vars =  cols, value.name = 'Elo')

# extract the round
team_elo_dat[, rnd := gsub(pattern = paste0("^elo_score\\[([[:digit:]]+),",team_id,"\\]"),
                    "\\1",
                    variable)]

team_elo_dat[, variable := NULL]
# add the initial elo 

team_elo_dat <- rbind(data.table(Elo = posterior[, paste0('elo_pre_season[',team_id,']') ], 
                              rnd = 0),team_elo_dat)

team_elo_dat[, rnd := as.numeric(rnd)]


ggplot(team_elo_dat) + geom_density_ridges(aes(x=Elo, y = as.factor(rnd)), col = "#0072B2",
                                           fill = "#0072B2", alpha = .2,panel_scaling = T) +
  geom_vline(xintercept = 1500, linetype = 'dashed') + 
  ggtitle('Posterior distributions of Elo ratings after each round for St Kilda Saints') +
  scale_y_discrete(name = 'Round') + theme_bw()

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/st_kilda_elo.png')



# Example graph of a team
team <- 'West Coast'
team_id <- which(team_list == team)
cols <- grep(pattern = paste0("^elo_score\\[[[:digit:]]+,",team_id,"\\]"), x = colnames(posterior),
             value = T)

team_elo_dat <- as.data.table(posterior[, cols])
team_elo_dat <- melt.data.table(team_elo_dat, measure.vars =  cols, value.name = 'Elo')

# extract the round
team_elo_dat[, rnd := gsub(pattern = paste0("^elo_score\\[([[:digit:]]+),",team_id,"\\]"),
                           "\\1",
                           variable)]

team_elo_dat[, variable := NULL]
# add the initial elo 

team_elo_dat <- rbind(data.table(Elo = posterior[, paste0('elo_pre_season[',team_id,']') ], 
                                 rnd = 0),team_elo_dat)

team_elo_dat[, rnd := as.numeric(rnd)]


ggplot(team_elo_dat) + geom_density_ridges(aes(x=Elo, y = as.factor(rnd)), col = "#0072B2",
                                           fill = "#0072B2", alpha = .2,panel_scaling = T) +
  geom_vline(xintercept = 1500, linetype = 'dashed') +
  ggtitle('Posterior distributions of Elo ratings after each round for West Coast Eagles') +
  scale_y_discrete(name = 'Round') + theme_bw()

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-18-Bayesian-ELO-Part2/west_coast_elo.png')
