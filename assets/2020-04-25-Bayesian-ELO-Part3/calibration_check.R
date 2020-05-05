library(bayesplot)

curr_season <- 2018
final_8_fixed <- 0  # Do we have the final 8 fixed so far? Used in simulating the future matches
semi_final_4_fixed <- 0  # Do we have the semi final 4 fixed so far? Used in simulating the future matches
prelim_final_4_fixed <- 0 # Do we have the prelim final 4 fixed so far? Used in simulating the future matches
final_2_fixed <- 0  # Do we have the final 2 fixed so far? Used in simulating the future matches
premiership_team_fixed <- 0 # Do we have the premiership fixed so far? Used in simulating the 'future matches'

# dummy ids or actual teams ids to pass on to stan. (Later on the code these will be fixed if we actually know them)
final_8_team_ids_input <- 1:8 
semi_final_4_team_ids_input <- 1:4
prelim_final_4_team_ids_input <- 1:4
final_2_team_ids_input <- 1:2
premiership_team_id_input <- 1


past_results[, round_numeric := as.numeric(gsub(pattern = 'Round ([::digit::]*)', '\\1', 
                                                round))]
predictive_calib_check_dat <- data.table()

for (rnd in 5:23) {
  

results <- past_results[season == curr_season & round_numeric < rnd,]
future_schedule <- schedules[season == curr_season][!results, on = c('round','team1','team2')]

# generate input data to pass on to Stan ----------------------------------

round_ids <- results[, as.numeric(gsub(pattern = "Round (.*)",replacement = '\\1',x = round))]
futr_round_ids <- future_schedule[, as.numeric(gsub(pattern = "Round (.*)",replacement = '\\1',x = round))]
n_rounds <- uniqueN(round_ids)
futr_n_rounds <- uniqueN(futr_round_ids)

team_list <- sort(unique(union(results$team1,results$team2)))
n_teams <- length(team_list)

# get the ids of teams
team1_ids <- sapply(results$team1, function(team){get_team_id(team,team_list)})
team2_ids <- sapply(results$team2, function(team){get_team_id(team,team_list)})
futr_team1_ids <- sapply(future_schedule$team1, function(team){get_team_id(team,team_list)})
futr_team2_ids <- sapply(future_schedule$team2, function(team){get_team_id(team,team_list)})



# get scores
team1_score <- results$score_team1
team2_score <- results$score_team2
team1_win_indictr <- as.numeric(team1_score >= team2_score)


# calculate for and against scores. Used for tie-breaking in the ranks when calculating the final 8
for_against_scores_1 <- results[, .(for_score = sum(score_team1), against_score = sum(score_team2)), by = team1]
for_against_scores_2 <- results[, .(for_score = sum(score_team2), against_score = sum(score_team1)), by = team2]
setnames(for_against_scores_1,'team1','team')
setnames(for_against_scores_2,'team2','team')
for_against_scores <- rbind(for_against_scores_1,for_against_scores_2)
for_against_scores <- for_against_scores[, .(for_score = sum(for_score), 
                                             against_score = sum(against_score)), by = team]
# reorder according to the team_list
for_against_scores <- for_against_scores[sapply(team_list, function(t){which(t == team)}),] 
for_against_ratio <- for_against_scores$for_score/for_against_scores$against_score 

# calculate team points for the ladder board
points_ladder <- sapply(team_list, function(team){
  # win is a 4 and draw is a 2
  s1 <- as.numeric(results[team1 == team, 
                           sum(ifelse(score_team1 >  score_team2,4,
                                      ifelse(score_team1 == score_team2,2,0)))])
  s2 <- as.numeric(results[team2 == team, 
                           sum(ifelse(score_team2 >  score_team1,4,
                                      ifelse(score_team1 == score_team2,2,0)))])
  s1+s2
})


# temporary hack to get the final 8 and to correctly label the QF and EF matches
if (final_8_fixed){
  points_ladder_dat <- data.table(team = team_list, points = points_ladder, 
                                  for_against_ratio = for_against_ratio)
  setorder(points_ladder_dat, -points, -for_against_ratio)
  final_8_team_names <- points_ladder_dat[1:8,team]
  final_8_team_ids_input <- sapply(final_8_team_names, function(team) {which(team == team_list)})
  
  # QF 1
  future_schedule[grep('Final',round_full_desc) & team1 == final_8_team_names[1],  
                  round_full_desc := 'Qualifying Final 1']
  # QF 2
  future_schedule[grep('Final',round_full_desc) & team1 == final_8_team_names[2],  
                  round_full_desc := 'Qualifying Final 2']
  
  # EF 1
  future_schedule[grep('Final',round_full_desc) & team1 == final_8_team_names[5],  
                  round_full_desc := 'Elimination Final 1']
  # EF 2
  future_schedule[grep('Final',round_full_desc) & team1 == final_8_team_names[6],  
                  round_full_desc := 'Elimination Final 2']
}

futr_rnd_type <- sapply(future_schedule$round_full_desc,function(rnd)(encode_rnd(rnd)))

# assemble input data to a list to be passed onto stan
input_list_stan <- list(round_ids = round_ids, n_rounds = n_rounds, n_matches = nrow(results),
                        n_teams = n_teams, team1_ids = as.numeric(team1_ids),
                        team2_ids = as.numeric(team2_ids), team1_win_indictr = team1_win_indictr,
                        futr_team1_ids = futr_team1_ids, futr_team2_ids = futr_team2_ids,
                        futr_round_ids = futr_round_ids, first_futr_round = futr_round_ids[1],
                        futr_n_rounds = futr_n_rounds, futr_n_matches = nrow(future_schedule),
                        futr_rnd_type = futr_rnd_type, points_ladder = points_ladder,
                        for_against_ratio = for_against_ratio, final_2_fixed = final_2_fixed,
                        semi_final_4_fixed = semi_final_4_fixed, prelim_final_4_fixed = prelim_final_4_fixed,
                        final_8_fixed = final_8_fixed, premiership_team_fixed = premiership_team_fixed, 
                        final_2_team_ids_input = final_2_team_ids_input, semi_final_4_team_ids_input = semi_final_4_team_ids_input,
                        prelim_final_4_team_ids_input = prelim_final_4_team_ids_input, final_8_team_ids_input = final_8_team_ids_input,
                        premiership_team_id_input = premiership_team_id_input)


# fit the stan model
fit <- stan(file = 'src/bayesian_elo_parameter_estimation.stan', data = input_list_stan, 
            iter = 20000, chains = 4, cores = 4)

# do some plotting
posterior <- as.matrix(fit)

xi_smps <- posterior[, 'xi']

# calculate the probabilities of the future matches
n_sims <- nrow(posterior)
future_schedule[, team1_win_prob := sapply(1:nrow(future_schedule), function(match){
  col_name <- paste0('futr_match_outcome[',match,']')  
  num_sim_wins <- sum(posterior[,col_name])
  num_sim_wins/n_sims})]

# just filter the next round
next_round_matches <- future_schedule[round == paste0('Round ',rnd)]

# calculate the win prob using another method
next_round_matches[, team1_win_prob_method2 := sapply(1:nrow(next_round_matches), function(match){
  team1_elo_smps <- posterior[, paste0('elo_score[',rnd-1,',',futr_team1_ids[match],']')]
  team2_elo_smps <- posterior[, paste0('elo_score[',rnd-1,',',futr_team2_ids[match],']')]
  mu_smps <- 1/(1+ 10^(-(team1_elo_smps-team2_elo_smps)/xi_smps))
  mean(mu_smps)})]

predictive_calib_check_dat <- rbind(predictive_calib_check_dat,next_round_matches)
}

#saveRDS(predictive_calib_check_dat,file = '~/my_stuff/sachinthak.github.io/assets/2020-04-25-Bayesian-ELO-Part3/predictive_check.rds')
#predictive_calib_check_dat <- readRDS('~/my_stuff/sachinthak.github.io/assets/2020-04-25-Bayesian-ELO-Part3/predictive_check.rds')
# get the scores


# just remove the last round results
predictive_calib_check_dat[, round_numeric := as.numeric(gsub(pattern = 'Round ([::digit::]*)', '\\1', 
                                    round))]
predictive_calib_check_dat <- predictive_calib_check_dat[round_numeric < 23]

# calculate win probabilities for retrospective calibration check
xi_smps <- posterior[, 'xi'] 

retrospective_calib_check_dat <- results[, .(round, team1, team2,score_team1, score_team2, season,
                                          date,venue, round_full_desc, .I, round_numeric)]

retrospective_calib_check_dat <- retrospective_calib_check_dat[round_numeric >=5 & round_numeric < 23]
rnd_id <- retrospective_calib_check_dat$round_numeric
match_id <- retrospective_calib_check_dat$I

retrospective_calib_check_dat[, team1_win_prob := sapply(1:nrow(retrospective_calib_check_dat), function(match){
  team1_elo_smps <- posterior[, paste0('elo_score[',rnd_id[match]-1,',',team1_ids[match_id[match]],']')]
  team2_elo_smps <- posterior[, paste0('elo_score[',rnd_id[match]-1,',',team2_ids[match_id[match]],']')]
  mu_smps <- 1/(1+ 10^(-(team1_elo_smps-team2_elo_smps)/xi_smps))
  trials <- rbinom(n = length(mu_smps),size = 1, prob = mu_smps)
  sum(trials)/length(trials)})]


retrospective_calib_check_dat[, team1_win_prob_method2 := sapply(1:nrow(retrospective_calib_check_dat), function(match){
  team1_elo_smps <- posterior[, paste0('elo_score[',rnd_id[match]-1,',',team1_ids[match_id[match]],']')]
  team2_elo_smps <- posterior[, paste0('elo_score[',rnd_id[match]-1,',',team2_ids[match_id[match]],']')]
  mu_smps <- 1/(1+ 10^(-(team1_elo_smps-team2_elo_smps)/xi_smps))
  mean(mu_smps)})]


# combine the predictive and retrospective data

calib_check_dat <- rbind(predictive_calib_check_dat[, .(direction = 'predictive', team1, team2, round, team1_win_prob, team1_win_prob_method2)],
                         retrospective_calib_check_dat[, .(direction = 'retrospective', team1, team2, round, team1_win_prob, team1_win_prob_method2)])

calib_check_dat <- past_results[season == curr_season, .(round, team1, team2,score_team1, score_team2)][calib_check_dat, 
                                                                                  on = .(round, team1,team2)]

calib_check_dat[, team1_win_indictr  := as.numeric(score_team1 >= score_team2)]

# bin the probabilities
cut_points <- seq(from = 0, to = 1, by = .1)
calib_check_dat[, prob_bin := .bincode(team1_win_prob, cut_points, TRUE)]

# summarise the bins
dat <- calib_check_dat[, .(team1_win_prob = mean(team1_win_prob), team1_win_percentage = mean(team1_win_indictr)), 
                by = .(direction, prob_bin)]

cols = c("predictive"="#0072B2", "retrospective"="#E69F00")

collabels = c('Predictive calibration check', 'Retrospective calibration check')

ggplot(dat) + geom_point(aes(x=team1_win_prob, y = team1_win_percentage, col = direction))+
  geom_smooth(method = 'lm',aes(x=team1_win_prob, y = team1_win_percentage, col = direction), se = F) +
  geom_abline(slope = 1, intercept = 0, linetype = 'dashed') +
  scale_color_manual(name = "color", values = cols, labels = collabels) + 
  scale_x_continuous( name = 'Team 1 winnning probability (binned) from the model', limits = c(0,1),
                      breaks = seq(0,1,.1)) +
  scale_y_continuous( name = 'Fraction of times team 1 actually won', limits = c(0,1),
                      breaks = seq(0,1,.1)) +
   theme_bw() + theme(legend.position = c(0.75, 0.2)) + theme(legend.title= element_blank()) 

ggsave(filename = '~/my_stuff/sachinthak.github.io/assets/2020-04-25-Bayesian-ELO-Part3/calibration_check.png')

# checking some other metrics

calib_check_dat[, Metrics::accuracy(team1_win_indictr, team1_win_prob>.5), by = 'direction']
# .0.6535948, 0.6666667

calib_check_dat[, Metrics::precision(team1_win_indictr, team1_win_prob>.5), by = 'direction']
# 0.69 , 0.71

calib_check_dat[, Metrics::recall(team1_win_indictr, team1_win_prob>.5), by = 'direction']
# 0.65, 0.65

calib_check_dat[, Metrics::auc(team1_win_indictr, team1_win_prob), by = 'direction']
# 0.72, .75




# final series probabilities ----------------------------------------------


# after round 22
final_series_probabilities <- return_final_series_probabilities(simulated_samples = posterior, 
                                                                team_list = team_list)
final_series_probabilities[, cbind(team_name,round(.SD,2)), .SDcols = 2:6]

# after round 15
# re run the contents of the above for loop with rnd set to 16 

